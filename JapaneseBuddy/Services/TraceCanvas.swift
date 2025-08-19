import SwiftUI
import PencilKit
import UIKit

/// SwiftUI wrapper for `PKCanvasView` used for tracing practice.
struct TraceCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView?
    var pencilOnly: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        let view = PKCanvasView()
        view.drawingPolicy = pencilOnly ? .pencilOnly : .anyInput
        canvasView = view
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
        view.drawing.image(from: CGRect(origin: .zero, size: size), scale: 1)
    }

    /// Rough overlap score between user drawing and template mask.
    static func overlapScore(drawing: UIImage, template: UIImage) -> Double {
        guard let d = drawing.cgImage, let t = template.cgImage,
              d.width == t.width, d.height == t.height else { return 0 }
        let width = d.width, height = d.height
        let pixels = width * height
        let space = CGColorSpaceCreateDeviceGray()
        var dBuf = [UInt8](repeating: 255, count: pixels)
        var tBuf = [UInt8](repeating: 255, count: pixels)
        let dCtx = CGContext(data: &dBuf, width: width, height: height, bitsPerComponent: 8,
                             bytesPerRow: width, space: space, bitmapInfo: 0)!
        dCtx.draw(d, in: CGRect(x: 0, y: 0, width: width, height: height))
        let tCtx = CGContext(data: &tBuf, width: width, height: height, bitsPerComponent: 8,
                             bytesPerRow: width, space: space, bitmapInfo: 0)!
        tCtx.draw(t, in: CGRect(x: 0, y: 0, width: width, height: height))

        var match = 0, total = 0
        for i in 0..<pixels {
            if tBuf[i] < 200 { // template stroke
                total += 1
                if dBuf[i] < 200 { match += 1 }
            }
        }
        return total == 0 ? 0 : Double(match) / Double(total)
    }
}

