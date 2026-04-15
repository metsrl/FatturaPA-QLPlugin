import Cocoa
import Quartz

class PreviewProvider: QLPreviewingController {

    override func loadView() {
        self.view = NSView()
    }

    // MARK: - QLPreviewingController

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        guard let xmlData = try? Data(contentsOf: url),
              let xmlString = String(data: xmlData, encoding: .utf8) ?? String(data: xmlData, encoding: .isoLatin1) else {
            handler(NSError(domain: "FatturaPA", code: 1, userInfo: [NSLocalizedDescriptionKey: "Impossibile leggere il file XML"]))
            return
        }

        let parser = FatturaPAParser(xmlString: xmlString)
        let fattura = parser.parse()
        let html = HTMLRenderer.render(fattura: fattura)

        let webView = FatturaWebView(frame: self.view.bounds, html: html)
        webView.autoresizingMask = [.width, .height]
        self.view.addSubview(webView)

        handler(nil)
    }
}
