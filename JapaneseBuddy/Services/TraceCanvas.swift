import SwiftUI
import PencilKit
import UIKit
import CoreImage

/// SwiftUI wrapper for `PKCanvasView` used for tracing practice.
struct TraceCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView?
    var pencilOnly: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let view = PKCanvasView()
        view.drawingPolicy = pencilOnly ? .pencilOnly : .anyInput
        // Avoid mutating SwiftUI state synchronously during view creation.
        DispatchQueue.main.async {
            self.canvasView = view
        }
        return view
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawingPolicy = pencilOnly ? .pencilOnly : .anyInput
    }
}

/// Utilities for evaluating traced drawings.
enum TraceEvaluator {
    /// Renders the drawing into an image of given size.
    static func snapshot(_ view: PKCanvasView, size: CGSize) -> UIImage {
        view.drawing.image(from: CGRect(origin: .zero, size: size), scale: UIScreen.main.scale)
    }

    /// Rough overlap score between user drawing and template mask.
    static let context = CIContext()

    static func overlapScore(drawing: UIImage, template: UIImage) -> Double {
        guard let d = drawing.cgImage, let t = template.cgImage,
              d.width == t.width, d.height == t.height else { return 0 }
        let width = d.width, height = d.height
        let pixels = width * height
        var dBuf = [UInt8](repeating: 255, count: pixels)
        var tBuf = [UInt8](repeating: 255, count: pixels)
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.render(CIImage(cgImage: d), toBitmap: &dBuf, rowBytes: width, bounds: rect, format: .R8, colorSpace: nil)
        context.render(CIImage(cgImage: t), toBitmap: &tBuf, rowBytes: width, bounds: rect, format: .R8, colorSpace: nil)
        var match = 0, total = 0
        for i in 0..<pixels {
            if tBuf[i] < 200 {
                total += 1
                if dBuf[i] < 200 { match += 1 }
            }
        }
        return total == 0 ? 0 : Double(match) / Double(total)
    }
}

