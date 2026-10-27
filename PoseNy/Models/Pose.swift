import SwiftUI

enum PoseCategory: String, CaseIterable, Identifiable {
    case cafe, beach, street, sunset

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cafe: "Cà phê"
        case .beach: "Biển"
        case .street: "Dạo phố"
        case .sunset: "Hoàng hôn"
        }
    }

    var icon: String {
        switch self {
        case .cafe: "cup.and.saucer.fill"
        case .beach: "beach.umbrella.fill"
        case .street: "building.2.fill"
        case .sunset: "sun.horizon.fill"
        }
    }

    var colors: [Color] {
        switch self {
        case .cafe: [Color(red: 0.45, green: 0.30, blue: 0.22), Color(red: 0.82, green: 0.64, blue: 0.47)]
        case .beach: [Color(red: 0.05, green: 0.45, blue: 0.62), Color(red: 0.45, green: 0.83, blue: 0.85)]
        case .street: [Color(red: 0.22, green: 0.20, blue: 0.45), Color(red: 0.55, green: 0.42, blue: 0.75)]
        case .sunset: [Color(red: 0.93, green: 0.42, blue: 0.30), Color(red: 0.98, green: 0.72, blue: 0.45)]
        }
    }
}

enum Subject: String, CaseIterable, Identifiable {
    case female, male, couple

    var id: String { rawValue }

    var title: String {
        switch self {
        case .female: "Nữ"
        case .male: "Nam"
        case .couple: "Cặp đôi"
        }
    }
}

enum Framing {
    case fullBody, halfBody

    var title: String {
        switch self {
        case .fullBody: "Toàn thân"
        case .halfBody: "Nửa người"
        }
    }
}

enum CameraAngle {
    case low, eyeLevel, high, side45

    var title: String {
        switch self {
        case .low: "Góc thấp"
        case .eyeLevel: "Ngang tầm mắt"
        case .high: "Góc cao"
        case .side45: "Nghiêng 45°"
        }
    }

    var detail: String {
        switch self {
        case .low: "Hạ máy ngang hông hoặc đầu gối, ngửa nhẹ lên. Chân dài, dáng cao hơn."
        case .eyeLevel: "Giữ máy ngang tầm mắt người được chụp. Tự nhiên, chân thật."
        case .high: "Giơ máy cao hơn đầu một chút, chúc xuống. Mặt thon, mắt to."
        case .side45: "Đứng lệch 45° so với người được chụp. Tạo chiều sâu, gương mặt thanh hơn."
        }
    }

    var icon: String {
        switch self {
        case .low: "arrow.up.circle"
        case .eyeLevel: "eye"
        case .high: "arrow.down.circle"
        case .side45: "angle"
        }
    }
}

struct Pose: Identifiable, Hashable {
    let id: String
    let name: String
    let summary: String
    let category: PoseCategory
    let subjects: [Subject]
    let framing: Framing
    let angle: CameraAngle
    /// Ống kính gợi ý: 0.5, 1 hoặc 2.
    let lens: CGFloat
    let expression: String
    let tips: [String]
    /// Khung xương mẫu — một phần tử cho mỗi người trong khung hình.
    let bodies: [Skeleton]

    static func == (lhs: Pose, rhs: Pose) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var lensLabel: String { lens < 1 ? "0.5x" : "\(Int(lens))x" }

    var lensDetail: String {
        if lens < 1 { return "Góc rộng. Đứng xa, hạ máy thấp để kéo dài chân." }
        if lens < 2 { return "Ống chính. Màu và chi tiết tốt nhất." }
        return "Chân dung. Mặt không bị méo, hậu cảnh gọn."
    }
}
