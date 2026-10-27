import CoreGraphics

/// "Mặc" dáng mẫu lên người thật: giữ HƯỚNG từng đoạn xương của dáng mẫu,
/// nhưng dùng vị trí và tỉ lệ cơ thể của người đang đứng trước máy.
/// Kết quả là hình bóng bám theo người mẫu, chỉ khác ở tư thế cần chỉnh.
enum PoseFitter {
    /// Cây xương: đi từ khớp gốc ra các chi.
    private static let tree: [(Joint, Joint)] = [
        (.root, .neck), (.neck, .nose),
        (.neck, .leftShoulder), (.neck, .rightShoulder),
        (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
        (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
        (.root, .leftHip), (.root, .rightHip),
        (.leftHip, .leftKnee), (.leftKnee, .leftAnkle),
        (.rightHip, .rightKnee), (.rightKnee, .rightAnkle),
    ]

    /// Các đoạn ít bị co ngắn do phối cảnh, dùng để ước lượng tỉ lệ người thật / dáng mẫu.
    private static let stableBones: Set<String> = ["root-neck", "neck-leftShoulder", "neck-rightShoulder", "root-leftHip", "root-rightHip"]

    static func fit(_ reference: Skeleton, to live: Skeleton, aspect: CGFloat) -> Skeleton? {
        let anchor: Joint
        if reference[.root] != nil, live[.root] != nil {
            anchor = .root
        } else if reference[.neck] != nil, live[.neck] != nil {
            anchor = .neck
        } else {
            return nil
        }
        guard let start = live[anchor], let scale = bodyScale(reference, live, aspect) else { return nil }

        var out: [Joint: CGPoint] = [anchor: start]
        var queue = [anchor]
        while !queue.isEmpty {
            let parent = queue.removeFirst()
            for (a, b) in tree {
                let child: Joint
                if a == parent { child = b } else if b == parent { child = a } else { continue }
                guard out[child] == nil, let rp = reference[parent], let rc = reference[child], let fp = out[parent] else { continue }

                let dx = (rc.x - rp.x) * aspect, dy = rc.y - rp.y
                let refLen = hypot(dx, dy)
                guard refLen > 0.0001 else { continue }
                let expected = refLen * scale
                var length = expected
                // Dùng độ dài thật của người mẫu, nhưng giới hạn ±25% để không bị méo
                // khi đoạn xương đang hướng về phía máy (trông ngắn đi).
                if let lp = live[parent], let lc = live[child] {
                    length = min(max(distance(lp, lc, aspect), expected * 0.8), expected * 1.25)
                }
                out[child] = CGPoint(x: fp.x + dx / refLen * length / aspect, y: fp.y + dy / refLen * length)
                queue.append(child)
            }
        }
        return Skeleton(out)
    }

    /// Trung vị tỉ lệ độ dài (người thật / dáng mẫu), ưu tiên các đoạn xương ổn định.
    private static func bodyScale(_ reference: Skeleton, _ live: Skeleton, _ aspect: CGFloat) -> CGFloat? {
        var stable: [CGFloat] = [], all: [CGFloat] = []
        for (a, b) in tree {
            guard let ra = reference[a], let rb = reference[b], let la = live[a], let lb = live[b] else { continue }
            let refLen = distance(ra, rb, aspect)
            guard refLen > 0.001 else { continue }
            let ratio = distance(la, lb, aspect) / refLen
            all.append(ratio)
            if stableBones.contains("\(a.rawValue)-\(b.rawValue)") { stable.append(ratio) }
        }
        let ratios = (stable.isEmpty ? all : stable).sorted()
        return ratios.isEmpty ? nil : ratios[ratios.count / 2]
    }

    private static func distance(_ a: CGPoint, _ b: CGPoint, _ aspect: CGFloat) -> CGFloat {
        hypot((b.x - a.x) * aspect, b.y - a.y)
    }
}
