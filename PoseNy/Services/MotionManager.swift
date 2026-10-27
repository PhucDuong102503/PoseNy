import CoreMotion

/// Đọc con quay hồi chuyển để hiển thị thước cân bằng (đường chân trời).
final class MotionManager: ObservableObject {
    /// Độ nghiêng của máy, đơn vị độ. Dương = nghiêng theo chiều kim đồng hồ.
    @Published private(set) var roll: Double = 0
    /// false khi máy nằm gần như phẳng (úp/ngửa). Lúc đó độ nghiêng không còn ý nghĩa.
    @Published private(set) var isUsable = false

    private let manager = CMMotionManager()

    func start() {
        guard manager.isDeviceMotionAvailable, !manager.isDeviceMotionActive else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 30
        manager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
            guard let self, let g = motion?.gravity else { return }
            self.roll = atan2(g.x, -g.y) * 180 / .pi
            self.isUsable = abs(g.z) < 0.85
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
    }
}
