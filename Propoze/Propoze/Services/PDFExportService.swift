import UIKit
import PDFKit
import WebKit

struct PDFExportService {
    static func export(proposal: Proposal, completion: @escaping (Data?) -> Void) {
        let html = proposal.htmlContent.isEmpty
            ? TemplateEngine.render(
                templateContent: TemplateEngine.builtInTemplates().first?.htmlContent ?? "",
                proposal: proposal
            )
            : proposal.htmlContent

        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 800, height: 1100))
        webView.loadHTMLString(html, baseURL: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let config = WKPDFConfiguration()
            config.rect = CGRect(x: 0, y: 0, width: 800, height: 1100)

            webView.createPDF(configuration: config) { result in
                switch result {
                case .success(let data):
                    completion(data)
                case .failure:
                    completion(nil)
                }
            }
        }
    }
}
