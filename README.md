# PoseNy 📸

App iOS giúp "phó nháy" chụp ảnh đẹp cho người yêu: chọn dáng mẫu, mở camera, khung dáng hiện đè lên màn hình,
và AI nhận diện khung xương để chỉ dẫn từng chi tiết ("Đưa bàn tay trái lên cao hơn", "Lùi ra sau một chút"...).

## Tính năng

| Roadmap | Đã làm |
|---|---|
| **Bước 1: Thư viện dáng** | 27 dáng mẫu (đứng, ngồi, nửa người, cặp đôi), lọc theo hoàn cảnh (Cà phê, Biển, Dạo phố, Hoàng hôn) và đối tượng (Nữ, Nam, Cặp đôi). Mỗi dáng có góc máy, ống kính, biểu cảm và mẹo chụp. Lưu dáng yêu thích. |
| **Bước 2: Camera & Overlay** | Hình bóng dáng mẫu hiện mờ trên camera (chỉnh được độ đậm). Lưới 1/3, thước cân bằng bằng con quay hồi chuyển, zoom 0.5x/1x/2x (tự chọn theo dáng), đổi camera trước/sau, chụp và lưu vào Ảnh. |
| **Bước 3: AI** | Apple Vision nhận diện khung xương theo thời gian thực (hỗ trợ cặp đôi, 2 người). App chấm điểm 0–100, tô đỏ bộ phận đang sai và đưa ra lời hướng dẫn bằng tiếng Việt. Máy rung khi khớp dáng, có thể bật tự chụp khi giữ đúng dáng 1.2 giây. |

Vì sao dùng **Apple Vision** thay cho MediaPipe? Nó có sẵn trong iOS, chạy hoàn toàn trên máy, được tối ưu cho Neural Engine,
không cần cài thêm thư viện và không tốn chi phí server.

## Cấu trúc

```
PoseNy/
├── App/PoseNyApp.swift          Điểm khởi động
├── Models/
│   ├── Skeleton.swift           Khớp xương và khung xương (toạ độ 0…1 trong khung 9:16)
│   └── Pose.swift               Dáng mẫu, danh mục, góc máy
├── Data/PoseLibrary.swift       Kho dáng mẫu (thêm dáng mới ở đây)
├── Services/
│   ├── CameraManager.swift      AVFoundation: preview, frame cho AI, zoom, chụp và lưu
│   ├── PoseDetector.swift       Apple Vision: nhận diện khung xương
│   ├── PoseMatcher.swift        So khớp tư thế, chấm điểm, sinh lời hướng dẫn
│   ├── PoseCoach.swift          Làm mượt điểm, rung, tự chụp
│   ├── MotionManager.swift      Thước cân bằng (CoreMotion)
│   └── FavoritesStore.swift     Lưu dáng yêu thích
└── Views/                       Giao diện SwiftUI
```

**AI so khớp như thế nào:** mỗi đoạn chi (bắp tay, cẳng tay, đùi, cẳng chân, đầu, thân) được so theo *hướng*
giữa dáng mẫu và người thật, nên người đứng xa hay gần đều không ảnh hưởng. Vị trí và kích thước trong khung được chấm riêng
thành điểm bố cục. Mỗi lần app chỉ đưa ra **một** lời khuyên quan trọng nhất, để phó nháy đọc to cho người mẫu làm theo.

## Chạy app

Cần **máy Mac có Xcode 15 trở lên** (iOS 17+). App dùng camera nên phải chạy trên **iPhone thật**, Simulator không có camera.

```bash
brew install xcodegen
cd PoseNy
xcodegen generate        # tạo PoseNy.xcodeproj từ project.yml
open PoseNy.xcodeproj
```

Trong Xcode: chọn target **PoseNy** → **Signing & Capabilities** → chọn Team (đăng nhập Apple ID miễn phí là đủ)
→ cắm iPhone → bấm ▶. Lần đầu chạy, vào iPhone **Cài đặt → Cài đặt chung → VPN & Quản lý thiết bị** để tin cậy nhà phát triển.

> Apple ID miễn phí: app chạy được 7 ngày rồi phải cài lại. Tài khoản Apple Developer ($99/năm) cho phép dùng TestFlight và đưa lên App Store.

### Nếu chỉ có máy Windows

- **Kiểm tra code biên dịch được:** đẩy code lên GitHub, workflow `.github/workflows/ios-build.yml` sẽ tự build trên máy macOS ảo (miễn phí với repo public).
- **Cài lên iPhone:** vẫn cần Mac. Bạn có thể thuê Mac cloud (MacinCloud, AWS EC2 Mac) hoặc mượn một chiếc Mac để cài.
  Nếu có tài khoản Developer trả phí, có thể dùng dịch vụ CI (Codemagic, Xcode Cloud) để build và gửi qua TestFlight.

## Thêm dáng mới

Mở `Data/PoseLibrary.swift`. Cách nhanh nhất là bắt đầu từ `standing` (đứng thẳng) hoặc `halfBody` (nửa người)
rồi ghi đè vài khớp:

```swift
bodies: [standing.with([
    .rightElbow: (0.30, 0.17), .rightWrist: (0.43, 0.12),   // giơ tay phải lên đầu
])]
```

- Toạ độ `(x, y)` từ 0 đến 1, gốc ở góc trên-trái của khung dọc 9:16.
- Trái/phải là **của người được chụp**: tay trái nằm ở bên phải ảnh (x lớn hơn).
- Giữ dáng trong khoảng x = 0.1…0.9, vì iPhone màn hình dài sẽ cắt bớt hai bên.
- Cặp đôi: dùng `.transformed(scale:center:)` để thu nhỏ và đặt từng người vào vị trí.

## Hướng phát triển tiếp

1. **Tạo dáng từ ảnh mẫu:** chọn một ảnh (Pinterest, Instagram...), Vision trích xuất khung xương thành dáng mới, và ảnh gốc được giữ làm ảnh tham khảo.
2. Thêm ảnh mẫu thật cho từng dáng (ảnh chụp đã được cấp phép).
3. Phát hiện góc nghiêng máy (pitch) để nhắc "Hạ máy thấp hơn" với dáng góc thấp.
4. Backend (Spring Boot + PostgreSQL) để đồng bộ bộ sưu tập và chia sẻ dáng giữa người dùng.
