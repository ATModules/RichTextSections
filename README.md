# RichTextSections

A lightweight Swift library for building rich `NSAttributedString` from composable sections and inline items — ready to drop into any `UITextView`.

## Features

- **Section-based layout** — each section renders as a single line, items flow inline
- **Rich inline items** — text, bold, italic, strikethrough, images, HTML, and tappable links
- **Per-item overrides** — customize font, size, and color on individual items
- **Per-section paragraph style** — alignment, indentation, and line spacing per section
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
    .section {
        $0.text("Hello ")
          .bold("World")
    }
    .build()

textView.attributedText = result.attributedString
```

## Usage

### Core Concept

A **section** is a single line. Each section contains one or more **items** that render inline. Sections are separated by automatic line breaks:

```swift
RTBuilder()
    .section {                        // Line 1: ⭐ Welcome
        $0.image(starIcon)
          .text(" ")
          .bold("Welcome")
    }
    .section {                        // Line 2: Visit the Docs now.
        $0.text("Visit the ")
          .link("Docs", url: docsURL)
          .text(" now.")
    }
    .spacing()                        // Blank line
    .section {                        // Line 3: Last updated: 2026
        $0.italic("Last updated: 2026", size: 12, color: .gray)
    }
    .build()
```

### Items

| Item | Description |
|------|-------------|
| `.text` | Plain text with optional `font` and `color` override |
| `.bold` | Bold text with optional `size` and `color` override |
| `.italic` | Italic text with optional `size` and `color` override |
| `.strikethrough` | Strikethrough text with optional `size` and `color` override |
| `.image` | Inline image with optional `size` |
| `.html` | HTML string with optional inline styles |
| `.link` | Tappable link with optional URL and tap handler |

### Strikethrough

Useful for showing old prices, deprecated info, or corrections:

```swift
.section {
    $0.text("Price: ")
      .strikethrough("$9.99", color: .systemRed)
      .text(" ")
      .bold("$4.99", color: .systemGreen)
      .text(" (50% off!)")
}
```

### Section Style

Each section can have its own paragraph style via `RTSectionStyle`. When not provided, the builder's global alignment and line spacing are used:

```swift
// Left-aligned with indent
.section(style: RTSectionStyle(alignment: .left, indent: 24)) {
    $0.bold("Note: ", color: .systemOrange)
      .text("This section is indented 24pt from the left.")
}

// Right-aligned signature
.section(style: RTSectionStyle(alignment: .right)) {
    $0.italic("— The Author", size: 12, color: .gray)
}

// First-line indent for paragraph style
.section(style: RTSectionStyle(alignment: .left, firstLineIndent: 32)) {
    $0.text("The first line starts further in while subsequent lines wrap normally.")
}
```

Available properties on `RTSectionStyle`:

| Property | Description | Default |
|----------|-------------|---------|
| `alignment` | Text alignment override | Global |
| `indent` | Head indent (left margin) | `0` |
| `firstLineIndent` | First-line head indent | `0` |
| `tailIndent` | Tail indent (negative = inset from right) | `0` |
| `lineSpacing` | Line spacing override | Global |

### Global Style

```swift
RTBuilder()
    .font(.systemFont(ofSize: 14))   // base font
    .color(.white)                    // base text color
    .alignment(.center)              // paragraph alignment
    .lineSpacing(4)                  // line spacing
    .linkColor(.systemBlue)          // link color
    .linkUnderline(true)             // underline links
```

### Reusable Configuration

Define a shared configuration to keep styling consistent:

```swift
let config = RTBuilderConfiguration(
    font: .systemFont(ofSize: 14),
    color: .white,
    alignment: .center,
    lineSpacing: 4,
    linkColor: .systemBlue
)

// Reuse across builders
let message1 = RTBuilder(config: config)
    .section { $0.text("First message") }
    .build()

let message2 = RTBuilder(config: config)
    .section { $0.bold("Second message") }
    .build()
```

Override per builder when needed:

```swift
RTBuilder(config: config)
    .color(.gray)
    .section { $0.text("Muted message") }
    .build()
```

### Link Handling

`RTResult` provides `linkHandlers` and `linkTextMap` for use in `UITextViewDelegate`:

```swift
class ViewController: UIViewController, UITextViewDelegate {
    
    private var linkResult: RTResult?
    
    func setup() {
        let result = RTBuilder()
            .section {
                $0.text("Read the ")
                  .link("Terms", url: termsURL) { text, url in
                      // handle tap
                  }
            }
            .section {
                $0.link("Contact") { text, _ in
                    // link without URL — custom action
                }
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

Apply inline CSS to `.html` items:

```swift
.section {
    $0.html("<b>Bold</b> and <i>italic</i>", styles: [
        .font(.systemFont(ofSize: 14)),
        .size(14),
        .color("#FF0000")
    ])
}
```

## Project Structure

```
Sources/
├── Enum/
│   ├── RTSection.swift              // Section enum (items or spacing)
│   ├── RTItem.swift                 // Inline content unit
│   └── RTHTMLStyle.swift            // HTML inline styles
├── RTBuilder.swift                  // Main builder class
├── RTBuilderConfiguration.swift     // Reusable style config
├── RTItemBuilder.swift              // Builder for items within a section
├── RTResult.swift                   // Build output
└── RTSectionStyle.swift             // Per-section paragraph style

Demo/
└── ViewController.swift             // Usage example
```

## License

MIT License. See [LICENSE](LICENSE) for details.
