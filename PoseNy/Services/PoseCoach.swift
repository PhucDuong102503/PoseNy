import UIKit

/// Làm mượt điểm số theo thời gian, rung khi khớp dáng và kích hoạt tự chụp.
final class PoseCoach: ObservableObject {
    @Published private(set) var result: MatchResult?
    @Published private(set) var score = 0
    @Published private(set) var isPerfect = false
    /// 0...1: đã giữ dáng hoàn hảo được bao lâu (dùng cho tự chụp).
    @Published private(set) var holdProgress: Double = 0
    /// Tăng mỗi khi cần tự bấm máy. View lắng nghe thay đổi này.
    @Published private(set) var autoShotCount = 0

    private static let enterPerfect = 82.0
    private static let exitPerfect = 76.0
    private static let holdDuration: TimeInterval = 1.2
    private static let autoShotCooldown: TimeInterval = 3

    private var smoothed = 0.0
    private var perfectSince: Date?
    private var lastAutoShot = Date.distantPast
    private let haptic = UINotificationFeedbackGenerator()

    func reset() {
        result = nil
        smoothed = 0
        score = 0
        isPerfect = false
        holdProgress = 0
        perfectSince = nil
    }

    func update(reference: [Skeleton], detected: [Skeleton], aspect: CGFloat, mirrored: Bool, autoCapture: Bool) {
        let r = PoseMatcher.match(reference: reference, detected: detected, aspect: aspect, mirrored: mirrored)
        result = r
        smoothed = smoothed * 0.75 + Double(r.score) * 0.25
        score = Int(smoothed.rounded())

        // Hai ngưỡng khác nhau để trạng thái không nhấp nháy.
        let nowPerfect = smoothed >= (isPerfect ? Self.exitPerfect : Self.enterPerfect)
        if nowPerfect && !isPerfect { haptic.notificationOccurred(.success) }
        isPerfect = nowPerfect

        guard nowPerfect else {
            perfectSince = nil
            holdProgress = 0
            return
        }
        let now = Date()
        let since = perfectSince ?? now
        perfectSince = since
        let held = now.timeIntervalSince(since)
        holdProgress = min(1, held / Self.holdDuration)

        if autoCapture, held >= Self.holdDuration, now.timeIntervalSince(lastAutoShot) > Self.autoShotCooldown {
            lastAutoShot = now
            perfectSince = nil
            holdProgress = 0
            autoShotCount += 1
        }
    }
}
