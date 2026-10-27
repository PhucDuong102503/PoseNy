import CoreGraphics
import Foundation

/// Một đoạn chi được dùng để so khớp. Tên gọi theo điểm cuối của đoạn (khuỷu tay, bàn tay...)
/// vì hướng dẫn luôn là "di chuyển điểm cuối".
struct Limb: Hashable {
    enum Kind { case arm, leg, head, torso }

    let from: Joint
    let to: Joint
    let name: String
    let weight: Double
    let kind: Kind

    static let all: [Limb] = [
        Limb(from: .leftShoulder, to: .leftElbow, name: "khuỷu tay trái", weight: 1, kind: .arm),
        Limb(from: .leftElbow, to: .leftWrist, name: "bàn tay trái", weight: 1, kind: .arm),
        Limb(from: .rightShoulder, to: .rightElbow, name: "khuỷu tay phải", weight: 1, kind: .arm),
        Limb(from: .rightElbow, to: .rightWrist, name: "bàn tay phải", weight: 1, kind: .arm),
        Limb(from: .leftHip, to: .leftKnee, name: "đầu gối trái", weight: 0.8, kind: .leg),
        Limb(from: .leftKnee, to: .leftAnkle, name: "bàn chân trái", weight: 0.8, kind: .leg),
        Limb(from: .rightHip, to: .rightKnee, name: "đầu gối phải", weight: 0.8, kind: .leg),
        Limb(from: .rightKnee, to: .rightAnkle, name: "bàn chân phải", weight: 0.8, kind: .leg),
        Limb(from: .neck, to: .nose, name: "đầu", weight: 0.6, kind: .head),
        Limb(from: .root, to: .neck, name: "thân người", weight: 0.8, kind: .torso),
    ]
}

struct MatchResult {
    struct Focus {
        let body: Int
        let limb: Limb
    }

    /// 0...100
    var score: Int
    var feedback: String
    /// Các người được nhận diện, xếp theo cùng thứ tự với dáng mẫu (trái → phải).
    var matchedBodies: [Skeleton]
    /// Đoạn chi đang sai nhiều nhất, được tô đỏ trên màn hình.
    var focus: Focus?
}

/// So khớp tư thế thật với dáng mẫu.
///
/// Mỗi đoạn chi được so theo **hướng** (góc), nên kết quả không phụ thuộc người đứng xa hay gần.
/// Vị trí và kích thước trong khung được chấm riêng thành điểm bố cục.
enum PoseMatcher {
    static func match(reference: [Skeleton], detected: [Skeleton], aspect: CGFloat, mirrored: Bool) -> MatchResult {
        guard !detected.isEmpty, !reference.isEmpty else {
            return MatchResult(score: 0, feedback: "Chưa thấy người trong khung hình", matchedBodies: [])
        }

        let n = reference.count
        let refs = reference.sorted { $0.boundingBox.midX < $1.boundingBox.midX }
        // Lấy n người to nhất (gần máy nhất), rồi xếp từ trái sang phải để ghép cặp với dáng mẫu.
        let lives = Array(
            detected.sorted { $0.boundingBox.height > $1.boundingBox.height }
                .prefix(n)
                .sorted { $0.boundingBox.midX < $1.boundingBox.midX }
        )
        guard lives.count == n else {
            return MatchResult(score: 0, feedback: "Cần thấy đủ \(n) người trong khung hình", matchedBodies: lives)
        }

        // 1. Điểm tư thế
        var scoreSum = 0.0, weightSum = 0.0
        var worst: (error: Double, body: Int, limb: Limb)?
        var refBox = CGRect.null, liveBox = CGRect.null

        for (i, (ref, live)) in zip(refs, lives).enumerated() {
            for limb in Limb.all {
                guard let rf = ref[limb.from], let rt = ref[limb.to],
                      let lf = live[limb.from], let lt = live[limb.to] else { continue }
                let error = angleDifference(vector(rf, rt, aspect), vector(lf, lt, aspect))
                scoreSum += max(0, 1 - error / 90) * limb.weight
                weightSum += limb.weight
                if error * limb.weight > (worst.map { $0.error * $0.limb.weight } ?? 0) {
                    worst = (error, i, limb)
                }
            }
            // Khung bao chỉ tính trên các khớp cả hai cùng có, để so công bằng.
            let common = Set(ref.points.keys).intersection(live.points.keys)
            guard !common.isEmpty else { continue }
            refBox = refBox.union(ref.boundingBox(of: common))
            liveBox = liveBox.union(live.boundingBox(of: common))
        }

        guard weightSum >= 3 else {
            return MatchResult(score: 0, feedback: "Lùi ra một chút để thấy rõ cả người", matchedBodies: lives)
        }
        let poseScore = scoreSum / weightSum

        // 2. Điểm bố cục
        let sizeRatio = liveBox.height / max(refBox.height, 0.01)
        let dx = liveBox.midX - refBox.midX
        let dy = liveBox.midY - refBox.midY
        let sizePenalty: Double = abs(log(Double(sizeRatio))) * 1.2
        let offsetPenalty: Double = (abs(Double(dx)) + abs(Double(dy))) * 2
        let framingScore: Double = max(0, 1 - sizePenalty - offsetPenalty)

        let total = Int(((poseScore * 0.8 + framingScore * 0.2) * 100).rounded())

        // 3. Chọn MỘT lời khuyên quan trọng nhất
        func limbFeedback() -> (String, MatchResult.Focus)? {
            guard let worst,
                  let text = advice(for: worst.limb, ref: refs[worst.body], live: lives[worst.body], aspect: aspect)
            else { return nil }
            // Trong ảnh lật gương (camera trước), trái/phải của Vision bị đảo.
            return (mirrored ? swapSides(text) : text, .init(body: worst.body, limb: worst.limb))
        }
        // Khi lật gương, hướng lia máy cũng bị đảo theo.
        let panDX = mirrored ? -dx : dx

        var feedback = ""
        var focus: MatchResult.Focus?
        if sizeRatio < 0.6 {
            feedback = "Tiến lại gần hơn hoặc zoom vào"
        } else if sizeRatio > 1.5 {
            feedback = "Lùi ra xa hơn cho vừa khung"
        } else if let worst, worst.error > 25, let limbAdvice = limbFeedback() {
            (feedback, focus) = limbAdvice
        } else if sizeRatio < 0.85 {
            feedback = "Tiến lại gần thêm chút nữa"
        } else if sizeRatio > 1.2 {
            feedback = "Lùi ra sau một chút"
        } else if panDX > 0.1 {
            feedback = "Lia máy sang phải một chút"
        } else if panDX < -0.1 {
            feedback = "Lia máy sang trái một chút"
        } else if dy > 0.08 {
            feedback = "Chúc máy xuống một chút"
        } else if dy < -0.08 {
            feedback = "Ngẩng máy lên một chút"
        } else if total >= 82 {
            feedback = "Hoàn hảo! Bấm máy thôi 📸"
        } else if let worst, worst.error > 12, let limbAdvice = limbFeedback() {
            (feedback, focus) = limbAdvice
        } else {
            feedback = "Gần đúng rồi, giữ nguyên nhé…"
        }

        return MatchResult(score: total, feedback: feedback, matchedBodies: lives, focus: focus)
    }

    // MARK: - Lời khuyên cho từng bộ phận

    /// Trả về hướng dẫn theo quy ước "trái/phải của người được chụp".
    private static func advice(for limb: Limb, ref: Skeleton, live: Skeleton, aspect: CGFloat) -> String? {
        guard let rf = ref[limb.from], let rt = ref[limb.to],
              let lf = live[limb.from], let lt = live[limb.to] else { return nil }

        // Điểm cuối "đáng lẽ phải ở đâu" nếu giữ nguyên độ dài thật nhưng xoay theo hướng mẫu.
        let refVec = vector(rf, rt, aspect)
        let refLen = max(hypot(refVec.dx, refVec.dy), 0.0001)
        let liveVec = vector(lf, lt, aspect)
        let liveLen = hypot(liveVec.dx, liveVec.dy)
        let expected = CGPoint(x: lf.x * aspect + refVec.dx / refLen * liveLen,
                               y: lf.y + refVec.dy / refLen * liveLen)
        let actual = CGPoint(x: lt.x * aspect, y: lt.y)
        let diffX = expected.x - actual.x
        let diffY = expected.y - actual.y
        let horizontal = abs(diffX) > abs(diffY)

        switch limb.kind {
        case .head:
            if horizontal {
                // Người đối diện máy: bên phải ảnh là bên trái của họ.
                return "Nghiêng đầu sang \(diffX > 0 ? "trái" : "phải") một chút"
            }
            return diffY < 0 ? "Ngẩng mặt lên một chút" : "Cúi mặt xuống một chút"
        case .torso:
            if horizontal {
                return "Nghiêng người sang \(diffX > 0 ? "trái" : "phải")"
            }
            return diffY < 0 ? "Đứng thẳng lưng lên" : "Hơi cúi người về trước"
        case .arm, .leg:
            if !horizontal {
                return diffY < 0 ? "Đưa \(limb.name) lên cao hơn" : "Hạ \(limb.name) xuống thấp hơn"
            }
            let centerX = (live[.neck] ?? live[.root] ?? lf).x * aspect
            let shouldGoOut = abs(expected.x - centerX) > abs(actual.x - centerX)
            return shouldGoOut ? "Đưa \(limb.name) ra xa người hơn" : "Khép \(limb.name) vào sát người hơn"
        }
    }

    // MARK: - Hình học

    /// Vector theo đơn vị thật (nhân x với tỉ lệ khung để góc không bị méo).
    private static func vector(_ a: CGPoint, _ b: CGPoint, _ aspect: CGFloat) -> CGVector {
        CGVector(dx: (b.x - a.x) * aspect, dy: b.y - a.y)
    }

    /// Góc lệch tuyệt đối giữa hai vector, đơn vị độ (0...180).
    private static func angleDifference(_ a: CGVector, _ b: CGVector) -> Double {
        var d = abs(atan2(a.dy, a.dx) - atan2(b.dy, b.dx))
        if d > .pi { d = 2 * .pi - d }
        return Double(d) * 180 / .pi
    }

    private static func swapSides(_ text: String) -> String {
        text.replacingOccurrences(of: "trái", with: "\u{1}")
            .replacingOccurrences(of: "phải", with: "trái")
            .replacingOccurrences(of: "\u{1}", with: "phải")
    }
}
