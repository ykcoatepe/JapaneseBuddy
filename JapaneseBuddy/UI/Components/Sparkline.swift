import SwiftUI

struct Sparkline: View {
    let values: [Double]   // 7 values, oldest -> newest, each 0…1
    let lineWidth: CGFloat = 3

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let n = max(1, values.count - 1)
            let pts: [CGPoint] = values.enumerated().map { (i, v) in
                let x = CGFloat(i) / CGFloat(n) * w
                let y = h - CGFloat(v) * h
                return CGPoint(x: x, y: y)
            }
            Path { p in
                guard let first = pts.first else { return }
                p.move(to: first)
                for pt in pts.dropFirst() { p.addLine(to: pt) }
            }
            .stroke(Color.accentColor,
                    style: StrokeStyle(lineWidth: lineWidth,
                                       lineCap: .round,
                                       lineJoin: .round))
        }
    }
}
