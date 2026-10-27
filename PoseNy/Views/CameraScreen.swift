import AVFoundation
import SwiftUI

struct CameraScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pose: Pose?

    @StateObject private var camera = CameraManager()
    @StateObject private var coach = PoseCoach()
    @StateObject private var motion = MotionManager()

    @AppStorage("showGrid") private var showGrid = true
    @AppStorage("showLevel") private var showLevel = true
    @AppStorage("aiEnabled") private var aiEnabled = true
    @AppStorage("autoCapture") private var autoCapture = false
    @AppStorage("overlayOpacity") private var overlayOpacity = 0.55

    @State private var flash = false
    @State private var toast: String?
    @State private var showPosePicker = false

    init(pose: Pose?) {
        _pose = State(initialValue: pose)
    }

    private var liveBodies: [Skeleton] {
        guard aiEnabled else { return [] }
        return pose == nil ? camera.bodies : (coach.result?.matchedBodies ?? [])
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            CameraPreview(session: camera.session)
                .ignoresSafeArea()

            ZStack {
                if showGrid { GridOverlay() }
                PoseOverlay(
                    reference: pose?.bodies ?? [],
                    live: liveBodies,
                    aspect: camera.imageAspect,
                    opacity: overlayOpacity,
                    isPerfect: coach.isPerfect,
                    focus: coach.result?.focus
                )
            }
            .ignoresSafeArea()

            if showLevel && motion.isUsable {
                HorizonLevelView(roll: motion.roll)
            }

            VStack(spacing: 10) {
                topBar
                if let pose { angleHint(pose) }
                if pose != nil && aiEnabled, let result = coach.result { coachBanner(result) }
                Spacer()
                bottomControls
            }

            statusOverlay

            if let toast {
                Text(toast)
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .transition(.opacity)
                    .offset(y: 120)
            }

            if flash {
                Color.white.ignoresSafeArea().allowsHitTesting(false)
            }
        }
        .foregroundStyle(.white)
        .statusBarHidden()
        .onAppear {
            camera.start()
            camera.setDetection(aiEnabled)
            motion.start()
            if let pose { camera.setZoom(pose.lens) }
        }
        .onDisappear {
            camera.stop()
            motion.stop()
        }
        .onReceive(camera.$bodies) { bodies in
            guard aiEnabled, let pose else { return }
            coach.update(
                reference: pose.bodies, detected: bodies,
                aspect: camera.imageAspect, mirrored: camera.position == .front,
                autoCapture: autoCapture
            )
        }
        .onChange(of: aiEnabled) { _, enabled in
            camera.setDetection(enabled)
            coach.reset()
        }
        .onChange(of: pose) { _, newPose in
            coach.reset()
            if let newPose { camera.setZoom(newPose.lens) }
        }
        .onChange(of: coach.autoShotCount) { _, _ in
            capture()
        }
        .sheet(isPresented: $showPosePicker) {
            PosePickerSheet(selection: $pose)
        }
    }

    // MARK: - Thanh trên

    private var topBar: some View {
        HStack(spacing: 10) {
            Button { dismiss() } label: {
                Image(systemName: "xmark").circleButton(isOn: false)
            }
            Spacer()
            toggle("square.grid.3x3", isOn: $showGrid, label: "Lưới 1/3")
            toggle("level", isOn: $showLevel, label: "Thước cân bằng")
            toggle("figure.arms.open", isOn: $aiEnabled, label: "AI nhận diện dáng")
            if pose != nil {
                toggle("timer", isOn: $autoCapture, label: "Tự chụp khi khớp dáng")
            }
            Menu {
                Picker("Độ đậm khung dáng", selection: $overlayOpacity) {
                    Text("Nhạt").tag(0.3)
                    Text("Vừa").tag(0.55)
                    Text("Đậm").tag(0.8)
                }
            } label: {
                Image(systemName: "circle.lefthalf.filled").circleButton(isOn: false)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func toggle(_ icon: String, isOn: Binding<Bool>, label: String) -> some View {
        Button { isOn.wrappedValue.toggle() } label: {
            Image(systemName: icon).circleButton(isOn: isOn.wrappedValue)
        }
        .accessibilityLabel(label)
    }

    private func angleHint(_ pose: Pose) -> some View {
        Label("\(pose.angle.title) · \(pose.lensLabel)", systemImage: pose.angle.icon)
            .font(.caption.bold())
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Color.black.opacity(0.45), in: Capsule())
    }

    // MARK: - Hướng dẫn của AI

    private func coachBanner(_ result: MatchResult) -> some View {
        let ringColor: Color = coach.isPerfect ? .white : (coach.score >= 60 ? .yellow : .orange)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().stroke(.white.opacity(0.25), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: Double(coach.score) / 100)
                        .stroke(ringColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(coach.score)")
                        .font(.system(.subheadline, design: .rounded).bold())
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(coach.isPerfect ? "Hoàn hảo! Bấm máy thôi 📸" : result.feedback)
                        .font(.headline)
                    Text("Trái/phải tính theo người được chụp")
                        .font(.caption2)
                        .opacity(0.7)
                }
                Spacer(minLength: 0)
            }
            if autoCapture && coach.holdProgress > 0 {
                ProgressView(value: coach.holdProgress)
                    .tint(.white)
            }
        }
        .padding(12)
        .background(
            coach.isPerfect ? Color.green.opacity(0.85) : Color.black.opacity(0.5),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: coach.isPerfect)
    }

    // MARK: - Thanh dưới

    private var bottomControls: some View {
        VStack(spacing: 18) {
            if camera.zoomOptions.count > 1 {
                HStack(spacing: 10) {
                    ForEach(camera.zoomOptions, id: \.self) { z in
                        let selected = abs(camera.zoom - z) < 0.05
                        Button { camera.setZoom(z) } label: {
                            Text(z < 1 ? "0.5x" : "\(Int(z))x")
                                .font(.caption.bold())
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.45), in: Circle())
                                .foregroundStyle(selected ? Color.yellow : Color.white)
                        }
                    }
                }
            }

            HStack {
                Button { showPosePicker = true } label: {
                    Group {
                        if let pose {
                            PoseFigureView(pose: pose)
                                .frame(width: 40, height: 71)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: "figure.stand")
                                .font(.title2)
                                .frame(width: 40, height: 71)
                        }
                    }
                    .frame(width: 60, height: 72)
                }
                .accessibilityLabel("Đổi dáng mẫu")

                Spacer()

                Button(action: capture) {
                    ZStack {
                        Circle().stroke(.white, lineWidth: 4).frame(width: 78, height: 78)
                        Circle().fill(coach.isPerfect ? Color.green : Color.white).frame(width: 64, height: 64)
                    }
                }
                .accessibilityLabel("Chụp ảnh")

                Spacer()

                Button { camera.switchCamera() } label: {
                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .font(.title2)
                        .frame(width: 60, height: 60)
                        .background(Color.black.opacity(0.45), in: Circle())
                }
                .accessibilityLabel("Đổi camera trước/sau")
            }
            .padding(.horizontal, 28)
        }
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var statusOverlay: some View {
        switch camera.status {
        case .unauthorized:
            VStack(spacing: 12) {
                Text("PoseNy chưa được phép dùng camera")
                    .font(.headline)
                Button("Mở Cài đặt") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        case .unavailable:
            Text("Không tìm thấy camera.\nHãy chạy app trên iPhone thật (Simulator không có camera).")
                .multilineTextAlignment(.center)
                .padding()
        default:
            EmptyView()
        }
    }

    // MARK: - Chụp

    private func capture() {
        withAnimation(.easeOut(duration: 0.05)) { flash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeIn(duration: 0.2)) { flash = false }
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        camera.capturePhoto { ok in
            showToast(ok ? "Đã lưu vào Ảnh ✅" : "Không lưu được ảnh. Kiểm tra quyền truy cập Ảnh.")
        }
    }

    private func showToast(_ message: String) {
        withAnimation { toast = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { if toast == message { toast = nil } }
        }
    }
}

private extension Image {
    func circleButton(isOn: Bool) -> some View {
        self.font(.system(size: 15, weight: .semibold))
            .frame(width: 38, height: 38)
            .background(isOn ? Color.yellow : Color.black.opacity(0.45), in: Circle())
            .foregroundStyle(isOn ? Color.black : Color.white)
    }
}

/// Đổi nhanh dáng mẫu ngay trong camera.
private struct PosePickerSheet: View {
    @Binding var selection: Pose?
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    Button { selection = nil; dismiss() } label: {
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                                .aspectRatio(9.0 / 16.0, contentMode: .fit)
                                .overlay { Image(systemName: "nosign").font(.title) }
                            Text("Chụp tự do").font(.caption2).lineLimit(1)
                        }
                    }
                    ForEach(PoseLibrary.all) { pose in
                        Button { selection = pose; dismiss() } label: {
                            VStack(spacing: 4) {
                                PoseFigureView(pose: pose)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay {
                                        if selection == pose {
                                            RoundedRectangle(cornerRadius: 12).stroke(Color.accentColor, lineWidth: 3)
                                        }
                                    }
                                Text(pose.name).font(.caption2).lineLimit(1)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding()
            }
            .foregroundStyle(Color.primary)
            .navigationTitle("Chọn dáng")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}
