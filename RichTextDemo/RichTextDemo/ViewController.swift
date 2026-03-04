//
//  ViewController.swift
//  RichTextDemo
//
//  Created by Anh Tuấn Nguyễn on 4/3/26.
//

import UIKit
import RichTextSection

class ViewController: UIViewController {
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        tv.textContainer.lineFragmentPadding = 0
        tv.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private var linkResult: RTResult?
    
    private let config = RTBuilderConfiguration(
        font: .systemFont(ofSize: 14),
        color: .white,
        alignment: .center,
        lineSpacing: 4,
        linkColor: .systemBlue
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        setupTextView()
        buildDemo()
    }
    
    private func setupTextView() {
        view.addSubview(textView)
        textView.delegate = self
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func buildDemo() {
        let result = RTBuilder(config: config)
            // Header with icon
            .image(UIImage(systemName: "star.fill")!, size: CGSize(width: 20, height: 20))
            .text(" ")
            .bold("Welcome to RichTextSections", size: 18, color: .systemYellow)
            .spacing()
            
            // Normal text
            .text("Build ")
            .bold("rich attributed text")
            .text(" from composable sections with a clean, declarative API.")
            .spacing()
            
            // Italic note
            .italic("This library supports text, bold, italic, image, HTML, and tappable links.", size: 12, color: .lightGray)
            .spacing()
            
            // Custom styled text
            .text("Status: ", font: .boldSystemFont(ofSize: 14))
            .text("Ready to use", color: .systemGreen)
            .spacing()
            
            // HTML content
            .html("Render <b>bold</b>, <i>italic</i>, and <u>underline</u> from raw HTML.",
                   styles: [.size(14), .color("#FFFFFF")])
            .spacing()
            
            // Links
            .text("Check out the ")
            .link("GitHub Repository", url: URL(string: "https://github.com/ATiOSModule/RichTextSections")) { text, url in
                print("Tapped: \(text) → \(url?.absoluteString ?? "nil")")
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
            .text(" and ")
            .link("Documentation", url: URL(string: "https://example.com/docs")) { text, url in
                print("Tapped: \(text) → \(url?.absoluteString ?? "nil")")
            }
            .spacing()
            
            // Link without URL
            .link("Send Feedback") { text, _ in
                print("Tapped: \(text) — no URL, handle custom action")
            }
            .build()
        
        linkResult = result
        textView.attributedText = result.attributedString
    }
}

// MARK: - UITextViewDelegate

extension ViewController: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        guard let result = linkResult else { return false }
        
        if let handler = result.linkHandlers[URL],
           let info = result.linkTextMap[URL] {
            handler(info.text, info.originalURL)
        }
        
        return false
    }
}
