import Foundation

struct HTMLRenderer {

    static func render(fattura: FatturaPAModel) -> String {
        let tipoLabel = tipoDocumentoLabel(fattura.tipoDocumento)
        let lineeHTML = fattura.linee.map { lineaRow($0) }.joined()
        let riepilogoHTML = fattura.aliquoteRiepilogo.map { riepilogoRow($0) }.joined()

        return """
        <!DOCTYPE html>
        <html lang="it">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          :root {
            --blu: #1A3A5C;
            --blu-chiaro: #2563EB;
            --verde: #059669;
            --rosso: #DC2626;
            --grigio-scuro: #1F2937;
            --grigio-medio: #6B7280;
            --grigio-chiaro: #F3F4F6;
            --bordo: #E5E7EB;
            --bianco: #FFFFFF;
          }

          * { box-sizing: border-box; margin: 0; padding: 0; }

          body {
            font-family: -apple-system, 'Helvetica Neue', Arial, sans-serif;
            font-size: 13px;
            color: var(--grigio-scuro);
            background: #F8FAFC;
            padding: 24px;
            line-height: 1.5;
          }

          .fattura-card {
            background: var(--bianco);
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08), 0 4px 16px rgba(0,0,0,0.06);
            overflow: hidden;
            max-width: 960px;
            margin: 0 auto;
          }

          /* INTESTAZIONE */
          .header {
            background: linear-gradient(135deg, var(--blu) 0%, #243B5E 100%);
            color: white;
            padding: 24px 28px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
          }
          .header-left h1 {
            font-size: 22px;
            font-weight: 700;
            letter-spacing: -0.3px;
          }
          .header-left .subtitle {
            font-size: 12px;
            opacity: 0.7;
            margin-top: 3px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
          }
          .header-right {
            text-align: right;
          }
          .header-right .doc-numero {
            font-size: 15px;
            font-weight: 600;
          }
          .header-right .doc-data {
            font-size: 12px;
            opacity: 0.75;
            margin-top: 4px;
          }
          .badge {
            display: inline-block;
            background: rgba(255,255,255,0.18);
            border: 1px solid rgba(255,255,255,0.25);
            border-radius: 20px;
            padding: 3px 10px;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 0.5px;
            margin-top: 8px;
            text-transform: uppercase;
          }

          /* SEZIONI */
          .body { padding: 0 28px 24px; }

          .soggetti {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-top: 20px;
          }
          .soggetto {
            background: var(--grigio-chiaro);
            border-radius: 8px;
            padding: 14px 16px;
          }
          .soggetto-label {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--grigio-medio);
            margin-bottom: 6px;
          }
          .soggetto-nome {
            font-size: 15px;
            font-weight: 700;
            color: var(--blu);
            line-height: 1.3;
          }
          .soggetto-detail {
            font-size: 11.5px;
            color: var(--grigio-medio);
            margin-top: 3px;
          }
          .soggetto-detail span {
            color: var(--grigio-scuro);
          }

          /* SEPARATORE */
          .sep {
            border: none;
            border-top: 1px solid var(--bordo);
            margin: 20px 0 0;
          }

          /* SEZIONE TITOLO */
          .sezione-titolo {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--grigio-medio);
            margin: 20px 0 10px;
          }

          /* TABELLA LINEE */
          table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12.5px;
          }
          thead th {
            background: var(--blu);
            color: white;
            padding: 8px 10px;
            text-align: left;
            font-weight: 600;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
          }
          thead th:first-child { border-radius: 6px 0 0 6px; }
          thead th:last-child { border-radius: 0 6px 6px 0; }
          tbody tr:nth-child(even) { background: #F9FAFB; }
          tbody tr:hover { background: #EFF6FF; }
          tbody td {
            padding: 8px 10px;
            border-bottom: 1px solid var(--bordo);
            vertical-align: top;
          }
          td.num, th.num { text-align: right; }
          td.center, th.center { text-align: center; }

          .desc-principale { font-weight: 500; }
          .natura-badge {
            display: inline-block;
            background: #FEF3C7;
            color: #92400E;
            border-radius: 4px;
            padding: 1px 5px;
            font-size: 10px;
            font-weight: 600;
            margin-left: 6px;
          }

          /* RIEPILOGO IVA */
          .riepilogo-table th { background: #374151; }

          /* TOTALI */
          .totali {
            margin-top: 16px;
            display: flex;
            justify-content: flex-end;
          }
          .totali-box {
            background: var(--grigio-chiaro);
            border-radius: 8px;
            padding: 14px 20px;
            min-width: 280px;
          }
          .totale-row {
            display: flex;
            justify-content: space-between;
            padding: 4px 0;
            font-size: 13px;
          }
          .totale-row label { color: var(--grigio-medio); }
          .totale-row .val { font-weight: 600; }
          .totale-finale {
            display: flex;
            justify-content: space-between;
            padding: 10px 0 0;
            margin-top: 8px;
            border-top: 2px solid var(--blu);
            font-size: 16px;
            font-weight: 700;
          }
          .totale-finale label { color: var(--blu); }
          .totale-finale .val { color: var(--blu); }
          .divisa {
            font-size: 11px;
            font-weight: 400;
            color: var(--grigio-medio);
            margin-left: 4px;
          }

          /* PAGAMENTO */
          .pagamento-grid {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
          }
          .pagamento-item {
            flex: 1;
            min-width: 180px;
            background: var(--grigio-chiaro);
            border-radius: 8px;
            padding: 12px 14px;
          }
          .pagamento-label {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--grigio-medio);
            margin-bottom: 4px;
          }
          .pagamento-val {
            font-size: 13px;
            font-weight: 600;
            color: var(--grigio-scuro);
          }
          .iban { font-family: 'SF Mono', Monaco, monospace; font-size: 11.5px; }

          /* CAUSALE */
          .causale-box {
            background: #FFFBEB;
            border: 1px solid #FDE68A;
            border-radius: 8px;
            padding: 12px 14px;
            font-size: 12.5px;
            color: #78350F;
          }

          /* FOOTER */
          .footer {
            background: var(--grigio-chiaro);
            border-top: 1px solid var(--bordo);
            padding: 10px 28px;
            text-align: center;
            font-size: 10.5px;
            color: var(--grigio-medio);
          }
          .footer strong { color: var(--grigio-scuro); }

          /* VUOTO */
          .vuoto { color: var(--grigio-medio); font-style: italic; }
        </style>
        </head>
        <body>
        <div class="fattura-card">

          <!-- HEADER -->
          <div class="header">
            <div class="header-left">
              <h1>\(escape(fattura.fornitoreNome))</h1>
              <div class="subtitle">Fattura Elettronica · FatturaPA</div>
              \(fattura.tipoDocumento.isEmpty ? "" : "<div class='badge'>\(escape(tipoLabel))</div>")
            </div>
            <div class="header-right">
              \(fattura.numero.isEmpty ? "" : "<div class='doc-numero'>N° \(escape(fattura.numero))</div>")
              \(fattura.data.isEmpty ? "" : "<div class='doc-data'>Data: \(escape(fattura.data))</div>")
            </div>
          </div>

          <div class="body">

            <!-- SOGGETTI -->
            <div class="soggetti">
              <div class="soggetto">
                <div class="soggetto-label">Cedente / Prestatore</div>
                <div class="soggetto-nome">\(escape(fattura.fornitoreNome))</div>
                \(pivaRow("P.IVA", fattura.fornitorePIVA))
                \(pivaRow("C.F.", fattura.fornitoreCF))
                \(indirizzoRow(fattura.fornitoreIndirizzo, fattura.fornitoreCap, fattura.fornitoreComune, fattura.fornitoreProvincia))
              </div>
              <div class="soggetto">
                <div class="soggetto-label">Cessionario / Committente</div>
                <div class="soggetto-nome">\(escape(fattura.clienteNome))</div>
                \(pivaRow("P.IVA", fattura.clientePIVA))
                \(pivaRow("C.F.", fattura.clienteCF))
                \(indirizzoRow(fattura.clienteIndirizzo, fattura.clienteCap, fattura.clienteComune, fattura.clienteProvincia))
              </div>
            </div>

            <!-- CAUSALE -->
            \(fattura.causale.isEmpty ? "" : """
            <hr class="sep">
            <div class="sezione-titolo">Causale</div>
            <div class="causale-box">\(escape(fattura.causale))</div>
            """)

            <!-- LINEE -->
            <hr class="sep">
            <div class="sezione-titolo">Dettaglio Prestazioni / Beni</div>
            \(fattura.linee.isEmpty ? "<p class='vuoto'>Nessuna linea trovata.</p>" : """
            <table>
              <thead>
                <tr>
                  <th class="center">#</th>
                  <th>Descrizione</th>
                  <th class="center">Q.tà</th>
                  <th class="center">U.M.</th>
                  <th class="num">Prezzo Unit.</th>
                  <th class="center">IVA</th>
                  <th class="num">Totale</th>
                </tr>
              </thead>
              <tbody>
                \(lineeHTML)
              </tbody>
            </table>
            """)

            <!-- RIEPILOGO IVA -->
            \(fattura.aliquoteRiepilogo.isEmpty ? "" : """
            <hr class="sep">
            <div class="sezione-titolo">Riepilogo IVA</div>
            <table class="riepilogo-table">
              <thead>
                <tr>
                  <th>Aliquota IVA</th>
                  <th>Natura</th>
                  <th class="num">Imponibile</th>
                  <th class="num">Imposta</th>
                </tr>
              </thead>
              <tbody>
                \(riepilogoHTML)
              </tbody>
            </table>
            """)

            <!-- TOTALI -->
            <div class="totali">
              <div class="totali-box">
                \(fattura.imponibile.isEmpty ? "" : """
                <div class="totale-row">
                  <label>Imponibile</label>
                  <div class="val">\(escape(fattura.imponibile)) <span class="divisa">\(fattura.divisa)</span></div>
                </div>
                """)
                \(fattura.imposta.isEmpty ? "" : """
                <div class="totale-row">
                  <label>IVA</label>
                  <div class="val">\(escape(fattura.imposta)) <span class="divisa">\(fattura.divisa)</span></div>
                </div>
                """)
                \(fattura.totale.isEmpty ? "" : """
                <div class="totale-finale">
                  <label>TOTALE</label>
                  <div class="val">\(escape(fattura.totale)) <span class="divisa">\(fattura.divisa)</span></div>
                </div>
                """)
              </div>
            </div>

            <!-- PAGAMENTO -->
            \(hasPagamento(fattura) ? """
            <hr class="sep">
            <div class="sezione-titolo">Dati Pagamento</div>
            <div class="pagamento-grid">
              \(fattura.modalitaPagamento.isEmpty ? "" : (
                "<div class=\"pagamento-item\">" +
                "<div class=\"pagamento-label\">Modalità</div>" +
                "<div class=\"pagamento-val\">\(escape(fattura.modalitaPagamento))</div>" +
                "</div>"
              ))
              \(fattura.dataScadenzaPagamento.isEmpty ? "" : (
                "<div class=\"pagamento-item\">" +
                "<div class=\"pagamento-label\">Scadenza</div>" +
                "<div class=\"pagamento-val\">\(escape(fattura.dataScadenzaPagamento))</div>" +
                "</div>"
              ))
              \(fattura.importoPagamento.isEmpty ? "" : (
                "<div class=\"pagamento-item\">" +
                "<div class=\"pagamento-label\">Importo</div>" +
                "<div class=\"pagamento-val\">\(escape(fattura.importoPagamento)) \(fattura.divisa)</div>" +
                "</div>"
              ))
              \(fattura.ibanAccredito.isEmpty ? "" : (
                "<div class=\"pagamento-item\">" +
                "<div class=\"pagamento-label\">IBAN</div>" +
                "<div class=\"pagamento-val iban\">\(escape(fattura.ibanAccredito))</div>" +
                "</div>"
              ))
            </div>
            """ : "")

          </div><!-- /body -->

          <div class="footer">
            Fattura Elettronica PA · Visualizzatore Quick Look ·
            <strong>FatturaPA-QLPlugin</strong>
          </div>

        </div><!-- /fattura-card -->
        </body>
        </html>
        """
    }

    // MARK: - Helpers

    private static func escape(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
         .replacingOccurrences(of: "<", with: "&lt;")
         .replacingOccurrences(of: ">", with: "&gt;")
         .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private static func pivaRow(_ label: String, _ val: String) -> String {
        guard !val.isEmpty else { return "" }
        return "<div class='soggetto-detail'>\(label): <span>\(escape(val))</span></div>"
    }

    private static func indirizzoRow(_ ind: String, _ cap: String, _ comune: String, _ prov: String) -> String {
        var parts: [String] = []
        if !ind.isEmpty { parts.append(ind) }
        var localita = ""
        if !cap.isEmpty { localita += cap + " " }
        if !comune.isEmpty { localita += comune }
        if !prov.isEmpty { localita += " (\(prov))" }
        if !localita.trimmingCharacters(in: .whitespaces).isEmpty { parts.append(localita) }
        guard !parts.isEmpty else { return "" }
        return "<div class='soggetto-detail'><span>\(escape(parts.joined(separator: ", ")))</span></div>"
    }

    private static func lineaRow(_ l: LineaFattura) -> String {
        let naturaHTML = l.natura.isEmpty ? "" : "<span class='natura-badge'>\(escape(l.natura))</span>"
        let scontoHTML = l.sconto.isEmpty ? "" : " <small style='color:#6B7280'>(sconto \(escape(l.sconto)))</small>"
        return """
        <tr>
          <td class="center">\(escape(l.numero))</td>
          <td><span class="desc-principale">\(escape(l.descrizione))</span>\(naturaHTML)\(scontoHTML)</td>
          <td class="center">\(escape(l.quantita))</td>
          <td class="center">\(escape(l.unitaMisura))</td>
          <td class="num">\(escape(l.prezzoUnitario))</td>
          <td class="center">\(escape(l.aliquotaIVA))</td>
          <td class="num">\(escape(l.prezzoTotale))</td>
        </tr>
        """
    }

    private static func riepilogoRow(_ r: AliquotaRiepilogo) -> String {
        return """
        <tr>
          <td class="center">\(escape(r.aliquotaIVA))</td>
          <td class="center">\(escape(r.natura))</td>
          <td class="num">\(escape(r.imponibile))</td>
          <td class="num">\(escape(r.imposta))</td>
        </tr>
        """
    }

    private static func hasPagamento(_ f: FatturaPAModel) -> Bool {
        return !f.modalitaPagamento.isEmpty || !f.dataScadenzaPagamento.isEmpty ||
               !f.importoPagamento.isEmpty || !f.ibanAccredito.isEmpty
    }

    private static func tipoDocumentoLabel(_ codice: String) -> String {
        let map: [String: String] = [
            "TD01": "Fattura", "TD02": "Acconto/Anticipo su fattura",
            "TD03": "Acconto/Anticipo su parcella", "TD04": "Nota di credito",
            "TD05": "Nota di debito", "TD06": "Parcella",
            "TD16": "Integrazione fattura rev. charge interno",
            "TD17": "Integrazione/autofattura servizi estero",
            "TD18": "Integrazione acquisto beni intraUE",
            "TD19": "Integrazione acquisto beni art.17 c.2 DPR 633/72",
            "TD20": "Autofattura per regolarizzazione",
            "TD21": "Autofattura per splafonamento",
            "TD22": "Estrazione beni deposito IVA",
            "TD23": "Estrazione beni deposito IVA con versamento imposta",
            "TD24": "Fattura differita art.21 c.4 lett.a",
            "TD25": "Fattura differita art.21 c.4 ter",
            "TD26": "Cessione beni ammortizzabili/passaggi interni",
            "TD27": "Fattura autoconsumo/cessioni gratuite senza rivalsa",
            "TD28": "Acquisti beni art.1 c.2 d.lgs.127/2015"
        ]
        return map[codice] ?? codice
    }
}
