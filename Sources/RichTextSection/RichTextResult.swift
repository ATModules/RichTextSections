//
//  File.swift
//  RichTextSection
//
//  Created by Anh Tuấn Nguyễn on 4/3/26.
//

import Foundation
import Foundation

/// The output of `RTBuilder.build()`.
public struct RTResult {
    /// The composed attributed string, ready to assign to `UITextView.attributedText`.
    public let attributedString: NSAttributedString
    
    /// Link tap handlers keyed by the URL assigned to each `.link` section.
    /// Use these in your `UITextViewDelegate` to handle taps.
    public let linkHandlers: [URL: (_ text: String, _ url: URL?) -> Void]
    
    /// Maps each internal link URL to its display text and original URL.
    /// Useful when a `.link` section has `url: nil` — the builder generates
    /// a placeholder URL internally, and this map lets you recover the original values.
    public let linkTextMap: [URL: (text: String, originalURL: URL?)]
}
