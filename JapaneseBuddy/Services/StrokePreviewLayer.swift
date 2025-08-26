import SwiftUI
import UIKit
import UIKit.UIAccessibility

final class StrokePreviewLayer: CALayer {
    private var strokeLayers: [CAShapeLayer] = []
    private var textLayers: [CATextLayer] = []
    private var pausedTime: CFTimeInterval?

    func setup(strokes: [Stroke]) {
        strokeLayers.forEach { $0.removeFromSuperlayer() }
        textLayers.forEach { $0.removeFromSuperlayer() }
        strokeLayers.removeAll()
        textLayers.removeAll()
        for (i, stroke) in strokes.enumerated() {
            guard let first = stroke.points.first else { continue }
            let path = UIBezierPath()
            path.move(to: first)
            stroke.points.dropFirst().forEach { path.addLine(to: $0) }
            let layer = CAShapeLayer()
            layer.path = path.scaled(to: bounds).cgPath
            layer.strokeColor = UIColor.systemBlue.cgColor
            layer.lineWidth = 8
            layer.fillColor = UIColor.clear.cgColor
            layer.lineCap = .round
            layer.strokeEnd = 0
            addSublayer(layer)
            strokeLayers.append(layer)

            let text = CATextLayer()
            if let scalar = UnicodeScalar(0x2460 + i) {
                text.string = String(Character(scalar))
            } else {
                text.string = String(i + 1)
            }
            text.fontSize = 24
            text.alignmentMode = .center
            text.foregroundColor = UIColor.systemBlue.cgColor
            text.frame = CGRect(x: first.x * bounds.width - 12, y: first.y * bounds.height - 12, width: 24, height: 24)
            addSublayer(text)
            textLayers.append(text)
        }
        reset()
    }

    func play() {
        if let pausedTime {
            speed = 1
            timeOffset = 0
            beginTime = 0
            let delta = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            beginTime = delta
            self.pausedTime = nil
        } else {
            reset()
            let base = CACurrentMediaTime()
            var offset: CFTimeInterval = 0
            for layer in strokeLayers {
                let anim = CABasicAnimation(keyPath: "strokeEnd")
                anim.fromValue = 0
                anim.toValue = 1
                anim.duration = 0.6
                anim.beginTime = base + offset
                anim.fillMode = .forwards
                anim.isRemovedOnCompletion = false
                layer.add(anim, forKey: "draw")
                offset += 0.6
            }
        }
    }

    func pause() {
        pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0
        if let pausedTime { timeOffset = pausedTime }
    }

    func reset() {
        strokeLayers.forEach { $0.removeAllAnimations(); $0.strokeEnd = 0 }
        speed = 1
        timeOffset = 0
        beginTime = 0
        pausedTime = nil
    }
}

private extension UIBezierPath {
    func scaled(to rect: CGRect) -> UIBezierPath {
        var transform = CGAffineTransform(scaleX: rect.width, y: rect.height)
        let scaledCGPath = cgPath.copy(using: &transform) ?? cgPath
        return UIBezierPath(cgPath: scaledCGPath)
    }
}

struct StrokePreviewView: UIViewRepresentable {
    var strokes: [Stroke]
    @Binding var playing: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let layer = StrokePreviewLayer()
        view.layer.addSublayer(layer)
        context.coordinator.layer = layer
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let layer = context.coordinator.layer else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.frame = uiView.bounds
        if !context.coordinator.configured {
            layer.setup(strokes: strokes)
            context.coordinator.configured = true
        }
        CATransaction.commit()
        if UIAccessibility.isReduceMotionEnabled {
            layer.reset()
            context.coordinator.playing = false
        } else if playing != context.coordinator.playing {
            playing ? layer.play() : layer.pause()
            context.coordinator.playing = playing
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var layer: StrokePreviewLayer?
        var playing = false
        var configured = false
    }
}
