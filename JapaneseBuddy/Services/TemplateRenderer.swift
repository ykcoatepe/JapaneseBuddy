import UIKit

/// Renders kana glyphs into mask images for tracing.
enum TemplateRenderer {
    static func image(for glyph: String, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            let font = UIFont.systemFont(ofSize: size.width * 0.8)
            let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
            let textSize = glyph.size(withAttributes: attrs)
            let rect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            glyph.draw(in: rect, withAttributes: attrs)
        }
    }
}

