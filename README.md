# FatturaPA Quick Look Plugin

Plugin **Quick Look** nativo per macOS che visualizza le **fatture elettroniche italiane** (formato XML FatturaPA / SDI) direttamente dal Finder premendo la **barra spaziatrice**.

---

## Funzionalità

- ✅ Visualizza cedente/prestatore e cessionario/committente
- ✅ Numero fattura, data e tipo documento (TD01, TD04, ecc.)
- ✅ Tabella dettaglio linee (descrizione, quantità, prezzo, IVA)
- ✅ Riepilogo aliquote IVA
- ✅ Totali (imponibile, IVA, importo totale)
- ✅ Dati di pagamento (modalità, scadenza, IBAN)
- ✅ Causale
- ✅ Supporto encoding UTF-8 e ISO-8859-1
- ✅ UI moderna con grafica professionale

---

## Requisiti

- **macOS 13.0** (Ventura) o superiore
- **Xcode 15** o superiore (disponibile gratis sull'App Store)
- Account sviluppatore Apple (anche gratuito per uso personale)

---

## Compilazione e installazione

### Passo 1 — Apri il progetto in Xcode

```bash
open FatturaPA-QLPlugin.xcodeproj
```

### Passo 2 — Seleziona il team di firma

1. Nel pannello di sinistra seleziona il progetto **FatturaPA-QLPlugin**
2. Vai su **Signing & Capabilities**
3. In **Team** seleziona il tuo account Apple ID  
   (se non appare, aggiungi l'account in Xcode → Settings → Accounts)

### Passo 3 — Compila

Premi **⌘B** (Build) oppure dal menu **Product → Build**

### Passo 4 — Trova il .appex compilato

Dal menu **Product → Show Build Folder in Finder**  
Naviga in:
```
Build/Products/Debug/FatturaPA-QLPlugin.appex
```

### Passo 5 — Installa il plugin

I plugin Quick Look per uso personale vanno copiati in:

```bash
~/Library/QuickLook/
```

Crea la cartella se non esiste:
```bash
mkdir -p ~/Library/QuickLook
```

Copia il plugin:
```bash
cp -R "Build/Products/Debug/FatturaPA-QLPlugin.appex" ~/Library/QuickLook/
```

### Passo 6 — Ricarica Quick Look

```bash
qlmanage -r
```

oppure fai logout/login dal Mac.

### Passo 7 — Test

```bash
qlmanage -p /percorso/alla/fattura.xml
```

---

## Associare l'estensione .xml alle fatture

Quick Look si attiva su tutti i file `.xml`. Se vuoi che il plugin si attivi **solo** sui file FatturaPA e non su tutti gli XML, puoi:

1. Assegnare l'estensione `.fatturapa` o `.p7m` alle tue fatture
2. Oppure lasciare invariato (il plugin riconosce automaticamente il formato FatturaPA)

### Nota sulle fatture firmate (.p7m)

Le fatture elettroniche spesso arrivano con estensione `.xml.p7m` (firma digitale CAdES). Per visualizzarle con Quick Look devi prima estrarre l'XML:

```bash
openssl smime -verify -noverify -in fattura.xml.p7m -inform DER -out fattura.xml
```

Oppure usa uno strumento come **Anteprima** o **QL-p7m** per le firme.

---

## Struttura del progetto

```
FatturaPA-QLPlugin/
├── FatturaPA-QLPlugin.xcodeproj/
│   └── project.pbxproj
└── FatturaPA-QLPlugin/
    ├── Sources/
    │   ├── PreviewProvider.swift   ← Entry point Quick Look
    │   ├── FatturaPAParser.swift   ← Parser XML FatturaPA
    │   ├── HTMLRenderer.swift      ← Rendering HTML grafico
    │   └── FatturaWebView.swift    ← WKWebView wrapper
    └── Resources/
        └── Info.plist              ← Metadati estensione
```

---

## Personalizzazione

### Modificare lo stile grafico
Apri `HTMLRenderer.swift` e modifica il CSS nella funzione `render(fattura:)`. Tutti i colori sono definiti come variabili CSS nella sezione `:root`.

### Supportare più campi XML
Apri `FatturaPAParser.swift` e aggiungi i campi mancanti nel modello `FatturaPAModel` e nei relativi `case` dell'`XMLParserDelegate`.

---

## Licenza

MIT — Libero uso personale e commerciale.

---

*Plugin sviluppato con Swift 5 · macOS 13+ · Formato FatturaPA v1.3*
