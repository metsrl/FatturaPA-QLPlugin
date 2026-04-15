import Cocoa
import Quartz

// ✅ NSViewController (classe base) + QLPreviewingController (protocollo)
class PreviewProvider: NSViewController, QLPreviewingController {

    // NSViewController gestisce già view; non serve override di loadView()

    // MARK: - QLPreviewingController

    func preparePreviewOfFile(at url: URL,
                              completionHandler handler: @escaping (Error?) -> Void) {

        guard let xmlData = try? Data(contentsOf: url),
              let xmlString = String(data: xmlData, encoding: .utf8)
                           ?? String(data: xmlData, encoding: .isoLatin1)
        else {
            handler(NSError(
                domain: "FatturaPA", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Impossibile leggere il file XML"]
            ))
            return
        }

        let parser  = FatturaPAParser(xmlString: xmlString)
        let fattura = parser.parse()
        let html    = HTMLRenderer.render(fattura: fattura)

        let webView = FatturaWebView(frame: view.bounds, html: html)
        webView.autoresizingMask = [.width, .height]   // ✅ NSView.AutoresizingMask
        view.addSubview(webView)

        handler(nil)
    }
}
