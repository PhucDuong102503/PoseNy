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

    /// Bật nhảy: tay chữ V, gập gối ra sau.
    static let jumping = Skeleton.pts([
        .nose: (0.50, 0.15), .neck: (0.50, 0.22),
        .rightShoulder: (0.37, 0.235), .leftShoulder: (0.63, 0.235),
        .rightElbow: (0.27, 0.13), .rightWrist: (0.23, 0.04),
        .leftElbow: (0.73, 0.13), .leftWrist: (0.77, 0.04),
        .root: (0.50, 0.44), .rightHip: (0.43, 0.44), .leftHip: (0.57, 0.44),
        .rightKnee: (0.38, 0.60), .rightAnkle: (0.40, 0.70),
        .leftKnee: (0.62, 0.60), .leftAnkle: (0.60, 0.70),
    ])

    /// Đứng khoanh tay trước ngực.
    static let crossedArms = standing.with([
        .rightElbow: (0.36, 0.37), .rightWrist: (0.58, 0.33),
        .leftElbow: (0.64, 0.37), .leftWrist: (0.42, 0.34),
    ])

    // MARK: - Danh sách dáng

    /// Tách thành nhiều mảng nhỏ để trình biên dịch Swift không bị quá tải khi suy luận kiểu.
    static let all: [Pose] = basics + moreSolo + moreSeated + moreCouples

    private static let basics: [Pose] = [
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
            bodies: [jumping]
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

    // MARK: - Dáng đứng bổ sung

    private static let moreSolo: [Pose] = [
        Pose(
            id: "power-pose",
            name: "Hai tay chống hông",
            summary: "Hai tay chống hông, chân rộng bằng vai. Mạnh mẽ, đầy khí chất.",
            category: .street, subjects: [.female, .male], framing: .fullBody,
            angle: .low, lens: 0.5,
            expression: "Cằm hơi nâng, ánh mắt tự tin nhìn thẳng ống kính.",
            tips: [
                "Đẩy khuỷu tay hơi ra sau để vai mở và eo gọn hơn.",
                "Chụp góc thấp với 0.5x để dáng cao và có khí thế.",
                "Hợp với nền toà nhà cao hoặc cầu thang lớn.",
            ],
            bodies: [standing.with([
                .rightElbow: (0.24, 0.35), .rightWrist: (0.40, 0.45),
                .leftElbow: (0.76, 0.35), .leftWrist: (0.60, 0.45),
                .rightKnee: (0.42, 0.65), .rightAnkle: (0.40, 0.84),
                .leftKnee: (0.58, 0.65), .leftAnkle: (0.60, 0.84),
            ])]
        ),
        Pose(
            id: "crossed-arms",
            name: "Khoanh tay tự tin",
            summary: "Khoanh tay trước ngực, đứng thả lỏng. Chững chạc, hợp ảnh profile.",
            category: .street, subjects: [.male, .female], framing: .fullBody,
            angle: .eyeLevel, lens: 1,
            expression: "Cười mỉm, mắt nhìn thẳng. Đừng mím môi kẻo trông căng thẳng.",
            tips: [
                "Khoanh tay lỏng, để lộ một chút bàn tay cho tự nhiên.",
                "Dựa nhẹ vai vào tường hoặc cột để dáng bớt cứng.",
                "Thử thêm một tấm nghiêng người 45° so với máy.",
            ],
            bodies: [crossedArms]
        ),
        Pose(
            id: "hat-hold",
            name: "Giữ mũ cói",
            summary: "Một tay giữ vành mũ, tay kia vịn váy. Đúng chất đi biển mùa hè.",
            category: .beach, subjects: [.female], framing: .fullBody,
            angle: .low, lens: 1,
            expression: "Nghiêng mặt nhìn xa, cười nhẹ như đang bị gió thổi.",
            tips: [
                "Kéo nhẹ vành mũ xuống che một bên mắt cho có chiều sâu.",
                "Chọn lúc gió thổi để váy và tóc có chuyển động.",
                "Đứng chếch so với mặt trời để mặt không bị nheo.",
            ],
            bodies: [standing.with([
                .nose: (0.47, 0.175),
                .rightElbow: (0.27, 0.16), .rightWrist: (0.42, 0.09),
                .leftElbow: (0.66, 0.37), .leftWrist: (0.70, 0.47),
                .rightKnee: (0.46, 0.65), .rightAnkle: (0.47, 0.84),
                .leftKnee: (0.56, 0.645), .leftAnkle: (0.56, 0.84),
            ])]
        ),
        Pose(
            id: "beach-run",
            name: "Chạy trên cát",
            summary: "Chạy về phía máy, một gối nâng cao. Năng động, tràn sức sống.",
            category: .beach, subjects: [.female, .male], framing: .fullBody,
            angle: .low, lens: 0.5,
            expression: "Cười thật tươi, như đang chạy về phía người mình thương.",
            tips: [
                "Chạy chậm thôi, người chụp giữ nút để chụp liên tục.",
                "Chạy dọc mép nước để có bọt sóng phía sau.",
                "Chọn tấm có một chân đang co lên cao nhất.",
            ],
            bodies: [standing.with([
                .rightElbow: (0.30, 0.33), .rightWrist: (0.36, 0.25),
                .leftElbow: (0.70, 0.38), .leftWrist: (0.66, 0.47),
                .rightKnee: (0.44, 0.56), .rightAnkle: (0.45, 0.70),
                .leftKnee: (0.57, 0.65), .leftAnkle: (0.59, 0.83),
            ])]
        ),
        Pose(
            id: "hands-behind-head",
            name: "Thư giãn tay sau đầu",
            summary: "Hai tay vòng ra sau đầu, vai mở rộng. Thoải mái, phóng khoáng.",
            category: .sunset, subjects: [.male, .female], framing: .fullBody,
            angle: .low, lens: 1,
            expression: "Nhắm mắt, ngẩng mặt đón nắng, cười mãn nguyện.",
            tips: [
                "Mở rộng khuỷu tay sang hai bên để ngực và vai trông rộng hơn.",
                "Đo sáng theo trời để có ánh viền vàng quanh người.",
                "Hơi dồn trọng tâm sang một chân để dáng không bị đơ.",
            ],
            bodies: [standing.with([
                .nose: (0.50, 0.165),
                .rightElbow: (0.24, 0.15), .rightWrist: (0.44, 0.13),
                .leftElbow: (0.76, 0.15), .leftWrist: (0.56, 0.13),
            ])]
        ),
        Pose(
            id: "reach-sun",
            name: "Vươn tay chạm nắng",
            summary: "Một tay giơ thẳng lên trời như đang chạm vào mặt trời.",
            category: .sunset, subjects: [.female, .male], framing: .fullBody,
            angle: .low, lens: 0.5,
            expression: "Ngước nhìn theo bàn tay, miệng cười.",
            tips: [
                "Lùi hoặc ngồi thấp xuống để bàn tay chạm đúng vào mặt trời trong khung hình.",
                "Mở xoè các ngón tay để nắng xuyên qua kẽ tay.",
                "Kiễng nhẹ chân để người trông cao và thon hơn.",
            ],
            bodies: [standing.with([
                .nose: (0.51, 0.165),
                .leftElbow: (0.67, 0.15), .leftWrist: (0.70, 0.04),
                .leftKnee: (0.56, 0.65), .leftAnkle: (0.55, 0.84),
            ])]
        ),
        Pose(
            id: "blow-kiss",
            name: "Hôn gió",
            summary: "Đưa tay từ môi ra phía trước như gửi một nụ hôn gió.",
            category: .sunset, subjects: [.female], framing: .fullBody,
            angle: .eyeLevel, lens: 2,
            expression: "Chu môi nhẹ, mắt nhìn thẳng ống kính, hơi nghiêng đầu.",
            tips: [
                "Chụp liên tục từ lúc tay chạm môi tới lúc tay đưa ra hết.",
                "Dùng 2x để hậu cảnh hoàng hôn to và mềm hơn.",
                "Tay kia có thể cầm túi hoặc vịn váy.",
            ],
            bodies: [standing.with([
                .nose: (0.51, 0.17),
                .rightElbow: (0.27, 0.27), .rightWrist: (0.17, 0.20),
            ])]
        ),
        Pose(
            id: "face-frame",
            name: "Ôm mặt cười",
            summary: "Hai bàn tay ôm nhẹ hai bên má. Đáng yêu, rất hợp ảnh cận.",
            category: .cafe, subjects: [.female], framing: .halfBody,
            angle: .high, lens: 1,
            expression: "Cười híp mắt hoặc phồng má.",
            tips: [
                "Lòng bàn tay chạm nhẹ vào má, đừng ép mặt.",
                "Giơ máy cao hơn mặt một chút để mặt thon và mắt to hơn.",
                "Ngồi gần cửa sổ để có ánh sáng mềm.",
            ],
            bodies: [halfBody.with([
                .rightElbow: (0.20, 0.60), .rightWrist: (0.40, 0.33),
                .leftElbow: (0.80, 0.60), .leftWrist: (0.60, 0.33),
            ])]
        ),
        Pose(
            id: "coffee-sip",
            name: "Nâng ly cà phê",
            summary: "Hai tay nâng ly trước ngực, như sắp nhấp một ngụm.",
            category: .cafe, subjects: [.female, .male], framing: .halfBody,
            angle: .eyeLevel, lens: 2,
            expression: "Nhìn vào ly hoặc nhìn ra cửa sổ, môi hơi cười.",
            tips: [
                "Cầm ly bằng cả hai tay để dáng mềm mại hơn.",
                "Để ly ngang cằm, đừng che mất khuôn mặt.",
                "Lấy nét vào mắt, để quán phía sau nhoè nhẹ.",
            ],
            bodies: [halfBody.with([
                .rightElbow: (0.26, 0.66), .rightWrist: (0.44, 0.48),
                .leftElbow: (0.74, 0.66), .leftWrist: (0.56, 0.48),
            ])]
        ),
        Pose(
            id: "thinker",
            name: "Suy tư chống cằm",
            summary: "Một tay chống cằm, tay kia đỡ khuỷu. Trầm tư, có chiều sâu.",
            category: .cafe, subjects: [.male, .female], framing: .halfBody,
            angle: .side45, lens: 2,
            expression: "Nhìn xa hoặc nhìn xuống, mặt hơi nghiêng.",
            tips: [
                "Ngón trỏ chạm nhẹ vào cằm, các ngón khác co lại tự nhiên.",
                "Đứng lệch 45° để gương mặt có khối và bóng đổ.",
                "Hợp với ảnh đen trắng.",
            ],
            bodies: [halfBody.with([
                .nose: (0.48, 0.31),
                .rightElbow: (0.32, 0.70), .rightWrist: (0.45, 0.38),
                .leftElbow: (0.74, 0.66), .leftWrist: (0.36, 0.68),
            ])]
        ),
    ]

    // MARK: - Dáng ngồi

    private static let moreSeated: [Pose] = [
        Pose(
            id: "sit-steps",
            name: "Ngồi bậc thềm",
            summary: "Ngồi trên bậc thềm, khuỷu tay tì lên gối. Chill, đậm chất đường phố.",
            category: .street, subjects: [.female, .male], framing: .fullBody,
            angle: .eyeLevel, lens: 1,
            expression: "Nhìn thẳng hoặc nhìn sang bên, cười nhẹ.",
            tips: [
                "Người chụp hạ máy ngang tầm mắt người ngồi, đừng chụp từ trên xuống.",
                "Đặt hai chân lệch bậc để dáng có nhịp điệu.",
                "Tìm bậc thềm có hoa văn hoặc tường màu phía sau.",
            ],
            bodies: [Skeleton.pts([
                .nose: (0.50, 0.29), .neck: (0.50, 0.36),
                .rightShoulder: (0.37, 0.375), .leftShoulder: (0.63, 0.375),
                .rightElbow: (0.36, 0.49), .leftElbow: (0.64, 0.49),
                .rightWrist: (0.40, 0.61), .leftWrist: (0.60, 0.61),
                .root: (0.50, 0.58), .rightHip: (0.43, 0.58), .leftHip: (0.57, 0.58),
                .rightKnee: (0.40, 0.62), .leftKnee: (0.60, 0.62),
                .rightAnkle: (0.41, 0.80), .leftAnkle: (0.59, 0.80),
            ])]
        ),
        Pose(
            id: "squat",
            name: "Ngồi xổm streetwear",
            summary: "Ngồi xổm, hai khuỷu tay tì lên đầu gối. Ngầu, hợp đồ streetwear.",
            category: .street, subjects: [.male], framing: .fullBody,
            angle: .eyeLevel, lens: 0.5,
            expression: "Mặt lạnh, nhìn thẳng ống kính.",
            tips: [
                "Dùng 0.5x và để máy sát đất để giày và quần áo nổi bật.",
                "Hai đầu gối mở rộng, lưng hơi cong về trước.",
                "Hợp với ngõ hẻm, tường graffiti hoặc bãi đỗ xe.",
            ],
            bodies: [Skeleton.pts([
                .nose: (0.50, 0.36), .neck: (0.50, 0.43),
                .rightShoulder: (0.38, 0.445), .leftShoulder: (0.62, 0.445),
                .rightElbow: (0.35, 0.55), .leftElbow: (0.65, 0.55),
                .rightWrist: (0.44, 0.63), .leftWrist: (0.56, 0.63),
                .root: (0.50, 0.62), .rightHip: (0.44, 0.62), .leftHip: (0.56, 0.62),
                .rightKnee: (0.36, 0.60), .leftKnee: (0.64, 0.60),
                .rightAnkle: (0.42, 0.80), .leftAnkle: (0.58, 0.80),
            ])]
        ),
        Pose(
            id: "hug-knees",
            name: "Ôm gối ngắm biển",
            summary: "Ngồi trên cát, hai tay ôm gối. Bình yên, hơi chút mơ màng.",
            category: .beach, subjects: [.female], framing: .fullBody,
            angle: .side45, lens: 1,
            expression: "Tựa cằm lên gối, mắt nhìn ra biển.",
            tips: [
                "Người chụp đứng lệch 45° và hạ thấp máy ngang tầm người ngồi.",
                "Để đường chân trời đi qua vai, đừng cắt ngang đầu.",
                "Buổi sáng sớm hoặc chiều muộn sẽ có ánh sáng đẹp nhất.",
            ],
            bodies: [Skeleton.pts([
                .nose: (0.50, 0.40), .neck: (0.50, 0.47),
                .rightShoulder: (0.38, 0.485), .leftShoulder: (0.62, 0.485),
                .rightElbow: (0.36, 0.58), .leftElbow: (0.64, 0.58),
                .rightWrist: (0.48, 0.60), .leftWrist: (0.52, 0.60),
                .root: (0.50, 0.70), .rightHip: (0.44, 0.70), .leftHip: (0.56, 0.70),
                .rightKnee: (0.45, 0.55), .leftKnee: (0.55, 0.55),
                .rightAnkle: (0.44, 0.76), .leftAnkle: (0.56, 0.76),
            ])]
        ),
    ]

    // MARK: - Cặp đôi bổ sung

    private static let moreCouples: [Pose] = [
        Pose(
            id: "couple-foreheads",
            name: "Chạm trán",
            summary: "Hai người tựa trán vào nhau, khung nửa người. Ngọt ngào, riêng tư.",
            category: .sunset, subjects: [.couple], framing: .halfBody,
            angle: .eyeLevel, lens: 2,
            expression: "Nhắm mắt hoặc nhìn nhau cười.",
            tips: [
                "Đặt hai người ngược sáng để có viền nắng quanh tóc.",
                "Chừa nhiều khoảng trời phía trên cho ảnh thoáng.",
                "Tay có thể nắm nhau hoặc ôm nhẹ eo.",
            ],
            bodies: [
                halfBody.transformed(scale: 0.65, center: CGPoint(x: 0.32, y: 0.58)).with([
                    .nose: (0.45, 0.45),
                ]),
                halfBody.transformed(scale: 0.6, center: CGPoint(x: 0.68, y: 0.62)).with([
                    .nose: (0.55, 0.47),
                ]),
            ]
        ),
        Pose(
            id: "couple-back-to-back",
            name: "Tựa lưng khoanh tay",
            summary: "Đứng sát vai nhau, cùng khoanh tay. Cool như cặp đôi trong phim.",
            category: .street, subjects: [.couple], framing: .fullBody,
            angle: .low, lens: 1,
            expression: "Cả hai cùng mặt lạnh, hoặc một người cười một người nghiêm.",
            tips: [
                "Hai người quay lưng chếch vào nhau, vai chạm vai.",
                "Mặc đồ cùng tông màu để ảnh đồng bộ.",
                "Chụp góc thấp để cả hai trông cao hơn.",
            ],
            bodies: [
                crossedArms.transformed(scale: 0.85, center: CGPoint(x: 0.35, y: 0.52)),
                crossedArms.transformed(scale: 0.8, center: CGPoint(x: 0.65, y: 0.54)),
            ]
        ),
        Pose(
            id: "couple-jump",
            name: "Cùng bật nhảy",
            summary: "Hai người cùng nhảy lên, tay chữ V. Vui hết nấc.",
            category: .beach, subjects: [.couple], framing: .fullBody,
            angle: .low, lens: 0.5,
            expression: "Cười to, hò hét càng tốt.",
            tips: [
                "Đếm 1-2-3 thật to để cả hai nhảy cùng lúc.",
                "Bật hẹn giờ kèm chụp liên tục rồi chọn tấm cả hai cùng lên cao nhất.",
                "Người chụp ngồi sát đất để cả hai trông như bay.",
            ],
            bodies: [
                jumping.transformed(scale: 0.8, center: CGPoint(x: 0.31, y: 0.52)),
                jumping.transformed(scale: 0.8, center: CGPoint(x: 0.69, y: 0.52)),
            ]
        ),
    ]
}
