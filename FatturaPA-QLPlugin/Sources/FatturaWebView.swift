import Cocoa
import WebKit

class FatturaWebView: WKWebView {

    init(frame: NSRect, html: String) {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = false
        super.init(frame: frame, configuration: config)
        self.loadHTMLString(html, baseURL: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
