import UIKit
import PDFKit

struct PDFExportService {
    static func export(proposal: Proposal) -> Data? {
        let html = proposal.htmlContent.isEmpty
            ? TemplateEngine.render(
                templateContent: TemplateEngine.builtInTemplates().first?.htmlContent ?? "",
                proposal: proposal
            )
            : proposal.htmlContent
        return export(html: html)
    }

    static func export(html: String) -> Data? {
        let attributedString = htmlToAttributedString(html: html)
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let printRect = CGRect(x: margin, y: margin, width: pageWidth - 2 * margin, height: pageHeight - 2 * margin)

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let data = pdfRenderer.pdfData { context in
            context.beginPage()

            let textStorage = NSTextStorage(attributedString: attributedString)
            let layoutManager = NSLayoutManager()
            let container = NSTextContainer(size: printRect.size)
            container.lineBreakMode = .byWordWrapping
            layoutManager.addTextContainer(container)
            textStorage.addLayoutManager(layoutManager)

            var currentRange = NSRange(location: 0, length: attributedString.length)
            var yOffset: CGFloat = margin

            while currentRange.location < attributedString.length {
                let _ = layoutManager.glyphRange(forCharacterRange: currentRange, actualCharacterRange: nil)
                let rect = CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: pageHeight - margin - yOffset)
                let newRange = layoutManager.glyphRange(forBoundingRect: rect, in: container)

                if newRange.location >= currentRange.location + currentRange.length {
                    break
                }

                layoutManager.drawGlyphs(forGlyphRange: newRange, at: CGPoint(x: margin, y: yOffset))

                let endLocation = NSMaxRange(newRange)
                if endLocation >= attributedString.length {
                    break
                }

                currentRange = NSRange(location: endLocation, length: attributedString.length - endLocation)
                context.beginPage()
                yOffset = margin
            }
        }

        return data
    }

    static func exportAsync(html: String) async -> Data? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let data = export(html: html)
                continuation.resume(returning: data)
            }
        }
    }

    static func exportAsync(proposal: Proposal) async -> Data? {
        nonisolated(unsafe) let safeProposal = proposal
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let data = export(proposal: safeProposal)
                continuation.resume(returning: data)
            }
        }
    }

    static func export(proposal: Proposal, completion: @escaping (Data?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let data = export(proposal: proposal)
            DispatchQueue.main.async {
                completion(data)
            }
        }
    }

    private static func htmlToAttributedString(html: String) -> NSAttributedString {
        guard let data = html.data(using: .utf8) else {
            return NSAttributedString(string: html)
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let attributed = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributed
        }

        return NSAttributedString(string: html)
    }
}
