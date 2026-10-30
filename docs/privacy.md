# Nemro Privacy Policy / Chính sách riêng tư

**Effective date / Ngày hiệu lực:** 2026-10-30

**App version / Phiên bản:** 0.4.0

Nemro is a local-first educational app. This policy explains what the app stores, what it does not collect, and how the Lab, Live, and Insights features handle data.

Nemro là ứng dụng giáo dục ưu tiên cục bộ. Chính sách này giải thích ứng dụng lưu gì, không thu thập gì và cách Lab, Live và Insights xử lý dữ liệu.

## Summary / Tóm tắt

- No account, no ads, no analytics, no tracking.
- The release build has no `INTERNET` permission.
- Settings and optional session history are stored on your device.
- The Lab includes read-only EEG samples and a bundled decoder that run on-device; neither is collected from you.
- Live opens the camera only after you tap Start. Frames are processed on-device and are not recorded, stored, or uploaded.
- Live does not request microphone, storage, or media-library permission.
- Saved Live summaries are opt-in; you can delete one session, clear the camera baseline, or delete all local data in **Settings → Data**.

- Không tài khoản, không quảng cáo, không analytics, không tracking.
- Bản release không có quyền `INTERNET`.
- Cài đặt và lịch sử phiên tùy chọn được lưu trên thiết bị.
- Lab có sẵn các mẫu EEG chỉ đọc và bộ giải mã đi kèm, chạy trên thiết bị; cả hai đều không được thu thập từ bạn.
- Live chỉ mở camera sau khi bạn nhấn Bắt đầu. Khung hình được xử lý trên thiết bị, không bị ghi, lưu hay tải lên.
- Live không yêu cầu quyền micro, bộ nhớ hay thư viện media.
- Tóm tắt phiên Live là tùy chọn; bạn có thể xóa từng phiên, xóa ngưỡng camera hoặc xóa toàn bộ dữ liệu cục bộ trong **Cài đặt → Dữ liệu**.

## What is stored / Dữ liệu được lưu

Version 0.4.0 stores only on this device:

- your selected language (`vi` or `en`);
- your theme choice (system, light, or dark);
- whether onboarding has been completed;
- your preferred camera lens (front or back);
- an optional personal camera baseline: two numbers (10th and 90th percentile of a short calibration);
- if you turn on **Save Live session summaries**: the average proxy score, duration, frame count, and end time of each completed Live session. History is capped at 50 sessions.

Phiên bản 0.4.0 chỉ lưu trên thiết bị:

- ngôn ngữ đã chọn (`vi` hoặc `en`);
- lựa chọn giao diện (theo hệ thống, sáng hoặc tối);
- trạng thái đã hoàn tất onboarding;
- lựa chọn camera trước hoặc sau;
- ngưỡng camera cá nhân tùy chọn: hai con số (phân vị 10 và 90 của một lần hiệu chuẩn ngắn);
- nếu bạn bật **Lưu tóm tắt phiên Live**: điểm proxy trung bình, thời lượng, số khung và thời điểm kết thúc của mỗi phiên Live đã hoàn tất. Lịch sử được giới hạn tối đa 50 phiên.

No EEG is recorded from you. The Lab replays read-only excerpts bundled with the app, and the decoder processes those excerpts locally. The app does not store your Lab predictions. The S002 excerpt is a cross-subject demo; the Lab does not attach S001's accuracy to it.

Không EEG nào của bạn bị ghi lại. Lab phát lại các đoạn dữ liệu chỉ đọc đi kèm ứng dụng và bộ giải mã xử lý các đoạn đó ngay trên thiết bị. Ứng dụng không lưu dự đoán Lab của bạn. Mẫu S002 là demo cross-subject; Lab không gán độ chính xác của S001 cho mẫu này.

## On-device AI decoder / Bộ giải mã AI trên thiết bị

Version 0.4.0 includes a small logistic-regression model in the Lab. The model file and the EEG excerpts are bundled with the app. Feature extraction and inference run entirely on the device; no EEG, prediction, or confidence score is uploaded. The decoder is a research demo, not a medical device and not mind reading. See [`model-card.md`](model-card.md) for its held-out accuracy, confidence interval, and limitations.

Phiên bản 0.4.0 có một mô hình hồi quy logistic nhỏ trong Lab. Tệp mô hình và các mẫu EEG đi kèm ứng dụng. Việc trích xuất đặc trưng và suy luận chạy hoàn toàn trên thiết bị; không EEG, dự đoán hay điểm tin cậy nào được tải lên. Bộ giải mã là demo nghiên cứu, không phải thiết bị y tế và không đọc suy nghĩ. Xem [`model-card.md`](model-card.md) để biết độ chính xác trên tập giữ lại, khoảng tin cậy và các giới hạn.

## Live camera proxy / Proxy camera Live

Live is a rough, transparent heuristic, not face or eye tracking and not a measurement of attention or medical state.

- The camera is opened only after you tap **Start** in Live. Opening the screen does not start the camera.
- Frames are downsampled to a small luminance grid and processed on-device. The score combines central contrast, lighting, and frame-to-frame stability.
- No video or images are recorded, stored, or uploaded.
- The camera is released when you tap **Stop** or when the app leaves the foreground.
- The app does not request microphone, storage, or media-library access. The Android manifest removes the camera plugin's `RECORD_AUDIO`, storage, and media-library declarations; the only runtime permission for this feature is `CAMERA`.
- A calibration baseline (two numbers) can be saved locally and cleared from the Live screen. It changes only how the score is presented; it is not a brain measurement.
- Saved Live session summaries are off by default. Turn them on in Settings if you want Insights history.

Live là một heuristic thô, minh bạch, không theo dõi khuôn mặt hay mắt và không đo chú ý hay tình trạng y tế.

- Camera chỉ được mở sau khi bạn nhấn **Bắt đầu** trong Live. Mở màn hình không bật camera.
- Khung hình được thu nhỏ thành lưới độ sáng nhỏ và xử lý trên thiết bị. Điểm số kết hợp độ tương phản vùng trung tâm, ánh sáng và độ ổn định giữa các khung.
- Không video hay hình ảnh nào bị ghi, lưu hoặc tải lên.
- Camera được giải phóng khi bạn nhấn **Dừng** hoặc khi ứng dụng rời khỏi màn hình.
- Ứng dụng không yêu cầu quyền micro, bộ nhớ hay thư viện media. Android manifest loại bỏ các khai báo `RECORD_AUDIO`, bộ nhớ và thư viện media của plugin camera; quyền runtime duy nhất cho tính năng này là `CAMERA`.
- Ngưỡng hiệu chuẩn (hai con số) có thể được lưu cục bộ và xóa từ màn hình Live. Nó chỉ thay đổi cách hiển thị điểm số, không phải phép đo não.
- Tóm tắt phiên Live mặc định tắt. Bật trong Cài đặt nếu bạn muốn có lịch sử trong Insights.

## Insights and export / Insights và xuất dữ liệu

- Insights reads only the saved Live summaries described above.
- Deleting one session removes exactly that summary after a confirmation dialog.
- **Export CSV** writes a plain CSV file to the app's temporary directory and opens the Android share sheet. The app itself does not upload the file; whatever app or service you choose in the share sheet handles it under its own policy.
- CSV timestamps are written in UTC with a `Z` suffix so the file is unambiguous across timezones.

- Insights chỉ đọc các tóm tắt Live đã lưu ở trên.
- Xóa một phiên sẽ xóa đúng tóm tắt đó sau hộp thoại xác nhận.
- **Xuất CSV** ghi một tệp CSV vào thư mục tạm của ứng dụng rồi mở bảng chia sẻ Android. Bản thân ứng dụng không tải tệp lên; ứng dụng hoặc dịch vụ bạn chọn trong bảng chia sẻ xử lý tệp theo chính sách riêng của họ.
- Dấu thời gian trong CSV được ghi theo UTC với hậu tố `Z` để tệp rõ ràng giữa các múi giờ.

## What is not collected / Dữ liệu không thu thập

Nemro does not collect names, email addresses, contacts, location, advertising identifiers, or usage analytics. There is no account system and no third-party analytics SDK. The release build does not have the `INTERNET` permission. Debug builds add it only for Flutter hot reload.

Nemro không thu thập tên, email, danh bạ, vị trí, mã nhận dạng quảng cáo hay số liệu sử dụng. Không có hệ thống tài khoản và không có SDK analytics bên thứ ba. Bản release không có quyền `INTERNET`. Bản debug chỉ thêm quyền này để Flutter hot reload.

## Storage and deletion / Lưu trữ và xóa dữ liệu

Settings, the optional baseline, and saved session summaries live in the app's private storage. Android cloud backup is disabled, and Android 12+ device-to-device transfer is excluded with `dataExtractionRules`, so this data is not copied to Google backup or another device. Use **Settings → Data → Delete all local data** to remove everything and reset onboarding. Use **Clear baseline** on the Live screen or **Delete session** in Insights for narrower deletion.

Cài đặt, ngưỡng tùy chọn và tóm tắt phiên đã lưu nằm trong vùng lưu trữ riêng của ứng dụng. Sao lưu đám mây Android bị tắt và tính năng chuyển dữ liệu sang thiết bị khác trên Android 12+ bị loại trừ bằng `dataExtractionRules`, nên dữ liệu này không được sao chép lên Google backup hay thiết bị khác. Dùng **Cài đặt → Dữ liệu → Xóa toàn bộ dữ liệu cục bộ** để xóa mọi thứ và đặt lại onboarding. Dùng **Xóa ngưỡng** trên màn hình Live hoặc **Xóa phiên** trong Insights để xóa phạm vi hẹp hơn.

## Sharing / Chia sẻ

Nemro does not share data with third parties. If you tap an external link (for example, the GitHub repository), your browser or the external app handles that request under its own privacy policy. CSV export is user-initiated and goes through the Android share sheet.

Nemro không chia sẻ dữ liệu với bên thứ ba. Nếu bạn mở liên kết ngoài (ví dụ repository GitHub), trình duyệt hoặc ứng dụng bên ngoài xử lý yêu cầu đó theo chính sách riêng của họ. Việc xuất CSV do bạn chủ động thực hiện và đi qua bảng chia sẻ Android.

## Children / Trẻ em

Nemro is an educational tool, not a child-directed service. It does not knowingly collect personal information from anyone, including children.

Nemro là công cụ giáo dục, không phải dịch vụ hướng đến trẻ em. Ứng dụng không cố ý thu thập thông tin cá nhân của bất kỳ ai, kể cả trẻ em.

## Medical disclaimer / Miễn trừ y tế

Nemro is not a medical device. It does not diagnose, treat, cure, or prevent any condition, and it is not a substitute for professional medical advice. The Live camera proxy is not an attention test, fatigue monitor, or mental-state measurement. The Lab decoder is not a mind reader.

Nemro không phải thiết bị y tế. Ứng dụng không chẩn đoán, điều trị, chữa khỏi hay phòng ngừa bất kỳ tình trạng nào và không thay thế tư vấn y tế chuyên môn. Proxy camera Live không phải bài kiểm tra chú ý, công cụ theo dõi mệt mỏi hay phép đo trạng thái tinh thần. Bộ giải mã Lab không đọc suy nghĩ.

## Changes / Thay đổi

If this policy changes, the updated version will be published in the repository and linked from the app. Material changes will be noted in the changelog.

Nếu chính sách thay đổi, phiên bản mới sẽ được công bố trong repository và liên kết từ ứng dụng. Các thay đổi quan trọng sẽ được ghi trong changelog.

## Contact / Liên hệ

Open an issue at <https://github.com/herbalblitz/nemro/issues>.

Mở issue tại <https://github.com/herbalblitz/nemro/issues>.
