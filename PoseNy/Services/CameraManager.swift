import AVFoundation
import Photos
import UIKit

/// Quản lý camera: preview, lấy khung hình cho Vision, zoom, đổi camera, chụp và lưu ảnh.
final class CameraManager: NSObject, ObservableObject {
    enum Status { case idle, running, unauthorized, unavailable }

    @Published private(set) var status: Status = .idle
    @Published private(set) var bodies: [Skeleton] = []
    /// Tỉ lệ rộng/cao của khung hình camera (thường là 9:16).
    @Published private(set) var imageAspect: CGFloat = 9.0 / 16.0
    @Published private(set) var position: AVCaptureDevice.Position = .back
    @Published private(set) var zoomOptions: [CGFloat] = [1]
    @Published private(set) var zoom: CGFloat = 1

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "poseny.camera.session")
    private let videoQueue = DispatchQueue(label: "poseny.camera.video", qos: .userInitiated)
    private let videoOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private let detector = PoseDetector()

    private var input: AVCaptureDeviceInput?
    private var isConfigured = false
    /// Hệ số zoom thật ứng với "1x" (máy có ống siêu rộng thì 1x = 2.0).
    private var baseZoom: CGFloat = 1
    private var photoCompletion: ((Bool) -> Void)?

    // Chỉ truy cập trên videoQueue
    private var detectionActive = true
    private var frameCounter = 0

    // MARK: - Vòng đời

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            run()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { self.run() } else { self.status = .unauthorized }
                }
            }
        default:
            status = .unauthorized
        }
    }

    func stop() {
        sessionQueue.async { [self] in
            if session.isRunning { session.stopRunning() }
        }
    }

    func setDetection(_ enabled: Bool) {
        videoQueue.async { self.detectionActive = enabled }
        if !enabled { bodies = [] }
    }

    private func run() {
        sessionQueue.async { [self] in
            if !isConfigured {
                guard configureSession() else {
                    DispatchQueue.main.async { self.status = .unavailable }
                    return
                }
                isConfigured = true
            }
            if !session.isRunning { session.startRunning() }
            DispatchQueue.main.async { self.status = .running }
        }
    }

    // MARK: - Cấu hình (chạy trên sessionQueue)

    private func configureSession() -> Bool {
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        session.sessionPreset = .high

        guard let device = Self.bestDevice(for: .back),
              let newInput = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(newInput) else { return false }
        session.addInput(newInput)
        input = newInput

        if session.canAddOutput(videoOutput) {
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
            ]
            videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
            session.addOutput(videoOutput)
        }
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        configureConnections(for: device.position)
        configureZoom(for: device)
        return true
    }

    /// Ưu tiên camera ảo (gộp nhiều ống kính) để zoom 0.5x / 1x / 2x mượt.
    private static func bestDevice(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let types: [AVCaptureDevice.DeviceType] = position == .back
            ? [.builtInTripleCamera, .builtInDualWideCamera, .builtInDualCamera, .builtInWideAngleCamera]
            : [.builtInWideAngleCamera]
        return AVCaptureDevice.DiscoverySession(deviceTypes: types, mediaType: .video, position: position).devices.first
    }

    private func configureConnections(for position: AVCaptureDevice.Position) {
        let connections = [videoOutput.connection(with: .video), photoOutput.connection(with: .video)].compactMap { $0 }
        for connection in connections {
            // Xoay khung hình về dọc để Vision nhận diện người đứng thẳng.
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = position == .front
            }
        }
    }

    private func configureZoom(for device: AVCaptureDevice) {
        let hasUltraWide = device.constituentDevices.contains { $0.deviceType == .builtInUltraWideCamera }
        let base = hasUltraWide ? CGFloat(device.virtualDeviceSwitchOverVideoZoomFactors.first?.doubleValue ?? 1) : 1
        let candidates: [CGFloat] = hasUltraWide ? [0.5, 1, 2] : [1, 2]
        let options = candidates.filter {
            $0 * base >= device.minAvailableVideoZoomFactor && $0 * base <= device.maxAvailableVideoZoomFactor
        }
        baseZoom = base
        applyZoom(1, on: device)
        DispatchQueue.main.async {
            self.zoomOptions = options
            self.position = device.position
        }
    }

    private func applyZoom(_ display: CGFloat, on device: AVCaptureDevice) {
        let factor = min(max(display * baseZoom, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)
        guard (try? device.lockForConfiguration()) != nil else { return }
        device.videoZoomFactor = factor
        device.unlockForConfiguration()
        let shown = factor / baseZoom
        DispatchQueue.main.async { self.zoom = shown }
    }

    // MARK: - Điều khiển

    /// `display` là mức zoom hiển thị cho người dùng: 0.5, 1, 2...
    func setZoom(_ display: CGFloat) {
        sessionQueue.async { [self] in
            guard let device = input?.device else { return }
            applyZoom(display, on: device)
        }
    }

    func switchCamera() {
        sessionQueue.async { [self] in
            guard let current = input else { return }
            let newPosition: AVCaptureDevice.Position = current.device.position == .back ? .front : .back
            guard let device = Self.bestDevice(for: newPosition),
                  let newInput = try? AVCaptureDeviceInput(device: device) else { return }

            session.beginConfiguration()
            session.removeInput(current)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
                input = newInput
            } else {
                session.addInput(current)
            }
            let active = input?.device ?? current.device
            configureConnections(for: active.position)
            session.commitConfiguration()
            configureZoom(for: active)
        }
    }

    func capturePhoto(completion: @escaping (Bool) -> Void) {
        sessionQueue.async { [self] in
            guard session.isRunning, photoCompletion == nil else { return }
            photoCompletion = completion
            photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    }
}

// MARK: - Khung hình video → Vision

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard detectionActive, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        // Xử lý 1/2 số khung hình (~15 fps) là đủ mượt và đỡ tốn pin.
        frameCounter += 1
        guard frameCounter % 2 == 0 else { return }

        let aspect = CGFloat(CVPixelBufferGetWidth(pixelBuffer)) / CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let found = detector.detect(in: pixelBuffer)
        DispatchQueue.main.async {
            if abs(self.imageAspect - aspect) > 0.001 { self.imageAspect = aspect }
            self.bodies = found
        }
    }
}

// MARK: - Chụp ảnh → thư viện Ảnh

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let data = error == nil ? photo.fileDataRepresentation() : nil
        sessionQueue.async { [self] in
            let completion = photoCompletion
            photoCompletion = nil
            let finish: (Bool) -> Void = { ok in DispatchQueue.main.async { completion?(ok) } }

            guard let data else { finish(false); return }
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                guard status == .authorized || status == .limited else { finish(false); return }
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
                }, completionHandler: { ok, _ in finish(ok) })
            }
        }
    }
}
