import SwiftUI

/// Chuyển toạ độ chuẩn hoá của ảnh camera sang điểm trên màn hình,
/// theo đúng cách preview hiển thị ảnh (aspect fill: phủ kín, cắt bớt hai bên).
struct FrameMapper {
    private let rect: CGRect

    init(size: CGSize, imageAspect: CGFloat) {
        let viewAspect = size.width / max(size.height, 1)
        var w = size.width, h = size.height
        if imageAspect > viewAspect { w = h * imageAspect } else { h = w / imageAspect }
        rect = CGRect(x: (size.width - w) / 2, y: (size.height - h) / 2, width: w, height: h)
    }

    func point(_ p: CGPoint) -> CGPoint {
        CGPoint(x: rect.minX + p.x * rect.width, y: rect.minY + p.y * rect.height)
    }

    var height: CGFloat { rect.height }
    var bottom: CGFloat { rect.maxY }
}

enum SilhouetteStyle {
    /// Tô đặc (ảnh minh hoạ trong thư viện).
    case solid
    /// Tô mờ + viền rõ (dáng mẫu trên camera).
    case ghost
    /// Chỉ viền nét đứt (vị trí bố cục gợi ý).
    case outline
}

enum SkeletonRenderer {
    /// Các đoạn chi: (khớp đầu, khớp cuối, bán kính đầu, bán kính cuối) theo tỉ lệ độ dài thân.
    private static let limbs: [(Joint, Joint, CGFloat, CGFloat)] = [
        (.neck, .nose, 0.08, 0.08),
        (.leftShoulder, .leftElbow, 0.085, 0.065), (.leftElbow, .leftWrist, 0.065, 0.045),
        (.rightShoulder, .rightElbow, 0.085, 0.065), (.rightElbow, .rightWrist, 0.065, 0.045),
        (.leftHip, .leftKnee, 0.12, 0.08), (.leftKnee, .leftAnkle, 0.08, 0.05),
        (.rightHip, .rightKnee, 0.12, 0.08), (.rightKnee, .rightAnkle, 0.08, 0.05),
    ]

    /// Kích thước cơ thể trên màn hình (≈ độ dài thân), dùng để tính độ dày nét.
    private static func bodyScale(_ s: Skeleton, _ mapper: FrameMapper) -> CGFloat {
        func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat { hypot(a.x - b.x, a.y - b.y) }
        if let n = s[.neck], let r = s[.root] {
            return dist(mapper.point(n), mapper.point(r))
        }
        if let a = s[.leftShoulder], let b = s[.rightShoulder] {
            return dist(mapper.point(a), mapper.point(b)) * 1.5
        }
        return mapper.height * 0.2
    }

    /// Vẽ hình bóng (silhouette) có khối của một người.
    static func drawSilhouette(_ s: Skeleton, in context: GraphicsContext, mapper: FrameMapper,
                               color: Color, style: SilhouetteStyle = .solid) {
        let path = bodyPath(s, mapper: mapper)
        switch style {
        case .solid:
            context.fill(path, with: .color(color))
        case .ghost:
            context.fill(path, with: .color(color.opacity(0.35)))
            context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
        case .outline:
            context.stroke(path, with: .color(color.opacity(0.8)),
                           style: StrokeStyle(lineWidth: 1.5, lineJoin: .round, dash: [6, 5]))
        }
    }

    /// Ghép thân, đầu, tay chân (thon dần) thành một khối liền để có đường viền ngoài.
    private static func bodyPath(_ s: Skeleton, mapper: FrameMapper) -> Path {
        let scale = bodyScale(s, mapper)
        let p: (Joint) -> CGPoint? = { s[$0].map(mapper.point) }
        var pieces: [Path] = []

        // Thân: nới hông ra ngoài một chút để eo-hông có hình dáng tự nhiên.
        if let ls = p(.leftShoulder), let rs = p(.rightShoulder) {
            var torso = Path()
            if let lh = p(.leftHip), let rh = p(.rightHip) {
                let dx = lh.x - rh.x, dy = lh.y - rh.y
                let len = max(hypot(dx, dy), 0.001)
                let off = scale * 0.07
                let lhOut = CGPoint(x: lh.x + dx / len * off, y: lh.y + dy / len * off)
                let rhOut = CGPoint(x: rh.x - dx / len * off, y: rh.y - dy / len * off)
                torso.addLines([ls, rs, rhOut, lhOut])
            } else {
                // Dáng nửa người: kéo thân xuống tới mép dưới khung.
                torso.addLines([ls, rs, CGPoint(x: rs.x, y: mapper.bottom), CGPoint(x: ls.x, y: mapper.bottom)])
            }
            torso.closeSubpath()
            pieces.append(torso)
            pieces.append(circle(ls, scale * 0.09))
            pieces.append(circle(rs, scale * 0.09))
        }

        for (a, b, ra, rb) in limbs {
            guard let pa = p(a), let pb = p(b) else { continue }
            pieces.append(contentsOf: taperedLimb(pa, pb, ra * scale, rb * scale))
        }

        // Bàn tay và đầu
        for wrist in [Joint.leftWrist, .rightWrist] {
            if let w = p(wrist) { pieces.append(circle(w, scale * 0.06)) }
        }
        if let nose = p(.nose) {
            let r = scale * 0.25
            pieces.append(Path(ellipseIn: CGRect(x: nose.x - r, y: nose.y - r * 1.2, width: r * 2, height: r * 2.3)))
        }

        guard var body = pieces.first else { return Path() }
        for piece in pieces.dropFirst() { body = body.union(piece) }
        return body
    }

    /// Đoạn chi thon dần: hình thang nối hai hình tròn bán kính khác nhau.
    private static func taperedLimb(_ a: CGPoint, _ b: CGPoint, _ ra: CGFloat, _ rb: CGFloat) -> [Path] {
        let dx = b.x - a.x, dy = b.y - a.y
        let len = max(hypot(dx, dy), 0.001)
        let nx = -dy / len, ny = dx / len
        var quad = Path()
        quad.addLines([
            CGPoint(x: a.x + nx * ra, y: a.y + ny * ra),
            CGPoint(x: b.x + nx * rb, y: b.y + ny * rb),
            CGPoint(x: b.x - nx * rb, y: b.y - ny * rb),
            CGPoint(x: a.x - nx * ra, y: a.y - ny * ra),
        ])
        quad.closeSubpath()
        return [quad, circle(a, ra), circle(b, rb)]
    }

    private static func circle(_ c: CGPoint, _ r: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2))
    }

    /// Vẽ khung xương người thật đang được AI nhận diện.
    static func drawLive(_ s: Skeleton, in context: GraphicsContext, mapper: FrameMapper, color: Color, highlight: Limb?) {
        let p: (Joint) -> CGPoint? = { s[$0].map(mapper.point) }

        var bones = Path()
        for (a, b) in Skeleton.bones {
            guard let pa = p(a), let pb = p(b) else { continue }
            bones.move(to: pa)
            bones.addLine(to: pb)
        }
        context.stroke(bones, with: .color(color), style: StrokeStyle(lineWidth: 3, lineCap: .round))

        if let h = highlight, let a = p(h.from), let b = p(h.to) {
            var path = Path()
            path.move(to: a)
            path.addLine(to: b)
            context.stroke(path, with: .color(.red), style: StrokeStyle(lineWidth: 8, lineCap: .round))
        }

        for joint in s.points.keys {
            guard let pt = p(joint) else { continue }
            context.fill(Path(ellipseIn: CGRect(x: pt.x - 4, y: pt.y - 4, width: 8, height: 8)), with: .color(.white))
        }
    }
}

/// Ảnh minh hoạ dáng (dùng cho thẻ trong thư viện và trang chi tiết).
struct PoseFigureView: View {
    let pose: Pose

    var body: some View {
        ZStack {
            LinearGradient(colors: pose.category.colors, startPoint: .top, endPoint: .bottom)
            Canvas { context, size in
                let mapper = FrameMapper(size: size, imageAspect: 9.0 / 16.0)
                for body in pose.bodies {
                    SkeletonRenderer.drawSilhouette(body, in: context, mapper: mapper, color: .white.opacity(0.92))
                }
            }
        }
        .aspectRatio(9.0 / 16.0, contentMode: .fit)
    }
}

/// Lớp phủ trên camera: hình bóng dáng mẫu và khung xương người thật.
/// Khi có `fitted`, dáng mẫu bám theo người; dáng gốc chỉ còn là viền nét đứt gợi ý bố cục.
struct PoseOverlay: View {
    let reference: [Skeleton]
    let fitted: [Skeleton]
    let live: [Skeleton]
    let aspect: CGFloat
    let opacity: Double
    let isPerfect: Bool
    let focus: MatchResult.Focus?

    var body: some View {
        Canvas { context, size in
            let mapper = FrameMapper(size: size, imageAspect: aspect)

            // Vẽ dáng mẫu vào một layer riêng để độ mờ đều, không bị đậm ở chỗ chồng nét.
            var refContext = context
            refContext.opacity = opacity
            refContext.addFilter(.shadow(color: .black.opacity(0.5), radius: 4))
            let color: Color = isPerfect ? .green : .white
            refContext.drawLayer { layer in
                if fitted.isEmpty {
                    for body in reference {
                        SkeletonRenderer.drawSilhouette(body, in: layer, mapper: mapper, color: color, style: .ghost)
                    }
                } else {
                    for body in reference {
                        SkeletonRenderer.drawSilhouette(body, in: layer, mapper: mapper, color: .white, style: .outline)
                    }
                    for body in fitted {
                        SkeletonRenderer.drawSilhouette(body, in: layer, mapper: mapper, color: color, style: .ghost)
                    }
                }
            }

            for (i, body) in live.enumerated() {
                SkeletonRenderer.drawLive(
                    body, in: context, mapper: mapper,
                    color: isPerfect ? .green : .yellow,
                    highlight: focus?.body == i ? focus?.limb : nil
                )
            }
        }
        .allowsHitTesting(false)
    }
}

/// Lưới 1/3 (Rule of Thirds).
struct GridOverlay: View {
    var body: some View {
        Canvas { context, size in
            var path = Path()
            for i in 1...2 {
                let x = size.width * CGFloat(i) / 3
                let y = size.height * CGFloat(i) / 3
                path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: size.height))
                path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: size.width, y: y))
            }
            context.stroke(path, with: .color(.white.opacity(0.4)), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

/// Thước cân bằng: vạch giữa luôn song song với mặt đất thật, xanh lá khi máy đã thẳng.
struct HorizonLevelView: View {
    let roll: Double

    var body: some View {
        let isLevel = abs(roll) < 1
        ZStack {
            HStack(spacing: 150) {
                Capsule().frame(width: 24, height: 2)
                Capsule().frame(width: 24, height: 2)
            }
            .foregroundStyle(.white.opacity(0.6))

            Capsule()
                .fill(isLevel ? Color.green : Color.yellow)
                .frame(width: 130, height: 2)
                .rotationEffect(.degrees(-roll))

            Text(isLevel ? "Thẳng" : "\(Int(roll.rounded()))°")
                .font(.caption2.bold())
                .foregroundStyle(isLevel ? Color.green : Color.yellow)
                .offset(y: 16)
        }
        .animation(.easeOut(duration: 0.1), value: roll)
        .allowsHitTesting(false)
    }
}
