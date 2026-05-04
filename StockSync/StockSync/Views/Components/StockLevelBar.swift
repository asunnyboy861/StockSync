import SwiftUI

struct StockLevelBar: View {
    let available: Int
    let threshold: Int

    private var maxStock: Int {
        max(available, threshold * 3, 1)
    }

    private var fillRatio: CGFloat {
        CGFloat(available) / CGFloat(maxStock)
    }

    private var barColor: Color {
        if available == 0 { return .red }
        if available <= threshold { return .orange }
        return .green
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)

                Capsule()
                    .fill(barColor)
                    .frame(width: geometry.size.width * min(fillRatio, 1.0), height: 6)
            }
        }
        .frame(height: 6)
    }
}
