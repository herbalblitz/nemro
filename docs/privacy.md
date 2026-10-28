# Nemro Privacy Policy / Chính sách riêng tư

**Effective date / Ngày hiệu lực:** 2026-10-28

**App version / Phiên bản:** 0.3.0

Nemro is a local-first educational app. This policy explains what the app stores, what it does not collect, and how the Lab and Live features handle data.

Nemro là ứng dụng giáo dục ưu tiên cục bộ. Chính sách này giải thích ứng dụng lưu gì, không thu thập gì và cách Lab và Live xử lý dữ liệu.

## Summary / Tóm tắt

- No account, no ads, no analytics, no tracking.
- The release build has no `INTERNET` permission.
- Settings are stored on your device.
- The Lab includes a read-only EEG sample and a bundled decoder that run on-device; neither is collected from you.
- Live opens the camera only after you tap Start. Frames are processed on-device and are not recorded, stored, or uploaded.
- Live does not request microphone or storage permission.
- You can delete local data in **Settings → Data**.

- Không tài khoản, không quảng cáo, không analytics, không tracking.
- Bản release không có quyền `INTERNET`.
- Cài đặt được lưu trên thiết bị.
- Lab có sẵn một mẫu EEG chỉ đọc và bộ giải mã đi kèm, chạy trên thiết bị; cả hai đều không được thu thập từ bạn.
- Live chỉ mở camera sau khi bạn nhấn Bắt đầu. Khung hình được xử lý trên thiết bị, không bị ghi, lưu hay tải lên.
- Live không yêu cầu quyền micro hay quyền truy cập bộ nhớ.
- Bạn có thể xóa dữ liệu cục bộ trong **Cài đặt → Dữ liệu**.

## What is stored / Dữ liệu được lưu

Version 0.3.0 stores:

- your selected language (`vi` or `en`);
- your theme choice (system, light, or dark);
- whether onboarding has been completed.

Phiên bản 0.3.0 lưu:

- ngôn ngữ đã chọn (`vi` hoặc `en`);
- lựa chọn giao diện (theo hệ thống, sáng hoặc tối);
- trạng thái đã hoàn tất onboarding.

No EEG is recorded from you in 0.3.0. The Lab replay uses a read-only excerpt bundled with the app, and the decoder processes that excerpt locally. The app does not store your predictions. A Live session summary (average proxy score, duration, and frame count) is shown on screen but is not saved in 0.3.0. Future versions may store Lab and Live session results locally so that the Insights screen can show your history; those records will remain on the device unless you explicitly export them.

Phiên bản 0.3.0 không ghi lại EEG của bạn. Màn hình Lab phát lại một đoạn dữ liệu chỉ đọc đi kèm ứng dụng và bộ giải mã xử lý đoạn dữ liệu đó ngay trên thiết bị. Ứng dụng không lưu dự đoán của bạn. Tóm tắt phiên Live (điểm proxy trung bình, thời lượng và số khung) được hiển thị trên màn hình nhưng chưa được lưu trong 0.3.0. Các phiên bản sau có thể lưu kết quả Lab và Live cục bộ để màn hình Lịch sử hiển thị; các bản ghi này ở lại trên thiết bị trừ khi bạn chủ động xuất.

## On-device AI decoder / Bộ giải mã AI trên thiết bị

Version 0.3.0 includes a small logistic-regression model in the Lab. The model file and the EEG excerpt are bundled with the app. Feature extraction and inference run entirely on the device; no EEG, prediction, or confidence score is uploaded. The decoder is a research demo, not a medical device and not mind reading. See [`model-card.md`](model-card.md) for its held-out accuracy and limitations.

Phiên bản 0.3.0 có một mô hình hồi quy logistic nhỏ trong Lab. Tệp mô hình và mẫu EEG đi kèm ứng dụng. Việc trích xuất đặc trưng và suy luận chạy hoàn toàn trên thiết bị; không EEG, dự đoán hay điểm tin cậy nào được tải lên. Bộ giải mã là demo nghiên cứu, không phải thiết bị y tế và không đọc suy nghĩ. Xem [`model-card.md`](model-card.md) để biết độ chính xác trên tập giữ lại và các giới hạn.

## Live camera proxy / Proxy camera Live

Live is available in 0.3.0. It is a rough, transparent heuristic, not face or eye tracking and not a measurement of attention or medical state.

- The camera is opened only after you tap **Start** in Live. Opening the screen does not start the camera.
- Frames are downsampled to a small luminance grid and processed on-device. The score combines central contrast, lighting, and frame-to-frame stability.
- No video or images are recorded, stored, or uploaded.
- The camera is released when you tap **Stop** or when the app leaves the foreground.
- The app does not request microphone or storage access. The Android manifest removes the camera plugin's `RECORD_AUDIO` and `WRITE_EXTERNAL_STORAGE` declarations, along with the implied `READ_EXTERNAL_STORAGE` permission; the only runtime permission for this feature is `CAMERA`.
- Live session summaries are not saved in 0.3.0.

Live đã có trong 0.3.0. Đây là một heuristic thô, minh bạch, không theo dõi khuôn mặt hay mắt và không đo chú ý hay tình trạng y tế.

- Camera chỉ được mở sau khi bạn nhấn **Bắt đầu** trong Live. Mở màn hình không bật camera.
- Khung hình được thu nhỏ thành lưới độ sáng nhỏ và xử lý trên thiết bị. Điểm số kết hợp độ tương phản vùng trung tâm, ánh sáng và độ ổn định giữa các khung.
- Không video hay hình ảnh nào bị ghi, lưu hoặc tải lên.
- Camera được giải phóng khi bạn nhấn **Dừng** hoặc khi ứng dụng rời khỏi màn hình.
- Ứng dụng không yêu cầu quyền micro hay bộ nhớ. Android manifest loại bỏ khai báo `RECORD_AUDIO` và `WRITE_EXTERNAL_STORAGE` của plugin camera, cùng quyền `READ_EXTERNAL_STORAGE` đi kèm; quyền runtime duy nhất cho tính năng này là `CAMERA`.
- Tóm tắt phiên Live chưa được lưu trong 0.3.0.

## What is not collected / Dữ liệu không thu thập

Nemro does not collect names, email addresses, contacts, location, advertising identifiers, or usage analytics. There is no account system and no third-party analytics SDK.

Nemro không thu thập tên, email, danh bạ, vị trí, mã nhận dạng quảng cáo hay số liệu sử dụng. Không có hệ thống tài khoản và không có SDK analytics bên thứ ba.

## Storage and deletion / Lưu trữ và xóa dữ liệu

Settings live in the app's private storage. Android cloud backup is disabled for the app, so this data is not copied to Google backup. Use **Settings → Data → Delete all local data** to remove them and reset onboarding. Future session databases will be included in this deletion.

Cài đặt nằm trong vùng lưu trữ riêng của ứng dụng. Sao lưu đám mây Android bị tắt cho ứng dụng, nên dữ liệu này không được sao chép lên Google backup. Dùng **Cài đặt → Dữ liệu → Xóa toàn bộ dữ liệu cục bộ** để xóa và đặt lại onboarding. Cơ sở dữ liệu phiên trong tương lai sẽ được bao gồm trong thao tác xóa này.

## Sharing / Chia sẻ

Nemro does not share data with third parties. If you tap an external link (for example, the GitHub repository), your browser or the external app handles that request under its own privacy policy.

Nemro không chia sẻ dữ liệu với bên thứ ba. Nếu bạn mở liên kết ngoài (ví dụ repository GitHub), trình duyệt hoặc ứng dụng bên ngoài xử lý yêu cầu đó theo chính sách riêng của họ.

## Children / Trẻ em

Nemro is an educational tool, not a child-directed service. It does not knowingly collect personal information from anyone, including children.

Nemro là công cụ giáo dục, không phải dịch vụ hướng đến trẻ em. Ứng dụng không cố ý thu thập thông tin cá nhân của bất kỳ ai, kể cả trẻ em.

## Medical disclaimer / Miễn trừ y tế

Nemro is not a medical device. It does not diagnose, treat, cure, or prevent any condition, and it is not a substitute for professional medical advice. The Live camera proxy is not an attention test, fatigue monitor, or mental-state measurement.

Nemro không phải thiết bị y tế. Ứng dụng không chẩn đoán, điều trị, chữa khỏi hay phòng ngừa bất kỳ tình trạng nào và không thay thế tư vấn y tế chuyên môn. Proxy camera Live không phải bài kiểm tra chú ý, công cụ theo dõi mệt mỏi hay phép đo trạng thái tinh thần.

## Changes / Thay đổi

If this policy changes, the updated version will be published in the repository and linked from the app. Material changes will be noted in the changelog.

Nếu chính sách thay đổi, phiên bản mới sẽ được công bố trong repository và liên kết từ ứng dụng. Các thay đổi quan trọng sẽ được ghi trong changelog.

## Contact / Liên hệ

Open an issue at <https://github.com/herbalblitz/nemro/issues>.

Mở issue tại <https://github.com/herbalblitz/nemro/issues>.
