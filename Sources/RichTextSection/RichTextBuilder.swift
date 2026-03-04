// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKit

/// A declarative builder for composing `NSAttributedString` from mixed-content sections.
///
/// Usage:
/// ```swift
/// let result = RTBuilder()
///     .font(.systemFont(ofSize: 14))
///     .color(.white)
///     .alignment(.center)
///     .text("Welcome back!")
///     .spacing()
///     .italic("Please read the terms below.")
///     .link("Terms of Service", url: termsURL) { text, url in
///         // handle tap
///     }
///     .build()
///
/// textView.attributedText = result.attributedString
/// ```
public final class RTBuilder {
    
    // MARK: - Configuration
    
    private var sections: [RTSection] = []
    private var baseFont: UIFont = .systemFont(ofSize: 14)
    private var italicFont: UIFont?
    private var textColor: UIColor = .white
    private var textAlignment: NSTextAlignment = .center
    private var textLineSpacing: CGFloat = 2
    private var linkTextColor: UIColor = .systemBlue
    private var linkUnderline: Bool = true
    
    // MARK: - Init
    
    public init() {}
    
    // MARK: - Global Style
    
    /// Sets the base font for `.text` sections.
    @discardableResult
    public func font(_ font: UIFont) -> Self {
        baseFont = font
        return self
    }
    
    /// Sets the font for `.italic` sections.
    /// If not set, the builder attempts to derive an italic variant from the base font.
    @discardableResult
    public func italic(font: UIFont) -> Self {
        italicFont = font
        return self
    }
    
    /// Sets the text color for all non-link sections.
    @discardableResult
    public func color(_ color: UIColor) -> Self {
        textColor = color
        return self
    }
    
    /// Sets the paragraph alignment. Default is `.center`.
    @discardableResult
    public func alignment(_ alignment: NSTextAlignment) -> Self {
        textAlignment = alignment
        return self
    }
    
    /// Sets the line spacing between lines within a section. Default is `2`.
    @discardableResult
    public func lineSpacing(_ spacing: CGFloat) -> Self {
        textLineSpacing = spacing
        return self
    }
    
    /// Sets the color for `.link` sections. Default is `.systemBlue`.
    @discardableResult
    public func linkColor(_ color: UIColor) -> Self {
        linkTextColor = color
        return self
    }
    
    /// Whether `.link` sections are underlined. Default is `true`.
    @discardableResult
    public func linkUnderline(_ enabled: Bool) -> Self {
        linkUnderline = enabled
        return self
    }
    
    // MARK: - Add Sections
    
    /// Appends a plain text section with optional font and color override.
    @discardableResult
    public func text(_ string: String, font: UIFont? = nil, color: UIColor? = nil) -> Self {
        sections.append(.text(string, font: font, color: color))
        return self
    }
    
    /// Appends an italic text section with optional size and color override.
    @discardableResult
    public func italic(_ string: String, size: CGFloat? = nil, color: UIColor? = nil) -> Self {
        sections.append(.italic(string, size: size, color: color))
        return self
    }
    
    /// Appends an HTML-rendered section with optional inline styles.
    @discardableResult
    public func html(_ string: String, styles: [RTHTMLStyle] = []) -> Self {
        sections.append(.html(string, styles: styles))
        return self
    }
    
    /// Appends a tappable link section.
    /// - Parameters:
    ///   - text: The display text.
    ///   - url: The URL to open. If `nil`, a placeholder is generated internally.
    ///   - handler: Called when the link is tapped.
    @discardableResult
    public func link(_ text: String,
                     url: URL? = nil,
                     handler: ((String, URL?) -> Void)? = nil) -> Self {
        sections.append(.link(text, url: url, handler: handler))
        return self
    }
    
    /// Appends a blank-line separator between sections.
    @discardableResult
    public func spacing() -> Self {
        sections.append(.spacing)
        return self
    }
    
    /// Appends a raw `RTSection` directly.
    @discardableResult
    public func section(_ section: RTSection) -> Self {
        sections.append(section)
        return self
    }
    
    /// Appends multiple `RTSection` values at once.
    @discardableResult
    public func sections(_ sections: [RTSection]) -> Self {
        self.sections.append(contentsOf: sections)
        return self
    }
    
    // MARK: - Build
    
    /// Composes the final `RTResult` from all appended sections and style configuration.
    public func build() -> RTResult {
        
        var linkHandlers: [URL: (String, URL?) -> Void] = [:]
        var linkTextMap: [URL: (text: String, originalURL: URL?)] = [:]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineSpacing = textLineSpacing
        
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let result = NSMutableAttributedString()
        
        for (index, section) in sections.enumerated() {
            switch section {
            case .text(let string, let font, let color):
                var attrs = baseAttributes
                if let font = font { attrs[.font] = font }
                if let color = color { attrs[.foregroundColor] = color }
                result.append(NSAttributedString(string: string, attributes: attrs))
                
            case .italic(let string, let size, let color):
                var attrs = baseAttributes
                let resolvedSize = size ?? baseFont.pointSize
                attrs[.font] = resolveItalicFont(withSize: resolvedSize)
                if let color = color { attrs[.foregroundColor] = color }
                result.append(NSAttributedString(string: string, attributes: attrs))
                
            case .html(let htmlString, let styles):
                if let attributed = convertHTML(htmlString, styles: styles) {
                    result.append(attributed)
                }
                
            case .link(let text, let url, let handler):
                let linkURL = url ?? URL(string: "rtbuilder://link/\(UUID().uuidString)")!
                
                var attrs = baseAttributes
                attrs[.foregroundColor] = linkTextColor
                attrs[.link] = linkURL
                if linkUnderline {
                    attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
                }
                result.append(NSAttributedString(string: text, attributes: attrs))
                
                if let handler = handler {
                    linkHandlers[linkURL] = handler
                }
                linkTextMap[linkURL] = (text: text, originalURL: url)
                
            case .spacing:
                result.append(NSAttributedString(string: "\n\n", attributes: baseAttributes))
            }
            
            // Newline between sections, skip around .spacing
            if index < sections.count - 1 {
                let needsNewline: Bool = {
                    if case .spacing = section { return false }
                    if case .spacing = sections[index + 1] { return false }
                    return true
                }()
                if needsNewline {
                    result.append(NSAttributedString(string: "\n", attributes: baseAttributes))
                }
            }
        }
        
        return RTResult(
            attributedString: result,
            linkHandlers: linkHandlers,
            linkTextMap: linkTextMap
        )
    }
    
}

// MARK: - Private Helpers
private extension RTBuilder {
    
    func resolveItalicFont(withSize size: CGFloat? = nil) -> UIFont {
        let targetSize = size ?? baseFont.pointSize
        if let explicit = italicFont {
            return explicit.withSize(targetSize)
        }
        let descriptor = baseFont.fontDescriptor
        if let italicDescriptor = descriptor.withSymbolicTraits(.traitItalic) {
            return UIFont(descriptor: italicDescriptor, size: targetSize)
        }
        return baseFont.withSize(targetSize)
    }
    
    func convertHTML(_ html: String, styles: [RTHTMLStyle]) -> NSAttributedString? {
        let trimmed = html.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        let wrapped: String
        if styles.isEmpty {
            wrapped = html
        } else {
            let inlineCSS = styles.map { $0.htmlTag }.joined(separator: ";")
            wrapped = "<span style=\"\(inlineCSS)\">\(html)</span>"
        }
        
        guard let data = wrapped.data(using: .utf8) else { return nil }
        
        return try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
    }
}
