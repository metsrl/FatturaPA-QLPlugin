import Foundation

// MARK: - Data Model

struct FatturaPAModel {
    // Cedente / Prestatore
    var fornitoreNome: String = ""
    var fornitorePIVA: String = ""
    var fornitoreCF: String = ""
    var fornitoreIndirizzo: String = ""
    var fornitoreCap: String = ""
    var fornitoreComune: String = ""
    var fornitoreProvincia: String = ""

    // Cessionario / Committente
    var clienteNome: String = ""
    var clientePIVA: String = ""
    var clienteCF: String = ""
    var clienteIndirizzo: String = ""
    var clienteCap: String = ""
    var clienteComune: String = ""
    var clienteProvincia: String = ""

    // Dati Generali
    var tipoDocumento: String = ""
    var divisa: String = "EUR"
    var data: String = ""
    var numero: String = ""
    var causale: String = ""

    // Dati Pagamento
    var modalitaPagamento: String = ""
    var dataScadenzaPagamento: String = ""
    var importoPagamento: String = ""
    var ibanAccredito: String = ""

    // Linee
    var linee: [LineaFattura] = []

    // Totali
    var imponibile: String = ""
    var imposta: String = ""
    var totale: String = ""

    // Aliquote
    var aliquoteRiepilogo: [AliquotaRiepilogo] = []
}

struct LineaFattura {
    var numero: String = ""
    var descrizione: String = ""
    var quantita: String = ""
    var unitaMisura: String = ""
    var prezzoUnitario: String = ""
    var sconto: String = ""
    var prezzoTotale: String = ""
    var aliquotaIVA: String = ""
    var natura: String = ""
}

struct AliquotaRiepilogo {
    var aliquotaIVA: String = ""
    var natura: String = ""
    var imponibile: String = ""
    var imposta: String = ""
    var esigibilitaIVA: String = ""
}

// MARK: - XML Parser

class FatturaPAParser: NSObject, XMLParserDelegate {

    private let xmlString: String
    private var model = FatturaPAModel()

    // Parser state
    private var currentPath: [String] = []
    private var currentText: String = ""
    private var currentLinea = LineaFattura()
    private var currentAliquota = AliquotaRiepilogo()
    private var inLinea = false
    private var inAliquota = false
    private var inCedente = false
    private var inCessionario = false
    private var inDatiGenerali = false
    private var inPagamento = false

    init(xmlString: String) {
        self.xmlString = xmlString
    }

    func parse() -> FatturaPAModel {
        guard let data = xmlString.data(using: .utf8) else { return model }
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return model
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String: String] = [:]) {
        currentPath.append(elementName)
        currentText = ""

        let path = currentPath.joined(separator: "/")

        if elementName == "CedentePrestatore" { inCedente = true }
        if elementName == "CessionarioCommittente" { inCessionario = true; inCedente = false }
        if elementName == "DatiGeneraliDocumento" { inDatiGenerali = true }
        if elementName == "DatiPagamento" { inPagamento = true }
        if elementName == "DettaglioLinee" { inLinea = true; currentLinea = LineaFattura() }
        if elementName == "DatiRiepilogo" { inAliquota = true; currentAliquota = AliquotaRiepilogo() }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        let value = currentText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Cedente / Prestatore
        if inCedente && !inCessionario {
            switch elementName {
            case "Denominazione", "Nome":
                if model.fornitoreNome.isEmpty { model.fornitoreNome = value }
            case "Cognome":
                if !value.isEmpty { model.fornitoreNome = (model.fornitoreNome + " " + value).trimmingCharacters(in: .whitespaces) }
            case "IdCodice":
                if model.fornitorePIVA.isEmpty { model.fornitorePIVA = value }
            case "CodiceFiscale":
                if model.fornitoreCF.isEmpty { model.fornitoreCF = value }
            case "Indirizzo":
                if model.fornitoreIndirizzo.isEmpty { model.fornitoreIndirizzo = value }
            case "CAP":
                if model.fornitoreCap.isEmpty { model.fornitoreCap = value }
            case "Comune":
                if model.fornitoreComune.isEmpty { model.fornitoreComune = value }
            case "Provincia":
                if model.fornitoreProvincia.isEmpty { model.fornitoreProvincia = value }
            default: break
            }
        }

        // Cessionario
        if inCessionario {
            switch elementName {
            case "Denominazione", "Nome":
                if model.clienteNome.isEmpty { model.clienteNome = value }
            case "Cognome":
                if !value.isEmpty { model.clienteNome = (model.clienteNome + " " + value).trimmingCharacters(in: .whitespaces) }
            case "IdCodice":
                if model.clientePIVA.isEmpty { model.clientePIVA = value }
            case "CodiceFiscale":
                if model.clienteCF.isEmpty { model.clienteCF = value }
            case "Indirizzo":
                if model.clienteIndirizzo.isEmpty { model.clienteIndirizzo = value }
            case "CAP":
                if model.clienteCap.isEmpty { model.clienteCap = value }
            case "Comune":
                if model.clienteComune.isEmpty { model.clienteComune = value }
            case "Provincia":
                if model.clienteProvincia.isEmpty { model.clienteProvincia = value }
            default: break
            }
        }

        // Dati Generali
        if inDatiGenerali {
            switch elementName {
            case "TipoDocumento": model.tipoDocumento = value
            case "Divisa": model.divisa = value
            case "Data": model.data = formatDate(value)
            case "Numero": model.numero = value
            case "Causale": if model.causale.isEmpty { model.causale = value }
            default: break
            }
        }

        // Pagamento
        if inPagamento {
            switch elementName {
            case "ModalitaPagamento": model.modalitaPagamento = descrizionePagamento(value)
            case "DataScadenzaPagamento": model.dataScadenzaPagamento = formatDate(value)
            case "ImportoPagamento": model.importoPagamento = formatCurrency(value)
            case "IBAN": model.ibanAccredito = value
            default: break
            }
        }

        // Linee
        if inLinea {
            switch elementName {
            case "NumeroLinea": currentLinea.numero = value
            case "Descrizione": currentLinea.descrizione = value
            case "Quantita": currentLinea.quantita = formatNumber(value)
            case "UnitaMisura": currentLinea.unitaMisura = value
            case "PrezzoUnitario": currentLinea.prezzoUnitario = formatCurrency(value)
            case "PercentualeSconto": currentLinea.sconto = value + "%"
            case "PrezzoTotale": currentLinea.prezzoTotale = formatCurrency(value)
            case "AliquotaIVA": currentLinea.aliquotaIVA = value + "%"
            case "Natura": currentLinea.natura = value
            default: break
            }
        }

        // Aliquote riepilogo
        if inAliquota {
            switch elementName {
            case "AliquotaIVA": currentAliquota.aliquotaIVA = value + "%"
            case "Natura": currentAliquota.natura = value
            case "ImponibileImporto": currentAliquota.imponibile = formatCurrency(value)
            case "Imposta": currentAliquota.imposta = formatCurrency(value)
            case "EsigibilitaIVA": currentAliquota.esigibilitaIVA = value
            default: break
            }
        }

        // Totali
        switch elementName {
        case "ImponibileImporto": model.imponibile = formatCurrency(value)
        case "Imposta": model.imposta = formatCurrency(value)
        case "ImportoTotaleDocumento": model.totale = formatCurrency(value)
        default: break
        }

        // Close sections
        if elementName == "CedentePrestatore" { inCedente = false }
        if elementName == "CessionarioCommittente" { inCessionario = false }
        if elementName == "DatiGeneraliDocumento" { inDatiGenerali = false }
        if elementName == "DatiPagamento" { inPagamento = false }
        if elementName == "DettaglioLinee" {
            model.linee.append(currentLinea)
            inLinea = false
        }
        if elementName == "DatiRiepilogo" {
            model.aliquoteRiepilogo.append(currentAliquota)
            inAliquota = false
        }

        currentPath.removeLast()
        currentText = ""
    }

    // MARK: - Helpers

    private func formatDate(_ s: String) -> String {
        // Input: YYYY-MM-DD → Output: DD/MM/YYYY
        let parts = s.split(separator: "-")
        guard parts.count == 3 else { return s }
        return "\(parts[2])/\(parts[1])/\(parts[0])"
    }

    private func formatCurrency(_ s: String) -> String {
        guard let val = Double(s) else { return s }
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = 2
        fmt.maximumFractionDigits = 2
        fmt.decimalSeparator = ","
        fmt.groupingSeparator = "."
        return fmt.string(from: NSNumber(value: val)) ?? s
    }

    private func formatNumber(_ s: String) -> String {
        guard let val = Double(s) else { return s }
        if val == val.rounded() && !s.contains(".") { return String(Int(val)) }
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.minimumFractionDigits = 0
        fmt.maximumFractionDigits = 4
        fmt.decimalSeparator = ","
        return fmt.string(from: NSNumber(value: val)) ?? s
    }

    private func descrizionePagamento(_ codice: String) -> String {
        let map: [String: String] = [
            "MP01": "Contanti", "MP02": "Assegno", "MP03": "Assegno circolare",
            "MP04": "Contanti presso Tesoreria", "MP05": "Bonifico", "MP06": "Vaglia cambiario",
            "MP07": "Bollettino bancario", "MP08": "Carta di pagamento",
            "MP09": "RID", "MP10": "RID utenze", "MP11": "RID veloce",
            "MP12": "RIBA", "MP13": "MAV", "MP14": "Quietanza erario",
            "MP15": "Giroconto su conti di contabilità speciale", "MP16": "Domiciliazione bancaria",
            "MP17": "Domiciliazione postale", "MP18": "Bollettino di c/c postale",
            "MP19": "SEPA Direct Debit", "MP20": "SEPA Direct Debit CORE",
            "MP21": "SEPA Direct Debit B2B", "MP22": "Trattenuta su somme già riscosse",
            "MP23": "PagoPA"
        ]
        return map[codice] ?? codice
    }
}
