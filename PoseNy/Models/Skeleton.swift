import CoreGraphics
import Vision

/// Các khớp xương dùng trong app — trùng với các khớp Apple Vision nhận diện được.
/// Trái/phải là của người được chụp: khi họ đứng đối diện camera, tay trái nằm bên PHẢI ảnh.
enum Joint: String, CaseIterable, Hashable {
    case nose, neck
    case leftShoulder, rightShoulder
    case leftElbow, rightElbow
    case leftWrist, rightWrist
    case root
    case leftHip, rightHip
    case leftKnee, rightKnee
    case leftAnkle, rightAnkle

    var visionName: VNHumanBodyPoseObservation.JointName {
        switch self {
        case .nose: .nose
        case .neck: .neck
        case .leftShoulder: .leftShoulder
        case .rightShoulder: .rightShoulder
        case .leftElbow: .leftElbow
        case .rightElbow: .rightElbow
        case .leftWrist: .leftWrist
        case .rightWrist: .rightWrist
        case .root: .root
        case .leftHip: .leftHip
        case .rightHip: .rightHip
        case .leftKnee: .leftKnee
        case .rightKnee: .rightKnee
        case .leftAnkle: .leftAnkle
        case .rightAnkle: .rightAnkle
        }
    }

    /// Khớp đối xứng trái ↔ phải.
    var opposite: Joint {
        switch self {
        case .leftShoulder: .rightShoulder
        case .rightShoulder: .leftShoulder
        case .leftElbow: .rightElbow
        case .rightElbow: .leftElbow
        case .leftWrist: .rightWrist
        case .rightWrist: .leftWrist
        case .leftHip: .rightHip
        case .rightHip: .leftHip
        case .leftKnee: .rightKnee
        case .rightKnee: .leftKnee
        case .leftAnkle: .rightAnkle
        case .rightAnkle: .leftAnkle
        default: self
        }
    }
}

/// Một khung xương người. Toạ độ chuẩn hoá 0...1 trong khung ảnh dọc 9:16,
/// gốc (0,0) ở góc trên-trái — cùng hệ toạ độ với ảnh camera sau khi xoay dọc.
struct Skeleton: Equatable {
    var points: [Joint: CGPoint]

    init(_ points: [Joint: CGPoint]) {
        self.points = points
    }

    subscript(_ joint: Joint) -> CGPoint? { points[joint] }

    /// Các đoạn xương để vẽ khung xương.
    static let bones: [(Joint, Joint)] = [
        (.neck, .nose),
        (.neck, .leftShoulder), (.neck, .rightShoulder),
        (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
        (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
        (.neck, .root),
        (.root, .leftHip), (.root, .rightHip),
        (.leftHip, .leftKnee), (.leftKnee, .leftAnkle),
        (.rightHip, .rightKnee), (.rightKnee, .rightAnkle),
    ]

    var boundingBox: CGRect { boundingBox(of: points.keys) }

    func boundingBox<S: Sequence>(of joints: S) -> CGRect where S.Element == Joint {
        let pts = joints.compactMap { points[$0] }
        guard let first = pts.first else { return .zero }
        var minX = first.x, maxX = first.x, minY = first.y, maxY = first.y
        for p in pts {
            minX = min(minX, p.x); maxX = max(maxX, p.x)
            minY = min(minY, p.y); maxY = max(maxY, p.y)
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    // MARK: - Tiện ích để soạn dáng mẫu

    static func pts(_ raw: [Joint: (CGFloat, CGFloat)]) -> Skeleton {
        Skeleton(raw.mapValues { CGPoint(x: $0.0, y: $0.1) })
    }

    /// Ghi đè một vài khớp.
    func with(_ raw: [Joint: (CGFloat, CGFloat)]) -> Skeleton {
        var copy = points
        for (joint, p) in raw { copy[joint] = CGPoint(x: p.0, y: p.1) }
        return Skeleton(copy)
    }

    /// Thu phóng quanh tâm khung (0.5, 0.5) rồi dời tâm tới `center`.
    func transformed(scale: CGFloat, center: CGPoint) -> Skeleton {
        Skeleton(points.mapValues {
            CGPoint(x: center.x + ($0.x - 0.5) * scale, y: center.y + ($0.y - 0.5) * scale)
        })
    }

    /// Lật gương: đổi trái ↔ phải.
    func mirrored() -> Skeleton {
        var out: [Joint: CGPoint] = [:]
        for (joint, p) in points { out[joint.opposite] = CGPoint(x: 1 - p.x, y: p.y) }
        return Skeleton(out)
    }
}
