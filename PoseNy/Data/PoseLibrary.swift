import CoreGraphics

/// Kho dáng mẫu tích hợp sẵn.
/// Toạ độ trong khung 9:16 (x theo chiều ngang, y theo chiều dọc, 0...1).
/// Lưu ý: trên iPhone màn hình dài chỉ thấy khoảng x = 0.09...0.91, nên giữ dáng trong vùng đó.
enum PoseLibrary {
    // MARK: - Khung xương gốc

    /// Đứng thẳng, tay buông — toàn thân.
    static let standing = Skeleton.pts([
        .nose: (0.50, 0.17), .neck: (0.50, 0.24),
        .rightShoulder: (0.37, 0.255), .leftShoulder: (0.63, 0.255),
        .rightElbow: (0.355, 0.37), .leftElbow: (0.645, 0.37),
        .rightWrist: (0.35, 0.48), .leftWrist: (0.65, 0.48),
        .root: (0.50, 0.46), .rightHip: (0.43, 0.46), .leftHip: (0.57, 0.46),
        .rightKnee: (0.43, 0.65), .leftKnee: (0.57, 0.65),
        .rightAnkle: (0.43, 0.84), .leftAnkle: (0.57, 0.84),
    ])

    /// Nửa người (ngực trở lên), tay buông.
    static let halfBody = Skeleton.pts([
        .nose: (0.50, 0.30), .neck: (0.50, 0.42),
        .rightShoulder: (0.25, 0.45), .leftShoulder: (0.75, 0.45),
        .rightElbow: (0.21, 0.68), .leftElbow: (0.79, 0.68),
        .rightWrist: (0.24, 0.90), .leftWrist: (0.76, 0.90),
    ])

    // MARK: - Danh sách dáng

    static let all: [Pose] = [
        Pose(
            id: "hand-on-hip",
            name: "Chống hông tự tin",
            summary: "Một tay chống hông, chân bắt chéo nhẹ. Dáng kinh điển, ai chụp cũng đẹp.",
            category: .street, subjects: [.female, .male], framing: .fullBody,
            angle: .low, lens: 1,
            expression: "Cằm hơi đưa ra trước, mắt nhìn thẳng ống kính, cười nhẹ.",
            tips: [
                "Khuỷu tay chống hông đưa ra sau một chút để eo trông nhỏ hơn.",
                "Dồn trọng tâm vào chân sau, chân trước bắt chéo nhẹ.",
                "Người chụp hạ máy ngang hông, để chân chạm sát mép dưới khung hình.",
            ],
            bodies: [standing.with([
                .nose: (0.51, 0.17),
                .leftElbow: (0.76, 0.35), .leftWrist: (0.60, 0.45),
                .rightKnee: (0.44, 0.65), .rightAnkle: (0.45, 0.84),
                .leftKnee: (0.53, 0.64), .leftAnkle: (0.47, 0.83),
            ])]
        ),
        Pose(
            id: "hair-touch",
            name: "Vén tóc dịu dàng",
            summary: "Một tay đưa lên vén tóc, đầu nghiêng nhẹ. Hợp gió biển, váy bay.",
            category: .beach, subjects: [.female], framing: .fullBody,
            angle: .eyeLevel, lens: 2,
            expression: "Nhìn xuống hoặc nhìn xa, nửa cười. Đừng nhìn thẳng ống kính.",
            tips: [
                "Tay chạm tóc thật nhẹ, ngón tay thả lỏng, đừng nắm chặt.",
                "Chụp liên tục (giữ nút chụp) khi gió thổi để bắt khoảnh khắc tóc bay.",
                "Đứng quay lưng về phía mặt trời để tóc có viền sáng.",
            ],
            bodies: [standing.with([
                .nose: (0.52, 0.175),
                .rightElbow: (0.30, 0.17), .rightWrist: (0.43, 0.12),
                .rightKnee: (0.47, 0.645), .rightAnkle: (0.49, 0.83),
                .leftKnee: (0.56, 0.65), .leftAnkle: (0.56, 0.84),
            ])]
        ),
        Pose(
            id: "arms-wide",
            name: "Dang tay đón gió",
            summary: "Hai tay dang rộng chếch lên trời. Tự do, phóng khoáng giữa trời rộng.",
            category: .beach, subjects: [.female, .male], framing: .fullBody,
            angle: .low, lens: 0.5,
            expression: "Ngẩng mặt lên trời, nhắm mắt hoặc cười thật tươi.",
            tips: [
                "Dùng 0.5x, hạ máy thấp để có nhiều trời và chân trông dài.",
                "Để đường chân trời ở 1/3 dưới khung hình (bật lưới để canh).",
                "Bảo người mẫu hít một hơi sâu rồi mới dang tay để dáng tự nhiên.",
            ],
            bodies: [standing.with([
                .nose: (0.50, 0.165),
                .rightElbow: (0.24, 0.17), .rightWrist: (0.12, 0.09),
                .leftElbow: (0.76, 0.17), .leftWrist: (0.88, 0.09),
                .rightKnee: (0.42, 0.65), .rightAnkle: (0.41, 0.84),
                .leftKnee: (0.58, 0.65), .leftAnkle: (0.59, 0.84),
            ])]
        ),
        Pose(
            id: "walking",
            name: "Bước đi tự nhiên",
            summary: "Bước về phía máy, tay đánh nhẹ theo nhịp. Ảnh street style có hồn.",
            category: .street, subjects: [.female, .male], framing: .fullBody,
            angle: .low, lens: 0.5,
            expression: "Nhìn xuống đường hoặc nhìn sang bên, cười như đang nói chuyện.",
            tips: [
                "Giữ nút chụp để chụp liên tục, sau đó chọn tấm chân trước vừa chạm đất.",
                "Bước chậm hơn bình thường, bước dài và thẳng hàng như catwalk.",
                "Người chụp ngồi xổm, máy ngang đầu gối.",
            ],
            bodies: [standing.with([
                .nose: (0.51, 0.17),
                .rightElbow: (0.33, 0.36), .rightWrist: (0.36, 0.47),
                .leftElbow: (0.67, 0.36), .leftWrist: (0.68, 0.47),
                .rightKnee: (0.44, 0.645), .rightAnkle: (0.43, 0.86),
                .leftKnee: (0.57, 0.63), .leftAnkle: (0.59, 0.80),
            ])]
        ),
        Pose(
            id: "chin-rest",
            name: "Chống cằm bên ly cà phê",
            summary: "Tì khuỷu tay lên bàn, tay chống cằm. Nhẹ nhàng, chill.",
            category: .cafe, subjects: [.female], framing: .halfBody,
            angle: .high, lens: 1,
            expression: "Nhìn ra cửa sổ hoặc nhìn vào ly, khoé miệng hơi cười.",
            tips: [
                "Ngồi cạnh cửa sổ, để ánh sáng chiếu vào nửa mặt.",
                "Cho ly cà phê hoặc bánh vào tiền cảnh để ảnh có câu chuyện.",
                "Tay chống cằm chỉ chạm nhẹ, đừng tì cả sức nặng của đầu lên.",
            ],
            bodies: [halfBody.with([
                .rightElbow: (0.30, 0.66), .rightWrist: (0.47, 0.40),
                .leftElbow: (0.80, 0.68), .leftWrist: (0.62, 0.74),
            ])]
        ),
        Pose(
            id: "jump",
            name: "Bật nhảy",
            summary: "Nhảy lên, hai tay giơ chữ V, gập gối ra sau. Năng lượng tràn khung hình.",
            category: .beach, subjects: [.female, .male], framing: .fullBody,
            angle: .low, lens: 0.5,
            expression: "Cười hết cỡ, miệng mở. Biểu cảm càng lố càng vui.",
            tips: [
                "Đếm 1-2-3 rồi nhảy, người chụp giữ nút chụp từ lúc đếm 3.",
                "Gập gối ra sau khi lên cao nhất để trông như nhảy cao hơn.",
                "Ngồi thấp sát đất khi chụp để nhìn như đang bay.",
            ],
            bodies: [Skeleton.pts([
                .nose: (0.50, 0.15), .neck: (0.50, 0.22),
                .rightShoulder: (0.37, 0.235), .leftShoulder: (0.63, 0.235),
                .rightElbow: (0.27, 0.13), .rightWrist: (0.23, 0.04),
                .leftElbow: (0.73, 0.13), .leftWrist: (0.77, 0.04),
                .root: (0.50, 0.44), .rightHip: (0.43, 0.44), .leftHip: (0.57, 0.44),
                .rightKnee: (0.38, 0.60), .rightAnkle: (0.40, 0.70),
                .leftKnee: (0.62, 0.60), .leftAnkle: (0.60, 0.70),
            ])]
        ),
        Pose(
            id: "sun-shade",
            name: "Che nắng ngắm hoàng hôn",
            summary: "Một tay che lên trán như đang ngắm xa. Hợp với nền trời cam.",
            category: .sunset, subjects: [.female, .male], framing: .fullBody,
            angle: .low, lens: 1,
            expression: "Nheo mắt nhìn xa về phía mặt trời, cười nhẹ.",
            tips: [
                "Chạm vào trời trên màn hình để đo sáng theo trời. Người sẽ thành bóng đen, rất nghệ.",
                "Muốn rõ mặt thì cho người mẫu xoay 45° về phía ánh sáng.",
                "Chụp trong khoảng 15–20 phút trước khi mặt trời lặn.",
            ],
            bodies: [standing.with([
                .nose: (0.49, 0.17),
                .rightElbow: (0.24, 0.20), .rightWrist: (0.44, 0.14),
                .rightKnee: (0.43, 0.65), .rightAnkle: (0.42, 0.84),
                .leftKnee: (0.56, 0.65), .leftAnkle: (0.58, 0.84),
            ])]
        ),
        Pose(
            id: "pockets",
            name: "Đút tay túi quần",
            summary: "Hai tay đút túi, đứng thả lỏng. Phong cách nam tính, cool ngầu.",
            category: .street, subjects: [.male], framing: .fullBody,
            angle: .low, lens: 1,
            expression: "Mặt lạnh hoặc nhếch mép cười. Nhìn thẳng hoặc nhìn chéo xuống.",
            tips: [
                "Chỉ đút ngón tay vào túi, ngón cái để ngoài cho dáng gọn.",
                "Hai chân rộng bằng vai, dồn trọng tâm sang một bên.",
                "Tìm bức tường hoặc ngõ nhỏ có đường dẫn (leading lines) làm nền.",
            ],
            bodies: [standing.with([
                .rightElbow: (0.31, 0.36), .rightWrist: (0.40, 0.48),
                .leftElbow: (0.69, 0.36), .leftWrist: (0.60, 0.48),
                .rightKnee: (0.42, 0.65), .rightAnkle: (0.40, 0.84),
                .leftKnee: (0.58, 0.65), .leftAnkle: (0.60, 0.84),
            ])]
        ),
        Pose(
            id: "peace",
            name: "Chữ V tinh nghịch",
            summary: "Giơ chữ V cạnh má, đầu nghiêng. Cute hết nấc.",
            category: .cafe, subjects: [.female], framing: .halfBody,
            angle: .high, lens: 1,
            expression: "Nháy một mắt hoặc chu môi, nghiêng đầu về phía tay.",
            tips: [
                "Chữ V đặt ngang gò má, lòng bàn tay hướng ra ngoài.",
                "Chụp góc hơi cao để mặt thon và mắt to hơn.",
                "Thử cả phiên bản nhìn thẳng và nhìn sang bên.",
            ],
            bodies: [halfBody.with([
                .nose: (0.52, 0.30),
                .rightElbow: (0.18, 0.60), .rightWrist: (0.35, 0.36),
            ])]
        ),
        Pose(
            id: "couple-hands",
            name: "Nắm tay dạo bước",
            summary: "Hai người đứng cạnh nhau, nắm tay, nàng tựa nhẹ vào chàng.",
            category: .street, subjects: [.couple], framing: .fullBody,
            angle: .eyeLevel, lens: 1,
            expression: "Nhìn nhau cười, hoặc cùng nhìn về một hướng.",
            tips: [
                "Dùng hẹn giờ 10 giây hoặc nhờ người qua đường. App sẽ chờ thấy đủ 2 người.",
                "Đứng lệch nhau nửa bước để ảnh có chiều sâu.",
                "Thử đi chậm về phía máy và chụp liên tục.",
            ],
            bodies: [
                standing.transformed(scale: 0.85, center: CGPoint(x: 0.31, y: 0.52)).with([
                    .leftElbow: (0.44, 0.40), .leftWrist: (0.50, 0.49),
                ]),
                standing.transformed(scale: 0.8, center: CGPoint(x: 0.69, y: 0.54)).with([
                    .nose: (0.675, 0.28),
                    .rightElbow: (0.565, 0.43), .rightWrist: (0.51, 0.50),
                ]),
            ]
        ),
        Pose(
            id: "couple-heart",
            name: "Trái tim hoàng hôn",
            summary: "Mỗi người giơ một tay, ghép thành trái tim trên đầu.",
            category: .sunset, subjects: [.couple], framing: .fullBody,
            angle: .low, lens: 0.5,
            expression: "Cười tươi nhìn máy, hoặc nhìn nhau.",
            tips: [
                "Đặt mặt trời vào giữa trái tim, đây là tấm 'signature' của buổi chụp.",
                "Đo sáng theo trời để có bóng đen (silhouette).",
                "Đứng cách nhau một sải tay để trái tim tròn đẹp.",
            ],
            bodies: [
                standing.transformed(scale: 0.85, center: CGPoint(x: 0.33, y: 0.52)).with([
                    .leftElbow: (0.45, 0.19), .leftWrist: (0.50, 0.12),
                ]),
                standing.transformed(scale: 0.8, center: CGPoint(x: 0.67, y: 0.54)).with([
                    .rightElbow: (0.56, 0.23), .rightWrist: (0.505, 0.125),
                ]),
            ]
        ),
    ]
}
