import Foundation

struct TemplateEngine {
    static func render(templateContent: String, proposal: Proposal) -> String {
        var html = templateContent

        html = html.replacingOccurrences(of: "{{CLIENT_NAME}}", with: proposal.clientName)
        html = html.replacingOccurrences(of: "{{CLIENT_COMPANY}}", with: proposal.clientCompany)
        html = html.replacingOccurrences(of: "{{CLIENT_EMAIL}}", with: proposal.clientEmail)
        html = html.replacingOccurrences(of: "{{DATE}}", with: proposal.createdAt.formatted())
        html = html.replacingOccurrences(of: "{{PROPOSAL_TITLE}}", with: proposal.title)

        let pricingHTML = renderPricingTable(proposal.pricingItems)
        html = html.replacingOccurrences(of: "{{PRICING_TABLE}}", with: pricingHTML)

        return html
    }

    static func builtInTemplates() -> [ProposalTemplate] {
        [
            ProposalTemplate(name: "Consulting Proposal", category: .consulting, htmlContent: consultingTemplate, isBuiltIn: true),
            ProposalTemplate(name: "Design Proposal", category: .design, htmlContent: designTemplate, isBuiltIn: true),
            ProposalTemplate(name: "Development Proposal", category: .development, htmlContent: developmentTemplate, isBuiltIn: true),
        ]
    }

    private static func renderPricingTable(_ items: [PricingItem]) -> String {
        guard !items.isEmpty else { return "" }

        var rows = ""
        for item in items {
            let total = item.quantity * item.unitPrice
            rows += """
            <tr>
                <td>\(item.name)</td>
                <td>\(item.itemDescription)</td>
                <td>\(Int(item.quantity))</td>
                <td>\(item.unitPrice.currencyString)</td>
                <td>\(total.currencyString)</td>
            </tr>
            """
        }

        let total = items.reduce(0.0) { $0 + $1.quantity * $1.unitPrice }

        return """
        <table style="width:100%; border-collapse:collapse; margin:20px 0;">
            <thead>
                <tr style="background:#2563EB; color:white;">
                    <th style="padding:10px; text-align:left;">Item</th>
                    <th style="padding:10px; text-align:left;">Description</th>
                    <th style="padding:10px; text-align:center;">Qty</th>
                    <th style="padding:10px; text-align:right;">Price</th>
                    <th style="padding:10px; text-align:right;">Total</th>
                </tr>
            </thead>
            <tbody>\(rows)</tbody>
            <tfoot>
                <tr style="font-weight:bold; background:#f5f5f5;">
                    <td colspan="4" style="padding:10px; text-align:right;">Total</td>
                    <td style="padding:10px; text-align:right;">\(total.currencyString)</td>
                </tr>
            </tfoot>
        </table>
        """
    }

    private static var consultingTemplate: String {
        """
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
        <body style="font-family:-apple-system,sans-serif; color:#1a1a1a; padding:40px 24px; line-height:1.6; max-width:800px; margin:0 auto;">
        <div style="text-align:center; margin-bottom:40px;">
        <h1 style="color:#2563EB; margin:0;">{{PROPOSAL_TITLE}}</h1>
        <p style="color:#64748B; font-size:14px;">Prepared for {{CLIENT_NAME}} | {{DATE}}</p>
        </div>
        <h2 style="color:#2563EB;">Executive Summary</h2>
        <p>Thank you for the opportunity to present this proposal. We understand your challenges and are confident our approach will deliver measurable results.</p>
        <h2 style="color:#2563EB;">Scope of Work</h2>
        <ul><li>Discovery and assessment</li><li>Strategy development</li><li>Implementation planning</li><li>Progress review and optimization</li></ul>
        <h2 style="color:#2563EB;">Investment</h2>
        {{PRICING_TABLE}}
        <h2 style="color:#2563EB;">Next Steps</h2>
        <p>We look forward to partnering with {{CLIENT_COMPANY}}. Upon agreement, we will begin with a kickoff session within 5 business days.</p>
        </body></html>
        """
    }

    private static var designTemplate: String {
        """
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
        <body style="font-family:-apple-system,sans-serif; color:#1a1a1a; padding:40px 24px; line-height:1.6; max-width:800px; margin:0 auto;">
        <div style="text-align:center; margin-bottom:40px;">
        <h1 style="color:#2563EB; margin:0;">{{PROPOSAL_TITLE}}</h1>
        <p style="color:#64748B; font-size:14px;">Prepared for {{CLIENT_NAME}} | {{DATE}}</p>
        </div>
        <h2 style="color:#2563EB;">Project Overview</h2>
        <p>We are excited to bring your vision to life. This proposal outlines our design approach, deliverables, and timeline.</p>
        <h2 style="color:#2563EB;">Design Deliverables</h2>
        <ul><li>Brand identity and style guide</li><li>UI/UX wireframes and prototypes</li><li>High-fidelity mockups</li><li>Design assets and source files</li></ul>
        <h2 style="color:#2563EB;">Investment</h2>
        {{PRICING_TABLE}}
        <h2 style="color:#2563EB;">Timeline</h2>
        <p>Estimated project duration: 4-6 weeks from kickoff.</p>
        </body></html>
        """
    }

    private static var developmentTemplate: String {
        """
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"></head>
        <body style="font-family:-apple-system,sans-serif; color:#1a1a1a; padding:40px 24px; line-height:1.6; max-width:800px; margin:0 auto;">
        <div style="text-align:center; margin-bottom:40px;">
        <h1 style="color:#2563EB; margin:0;">{{PROPOSAL_TITLE}}</h1>
        <p style="color:#64748B; font-size:14px;">Prepared for {{CLIENT_NAME}} | {{DATE}}</p>
        </div>
        <h2 style="color:#2563EB;">Technical Approach</h2>
        <p>Our development team will build a robust, scalable solution using modern technologies and best practices.</p>
        <h2 style="color:#2563EB;">Development Phases</h2>
        <ul><li>Requirements analysis and architecture</li><li>Core development and integration</li><li>Testing and quality assurance</li><li>Deployment and launch support</li></ul>
        <h2 style="color:#2563EB;">Investment</h2>
        {{PRICING_TABLE}}
        <h2 style="color:#2563EB;">Why Choose Us</h2>
        <p>We deliver clean, maintainable code with comprehensive documentation and ongoing support.</p>
        </body></html>
        """
    }
}
