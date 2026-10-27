import CoreVideo
import Vision

/// Nhận diện khung xương người bằng Apple Vision (chạy hoàn toàn trên máy, không cần server).
final class PoseDetector {
    private let request = VNDetectHumanBodyPoseRequest()
    private let minConfidence: Float = 0.3

    /// `pixelBuffer` phải đã được xoay dọc (connection.videoRotationAngle = 90).
    func detect(in pixelBuffer: CVPixelBuffer) -> [Skeleton] {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        do {
            try handler.perform([request])
        } catch {
            return []
        }
        return (request.results ?? []).compactMap(makeSkeleton)
    }

    private func makeSkeleton(_ observation: VNHumanBodyPoseObservation) -> Skeleton? {
        guard let recognized = try? observation.recognizedPoints(.all) else { return nil }
        var points: [Joint: CGPoint] = [:]
        for joint in Joint.allCases {
            guard let p = recognized[joint.visionName], p.confidence >= minConfidence else { continue }
            // Vision dùng gốc dưới-trái → đổi sang gốc trên-trái.
            points[joint] = CGPoint(x: p.location.x, y: 1 - p.location.y)
        }
        return points.count >= 5 ? Skeleton(points) : nil
    }
}
