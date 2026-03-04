//
//  File.swift
//  RichTextSection
//
//  Created by Anh Tuấn Nguyễn on 4/3/26.
//

import Foundation
import UIKit

/// A composable section of rich text content.
public enum RTSection {
    /// Regular body text with optional font and color override.
    case text(String, font: UIFont? = nil, color: UIColor? = nil)
    /// Italic text with optional size and color override.
    case italic(String, size: CGFloat? = nil, color: UIColor? = nil)
    /// HTML formatted text with optional inline styles.
    case html(String, styles: [RTHTMLStyle])
    /// Tappable link with display text, URL, and optional tap handler.
    case link(String, url: URL?, handler: ((String, URL?) -> Void)?)
    /// A blank line separator.
    case spacing
}


public enum RTHTMLStyle {
    case font(UIFont)
    case size(Int)
    case color(String)
    
    var htmlTag: String {
        switch self {
        case .font(let font):
            return "font-family: '\(font.familyName)'"
        case .size(let size):
            return "font-size: \(size)px"
        case .color(let hexColor):
            return "color: \(hexColor)"
        }
    }
}
