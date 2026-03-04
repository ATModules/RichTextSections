# RichTextSections

A lightweight Swift library for building rich `NSAttributedString` from composable sections — plain text, bold, italic, HTML, inline images, and tappable links — ready to drop into any `UITextView`.

## Features

- **Declarative builder API** — chain sections fluently, no boilerplate
- **Mixed content** — combine text, bold, italic, images, HTML, and links in a single attributed string
- **Per-section overrides** — customize font, size, and color on individual sections
- **Reusable configuration** — define `RTBuilderConfiguration` once, share across builders
- **Tappable links** — built-in handler support with or without a URL
- **Inline images** — embed icons and badges via `NSTextAttachment`, auto-aligned to text

## Requirements

- iOS 13.0+
- Swift 5.0+

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/yourname/RichTextSections.git", from: "1.0.0")
]
```

### Manual

Copy the `Sources` folder into your project.

## Quick Start

```swift
let result = RTBuilder()
    .font(.systemFont(ofSize: 14))
    .color(.white)
    .text("Hello ")
    .bold("World")
    .build()

textView.attributedText = result.attributedString
```

## Usage

### Sections

| Section | Description |
|---------|-------------|
| `.text` | Plain text with optional `font` and `color` override |
| `.bold` | Bold text with optional `size` and `color` override |
| `.italic` | Italic text with optional `size` and `color` override |
| `.image` | Inline image with optional `size` |
| `.html` | HTML string with optional inline styles |
| `.link` | Tappable link with optional URL and tap handler |
| `.spacing` | Blank line separator |

### Builder API

```swift
let result = RTBuilder()
    .font(.systemFont(ofSize: 14))       // base font
    .color(.white)                        // base color
    .alignment(.center)                   // paragraph alignment
    .lineSpacing(4)                       // line spacing
    .linkColor(.systemBlue)              // link color
    .linkUnderline(true)                 // underline links
    .text("Regular text")
    .bold("Bold text", size: 16, color: .yellow)
    .italic("Italic note", size: 12, color: .gray)
    .image(UIImage(systemName: "star.fill")!, size: CGSize(width: 16, height: 16))
    .html("<b>HTML</b> content", styles: [.size(14), .color("#FFFFFF")])
    .link("Tap me", url: someURL) { text, url in
        print("Tapped: \(text)")
    }
    .spacing()
    .build()

textView.attributedText = result.attributedString
```

### Reusable Configuration

Define a shared configuration to keep styling consistent across your app:

```swift
let config = RTBuilderConfiguration(
    font: .systemFont(ofSize: 14),
    color: .white,
    alignment: .center,
    lineSpacing: 4,
    linkColor: .systemBlue
)

let result1 = RTBuilder(config: config)
    .text("First message")
    .build()

let result2 = RTBuilder(config: config)
    .bold("Second message")
    .link("Learn more", url: helpURL) { _, _ in }
    .build()
```

You can still override individual properties per builder:

```swift
RTBuilder(config: config)
    .color(.gray)  // override just for this builder
    .text("Muted message")
    .build()
```

### Link Handling

`RTResult` provides `linkHandlers` and `linkTextMap` for use in your `UITextViewDelegate`:

```swift
class ViewController: UIViewController, UITextViewDelegate {
    
    private var linkResult: RTResult?
    
    func setupTextView() {
        let result = RTBuilder()
            .link("Terms", url: termsURL) { text, url in
                // handle tap
            }
            .link("Contact") { text, _ in
                // link without URL — custom action
            }
            .build()
        
        linkResult = result
        textView.attributedText = result.attributedString
        textView.delegate = self
    }
    
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        if let handler = linkResult?.linkHandlers[URL],
           let info = linkResult?.linkTextMap[URL] {
            handler(info.text, info.originalURL)
        }
        return false
    }
}
```

### HTML Styles

Apply inline CSS to `.html` sections:

```swift
.html("<b>Bold</b> and <i>italic</i>", styles: [
    .font(.systemFont(ofSize: 14)),
    .size(14),
    .color("#FF0000")
])
```

## Project Structure

```
Sources/
├── RTSection.swift                // Section enum
├── RTHTMLStyle.swift              // HTML inline styles
├── RTBuilder.swift                // Builder class
├── RTBuilderConfiguration.swift   // Reusable config
└── RTResult.swift                 // Build output
```

## License

MIT License. See [LICENSE](LICENSE) for details.
