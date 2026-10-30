// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Nemro';

  @override
  String get appTagline => 'Vòng lặp AI–não trong tầm tay';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingLanguageTitle => 'Chọn ngôn ngữ';

  @override
  String get onboardingLanguageSubtitle =>
      'Bạn có thể đổi bất cứ lúc nào trong Cài đặt.';

  @override
  String get onboardingConsentTitle => 'Trước khi bắt đầu';

  @override
  String get onboardingConsentPoint1 => 'Nemro không đọc suy nghĩ.';

  @override
  String get onboardingConsentPoint2 => 'Đây không phải thiết bị y tế.';

  @override
  String get onboardingConsentPoint3 =>
      'Dữ liệu được lưu trên thiết bị của bạn.';

  @override
  String get onboardingConsentPoint4 =>
      'Camera xử lý trên thiết bị, không ghi hay tải video lên.';

  @override
  String get onboardingConsentCheckbox => 'Tôi đã hiểu và đồng ý';

  @override
  String get onboardingContinue => 'Đồng ý và tiếp tục';

  @override
  String get homeHeadline => 'Vòng lặp AI–não, trong tầm tay.';

  @override
  String get homeSubheadline =>
      'Phát lại EEG thật, xem bộ giải mã trên thiết bị ước lượng bàn tay đang tưởng tượng và thử proxy ánh sáng/độ tương phản/độ ổn định bằng camera.';

  @override
  String get homeLabTitle => 'Lab';

  @override
  String get homeLabSubtitle => 'Phát lại + giải mã trên thiết bị';

  @override
  String get homeLabAction => 'Mở Lab';

  @override
  String get homeLabBadge => 'DEMO';

  @override
  String get homeLiveTitle => 'Live';

  @override
  String get homeLiveSubtitle => 'Proxy tín hiệu camera';

  @override
  String get homeLiveAction => 'Mở Live';

  @override
  String get homeLiveBadge => 'DEMO';

  @override
  String get homeRecentTitle => 'Phiên gần nhất';

  @override
  String get homeRecentEmpty =>
      'Chưa có phiên nào được lưu. Hãy thử bộ giải mã trong Lab.';

  @override
  String get homeRecentAction => 'Mở Lab';

  @override
  String get homeFooter =>
      'Mã nguồn mở. Không phải thiết bị y tế. Không đọc suy nghĩ.';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navInsights => 'Lịch sử';

  @override
  String get navLearn => 'Học';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get labTitle => 'Lab';

  @override
  String get labReplayTitle => 'Phát lại EEG';

  @override
  String get labReplayIntro =>
      'Cửa sổ 60 giây thật từ bộ dữ liệu vận động–tưởng tượng của PhysioNet. Nhấn phát để xem tín hiệu thô, các mốc nhiệm vụ và kết quả giải mã trên thiết bị.';

  @override
  String get labReplayBadge => 'PHÁT LẠI';

  @override
  String labChannelSummary(int count, int rate) {
    return '$count kênh · $rate Hz';
  }

  @override
  String labWindowLabel(int seconds) {
    return 'Cửa sổ $seconds giây';
  }

  @override
  String get labPlay => 'Phát';

  @override
  String get labPause => 'Tạm dừng';

  @override
  String get labRestart => 'Chạy lại';

  @override
  String get labNow => 'Hiện tại';

  @override
  String get labRest => 'Nghỉ';

  @override
  String get labLeftFist => 'Tưởng tượng nắm tay trái';

  @override
  String get labRightFist => 'Tưởng tượng nắm tay phải';

  @override
  String get labDecoderTitle => 'Bộ giải mã AI';

  @override
  String get labDecoderBody =>
      'Một mô hình nhỏ ước lượng bàn tay đang tưởng tượng từ công suất dải mu/beta. Mô hình chạy hoàn toàn trên thiết bị; không có EEG nào rời khỏi điện thoại.';

  @override
  String get labOnDeviceBadge => 'TRÊN THIẾT BỊ';

  @override
  String labDecoderModel(int count) {
    return 'Hồi quy logistic · công suất mu/beta · $count kênh';
  }

  @override
  String labDecoderTraining(String train, String test) {
    return 'Huấn luyện trên run $train; đánh giá trên run $test.';
  }

  @override
  String labDecoderTrainingLoro(String train) {
    return 'Huấn luyện trên run $train; đánh giá leave-one-run-out.';
  }

  @override
  String labDecoderAccuracy(int percent) {
    return 'Độ chính xác trên run giữ lại: $percent% (ngẫu nhiên 50%)';
  }

  @override
  String labDecoderAccuracyLoro(int percent) {
    return 'Độ chính xác leave-one-run-out: $percent% (ngẫu nhiên 50%)';
  }

  @override
  String labDecoderAccuracyDetail(int trials, int low, int high) {
    return 'n = $trials; khoảng tin cậy Wilson 95%: $low%–$high%.';
  }

  @override
  String labDecoderTrainingCrossSubject(
    String trainingSubject,
    String train,
    String subject,
  ) {
    return 'Huấn luyện trên các run $train của $trainingSubject; chưa đánh giá trên $subject.';
  }

  @override
  String labDecoderCrossSubject(String subject, String trainingSubject) {
    return 'Chỉ là demo cross-subject: không có tuyên bố độ chính xác cho $subject. Kết quả trên tập giữ lại chỉ áp dụng cho $trainingSubject.';
  }

  @override
  String get labDecoderLoading => 'Đang tải mô hình trên thiết bị…';

  @override
  String get labDecoderIdle => 'Nghỉ — bộ giải mã tạm dừng.';

  @override
  String get labDecoderDecoding => 'Đang giải mã cửa sổ này…';

  @override
  String get labDecoderIncomplete => 'Không đủ tín hiệu trong cửa sổ này.';

  @override
  String get labDecoderUnavailable => 'Bộ giải mã không khả dụng.';

  @override
  String get labDecoderPrediction => 'Dự đoán';

  @override
  String get labDecoderMarker => 'Mốc';

  @override
  String get labDecoderLimitations =>
      'Một người tham gia (S001). Chỉ là demo; không phải thiết bị y tế và không đọc suy nghĩ.';

  @override
  String get labDecoderPreprocessingLabel => 'Tiền xử lý';

  @override
  String get labDecoderPreprocessingText =>
      'Cửa sổ 4,1 giây; trừ trung bình từng cửa sổ; cửa sổ Hann; công suất Goertzel; log10; chuẩn hóa đặc trưng.';

  @override
  String get labDecoderLimitationsLabel => 'Giới hạn';

  @override
  String get labDecoderLimitationsText =>
      'Một người tham gia (S001), 30 lượt thử huấn luyện, bài toán tưởng tượng nắm tay nhị phân. Không phải thiết bị y tế và không đọc suy nghĩ.';

  @override
  String get labDatasetTitle => 'Dữ liệu & giấy phép';

  @override
  String get labSourceLabel => 'Nguồn';

  @override
  String get labRecordingLabel => 'Bản ghi';

  @override
  String get labChannelsLabel => 'Tín hiệu';

  @override
  String get labLicenseLabel => 'Giấy phép';

  @override
  String labRunDescription(String subject) {
    return '$subject · lượt 4 · tưởng tượng nắm tay trái/phải';
  }

  @override
  String get labOpenDataset => 'Mở trang dữ liệu';

  @override
  String get labLoading => 'Đang tải EEG…';

  @override
  String get labLoadError => 'Không tải được mẫu EEG.';

  @override
  String get labRetry => 'Thử lại';

  @override
  String get liveTitle => 'Live';

  @override
  String get liveBadge => 'TRÊN THIẾT BỊ';

  @override
  String get insightsTitle => 'Lịch sử';

  @override
  String get insightsEmptyTitle => 'Chưa có dữ liệu';

  @override
  String get insightsEmptySavedOff =>
      'Bật lưu tóm tắt phiên Live trong Cài đặt để giữ chúng ở đây.';

  @override
  String get insightsEmptySavedOn =>
      'Chưa có phiên nào được lưu. Hoàn thành một phiên Live, nó sẽ xuất hiện ở đây.';

  @override
  String get insightsStart => 'Bắt đầu Live';

  @override
  String get insightsSavedTitle => 'Phiên Live đã lưu';

  @override
  String get insightsDelete => 'Xóa phiên';

  @override
  String get insightsDeleteConfirmTitle => 'Xóa phiên này?';

  @override
  String get insightsDeleteConfirmBody =>
      'Tóm tắt phiên sẽ bị xóa khỏi thiết bị này.';

  @override
  String get insightsTrendsTitle => 'Xu hướng';

  @override
  String get insightsTrendCurrentStreak => 'Chuỗi hiện tại';

  @override
  String get insightsTrendLongestStreak => 'Chuỗi dài nhất';

  @override
  String insightsTrendStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days ngày',
      one: '1 ngày',
    );
    return '$_temp0';
  }

  @override
  String get insightsTrendBest => 'Phiên tốt nhất';

  @override
  String get insightsTrendWorst => 'Phiên thấp nhất';

  @override
  String get insightsTrendWeeklyTitle => 'Trung bình theo tuần';

  @override
  String insightsTrendSessions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count phiên',
      one: '1 phiên',
    );
    return '$_temp0';
  }

  @override
  String get insightsExport => 'Xuất CSV';

  @override
  String get insightsExportDone => 'Đã xuất lịch sử phiên.';

  @override
  String get insightsExportFailed => 'Không xuất được lịch sử phiên.';

  @override
  String get learnTitle => 'Học';

  @override
  String get learnSubtitle =>
      'Hiểu đúng về BCI, EEG và giới hạn của công nghệ.';

  @override
  String get lesson1Title => 'Neuron và EEG';

  @override
  String get lesson2Title => 'BCI là gì?';

  @override
  String get lesson3Title => 'Xâm lấn và không xâm lấn';

  @override
  String get lesson4Title => 'Siêu âm, từ trường, ánh sáng';

  @override
  String get lesson5Title => 'WiFi có đọc được não?';

  @override
  String get lesson6Title => 'Đạo đức và quyền riêng tư';

  @override
  String get lesson1Body =>
      'Neuron giao tiếp bằng xung điện rất nhỏ. EEG lắng nghe từ da đầu, thu tín hiệu tổng hợp của hàng triệu neuron cùng lúc — một cửa sổ mờ và nhiễu, không bao giờ là một suy nghĩ đơn lẻ.';

  @override
  String get lesson2Body =>
      'Giao diện não–máy tính biến tín hiệu não thành lệnh hoặc phản hồi: tín hiệu, giải mã, đáp lại. Vòng lặp của Nemro đúng là như vậy — và nó chỉ tốt bằng tín hiệu mà nó đọc được.';

  @override
  String get lesson3Body =>
      'Điện cực cấy ghép nghe rõ từng neuron, nhưng cần phẫu thuật. EEG da đầu an toàn và dễ dùng, nhưng thô và nhiễu. Nemro chỉ dùng phía không xâm lấn — và Live thậm chí không dùng EEG, chỉ dùng proxy camera.';

  @override
  String get lesson4Body =>
      'Siêu âm, MEG và ánh sáng hồng ngoại gần mỗi loại cảm nhận não theo cách khác nhau, đánh đổi độ chính xác lấy chi phí và tính di động. Không loại nào đọc được suy nghĩ — tất cả đều đo tín hiệu gián tiếp và nhiễu.';

  @override
  String get lesson5Body =>
      'Không. Cảm biến Wi-Fi chỉ nhận ra chuyển động và tư thế qua sóng radio bị nhiễu — nó không chạm tới hoạt động não. Mọi sản phẩm quảng cáo đọc suy nghĩ qua Wi-Fi đều là thổi phồng, hoặc lừa đảo.';

  @override
  String get lesson6Body =>
      'Dữ liệu não rất riêng tư, dù nó có nhiễu. Nemro giữ mọi thứ trên thiết bị này: không tài khoản, không theo dõi, không tải lên. Lịch sử phiên là tùy chọn, và bạn có thể xóa bất cứ lúc nào.';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsAppearance => 'Giao diện';

  @override
  String get settingsThemeSystem => 'Theo hệ thống';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsPrivacy => 'Quyền riêng tư';

  @override
  String get settingsPrivacyBody =>
      'Dữ liệu ở lại trên thiết bị. Không tài khoản, không quảng cáo, không tracking.';

  @override
  String get settingsPrivacyPolicy => 'Chính sách riêng tư';

  @override
  String get settingsSaveLiveSummaries => 'Lưu tóm tắt phiên Live';

  @override
  String get settingsSaveLiveSummariesBody =>
      'Khi bật, tóm tắt các phiên Live đã kết thúc được lưu chỉ trên thiết bị này. Tắt để ngừng lưu phiên mới.';

  @override
  String get settingsData => 'Dữ liệu';

  @override
  String get settingsDataBody =>
      'Nemro lưu cài đặt và ngưỡng camera tùy chọn cục bộ. Tóm tắt phiên Live chỉ được lưu khi bạn bật tính năng đó.';

  @override
  String get settingsDeleteData => 'Xóa toàn bộ dữ liệu cục bộ';

  @override
  String get settingsDeleteDataBody =>
      'Thao tác này xóa cài đặt, ngưỡng camera, phiên Live đã lưu và trạng thái onboarding.';

  @override
  String get settingsDeleteDataConfirm => 'Xóa toàn bộ dữ liệu cục bộ?';

  @override
  String get settingsDeleteDataDone => 'Đã xóa dữ liệu cục bộ.';

  @override
  String get settingsDelete => 'Xóa';

  @override
  String get settingsCancel => 'Hủy';

  @override
  String get settingsAbout => 'Giới thiệu';

  @override
  String get settingsVersion => 'Phiên bản';

  @override
  String get settingsLicenses => 'Giấy phép mã nguồn mở';

  @override
  String get aboutTitle => 'Giới thiệu Nemro';

  @override
  String get aboutBody =>
      'Nemro là dự án mã nguồn mở giúp bạn hiểu vòng lặp AI–não: AI giải mã tín hiệu thần kinh, phản hồi lại người dùng, và những giới hạn thật của công nghệ.';

  @override
  String get aboutDisclaimerTitle => 'Tuyên bố miễn trừ';

  @override
  String get aboutDisclaimerBody =>
      'Nemro không phải thiết bị y tế, không đọc suy nghĩ và không thay thế tư vấn y tế.';

  @override
  String get aboutSources => 'Nguồn tham khảo';

  @override
  String get aboutSourceEeg => 'PhysioNet EEG Motor Movement/Imagery Dataset';

  @override
  String get aboutSourceModel => 'Bộ giải mã trên thiết bị';

  @override
  String get aboutSourcePlanned => 'Dự kiến';

  @override
  String get aboutSourceBci => 'BCI Competition IV 2a';

  @override
  String get aboutSourceNote =>
      'Lab đóng gói các đoạn 60 giây từ EEGMMIDB của S001, S002 và S003 (ODC-BY 1.0). Bộ giải mã là hồi quy logistic nhỏ, huấn luyện trên run 8 và 12 của S001 và đánh giá trên run 4: độ chính xác 67%, mức ngẫu nhiên 50%. Các bản phát lại S002 và S003 chỉ là demo khác chủ thể, không có tuyên bố độ chính xác. Chỉ là demo nghiên cứu.';

  @override
  String get aboutRepo => 'Mã nguồn trên GitHub';

  @override
  String get aboutLicense => 'Giấy phép MIT';

  @override
  String get privacyTitle => 'Quyền riêng tư';

  @override
  String privacyIntro(String version) {
    return 'Nemro được thiết kế local-first. Phiên bản $version không có quyền truy cập Internet. Mẫu EEG, bộ giải mã và proxy camera Live chạy hoàn toàn trên thiết bị.';
  }

  @override
  String get privacyDataTitle => 'Dữ liệu nào được lưu?';

  @override
  String get privacyDataBody =>
      'Ngôn ngữ, giao diện, trạng thái onboarding, lựa chọn camera và ngưỡng camera tùy chọn. Tóm tắt phiên Live chỉ được lưu trên thiết bị khi bạn bật lưu trong Cài đặt, và xóa toàn bộ dữ liệu trong Cài đặt sẽ xóa chúng. Bộ giải mã Lab xử lý mẫu đi kèm ngay trên thiết bị; không EEG nào được thu thập từ bạn.';

  @override
  String get privacyDecoderTitle => 'AI trên thiết bị';

  @override
  String get privacyDecoderBody =>
      'Bộ giải mã Lab là một mô hình nhỏ đi kèm ứng dụng. Mô hình chạy cục bộ trên mẫu EEG và dự đoán không rời khỏi thiết bị.';

  @override
  String get privacyCameraTitle => 'Camera';

  @override
  String get privacyCameraBody =>
      'Live chỉ mở camera sau khi bạn nhấn Bắt đầu. Khung hình được thu nhỏ và xử lý trên thiết bị để ước lượng proxy thô từ ánh sáng, độ tương phản và chuyển động. Không video hay hình ảnh nào bị ghi, lưu hoặc tải lên. Một ngưỡng hiệu chuẩn tùy chọn (hai con số) có thể được lưu cục bộ. Camera được giải phóng khi bạn dừng hoặc rời ứng dụng; Nemro không yêu cầu quyền micro hay bộ nhớ.';

  @override
  String get privacyStorageTitle => 'Lưu trữ';

  @override
  String get privacyStorageBody =>
      'Dữ liệu nằm trong vùng riêng của app. Bạn có thể xóa toàn bộ trong Cài đặt.';

  @override
  String get privacySharingTitle => 'Chia sẻ';

  @override
  String get privacySharingBody =>
      'Không có analytics, quảng cáo hay SDK bên thứ ba thu thập dữ liệu. Bộ giải mã và proxy camera đi kèm không gọi máy chủ.';

  @override
  String get privacyContactTitle => 'Liên hệ';

  @override
  String get privacyContactBody => 'Mở issue trên GitHub của dự án.';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonComingSoon => 'Sắp có';

  @override
  String get commonLearnMore => 'Tìm hiểu thêm';

  @override
  String get commonError => 'Có lỗi xảy ra';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get liveStartTitle => 'Proxy tín hiệu camera';

  @override
  String get liveStartBody =>
      'Một proxy thô, chạy trên thiết bị, dựa trên ánh sáng, độ tương phản và chuyển động. Đây không phải đọc suy nghĩ hay đo lường y tế.';

  @override
  String get liveStartBullet1 => 'Camera chỉ bật khi bạn nhấn Bắt đầu.';

  @override
  String get liveStartBullet2 =>
      'Khung hình được xử lý trên thiết bị. Không ghi hay tải video lên.';

  @override
  String get liveStartBullet3 =>
      'Dừng bất cứ lúc nào. Camera được giải phóng khi phiên kết thúc.';

  @override
  String get liveStartButton => 'Bắt đầu phiên camera';

  @override
  String get liveStarting => 'Đang bật camera…';

  @override
  String get liveStartingBody =>
      'Nếu được hỏi, hãy cho phép truy cập camera. Nemro không dùng micro.';

  @override
  String get livePermissionHint =>
      'Nếu bạn đã từ chối vĩnh viễn, hãy bật Camera cho Nemro trong Cài đặt Android.';

  @override
  String get liveOpenSettings => 'Mở Cài đặt';

  @override
  String get liveCameraLabel => 'Camera';

  @override
  String get liveCameraFront => 'Trước';

  @override
  String get liveCameraBack => 'Sau';

  @override
  String get livePreviewSemantics =>
      'Xem trước camera trực tiếp. Khung hình được xử lý trên thiết bị.';

  @override
  String get liveLiveBadge => 'TRỰC TIẾP';

  @override
  String get liveScoreTitle => 'Điểm proxy';

  @override
  String get liveScoreCaption =>
      'Điểm heuristic từ ánh sáng, độ tương phản và độ ổn định. Không đo suy nghĩ.';

  @override
  String get liveScoreWarmingUp => 'Đang hiệu chỉnh…';

  @override
  String get liveScoreWaiting => 'Đang chờ khung hình…';

  @override
  String get liveScoreHigh => 'Cao';

  @override
  String get liveScoreMedium => 'Trung bình';

  @override
  String get liveScoreLow => 'Thấp';

  @override
  String get liveLightLabel => 'Ánh sáng';

  @override
  String get liveStabilityLabel => 'Độ ổn định';

  @override
  String get liveFramesLabel => 'Số khung đã phân tích';

  @override
  String get liveBaselineTitle => 'Ngưỡng riêng của bạn';

  @override
  String get liveBaselineBody =>
      'Chuẩn hóa một lần trong phòng và ánh sáng thường dùng của bạn. Điểm sau đó hiển thị tương đối theo ngưỡng riêng — vẫn là proxy camera, không phải đo não.';

  @override
  String liveBaselineRange(int low, int high) {
    return 'Ngưỡng thường gặp: $low–$high';
  }

  @override
  String get liveBaselineCalibrate => 'Chuẩn hóa ngưỡng';

  @override
  String get liveBaselineRecalibrate => 'Chuẩn hóa lại';

  @override
  String get liveBaselineCapturing =>
      'Đang chuẩn hóa… ngồi bình thường và ở trong khung hình.';

  @override
  String liveBaselineProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Đã ghi $count khung hình',
      one: 'Đã ghi 1 khung hình',
    );
    return '$_temp0';
  }

  @override
  String liveBaselineNeeds(int min) {
    return 'Cần ít nhất $min khung hình để lưu.';
  }

  @override
  String get liveBaselineStopSave => 'Dừng và lưu ngưỡng';

  @override
  String get liveBaselineCancel => 'Hủy chuẩn hóa';

  @override
  String get liveBaselineSaved => 'Đã lưu ngưỡng.';

  @override
  String get liveBaselineClear => 'Xóa ngưỡng';

  @override
  String get liveBaselineSaveFailed => 'Không lưu được ngưỡng. Thử lại.';

  @override
  String get liveBaselineTooShort =>
      'Chưa đủ khung hình để đặt ngưỡng. Ở trong khung hình lâu hơn một chút rồi thử lại.';

  @override
  String get liveBaselineRelativeNote =>
      'Tương đối theo ngưỡng riêng của bạn. Vẫn là proxy camera, không phải đo não.';

  @override
  String liveBaselineAbsolute(int score) {
    return 'Điểm proxy tuyệt đối: $score';
  }

  @override
  String get liveStopButton => 'Dừng phiên';

  @override
  String get livePrivacyNote =>
      'Khung hình camera ở lại trên thiết bị. Không ghi hay tải lên.';

  @override
  String get liveSummaryTitle => 'Tóm tắt phiên';

  @override
  String get liveSummaryAverage => 'Điểm trung bình';

  @override
  String get liveSummaryDuration => 'Thời lượng';

  @override
  String get liveSummaryFrames => 'Số khung';

  @override
  String get liveSummaryNoFrames =>
      'Không có khung hình nào được phân tích. Hãy kiểm tra quyền camera và thử lại.';

  @override
  String get liveSummaryPaused =>
      'Phiên đã dừng khi ứng dụng rời khỏi màn hình.';

  @override
  String get liveStartAgain => 'Bắt đầu lại';

  @override
  String get liveErrorTitle => 'Camera không khả dụng';

  @override
  String get liveErrorPermissionDenied =>
      'Quyền camera đã bị từ chối. Nhấn Thử lại để yêu cầu lại.';

  @override
  String get liveErrorPermissionPermanentlyDenied =>
      'Quyền camera bị chặn. Hãy bật Camera cho Nemro trong Cài đặt Android rồi thử lại.';

  @override
  String get liveErrorRestricted =>
      'Quyền camera bị hạn chế trên thiết bị này.';

  @override
  String get liveErrorNoCamera => 'Không tìm thấy camera trên thiết bị này.';

  @override
  String get liveErrorUnavailable =>
      'Không thể bật camera. Hãy đóng ứng dụng camera khác và thử lại.';

  @override
  String liveScoreSemantics(int score) {
    return 'Điểm proxy camera: $score trên 100';
  }

  @override
  String get labDecoderConfusionTitle =>
      'Ma trận nhầm lẫn (hàng = thực tế, cột = dự đoán)';

  @override
  String get homePracticeTitle => 'Luyện tập';

  @override
  String get homePracticeSubtitle => 'Thở theo nhịp gợi ý từ tín hiệu camera';

  @override
  String get homePracticeAction => 'Mở';

  @override
  String get homePracticeBadge => 'Mới';

  @override
  String get practiceTitle => 'Luyện tập';

  @override
  String get practiceIntro =>
      'Buổi tập thở có nhịp thay đổi theo tín hiệu camera. Ngồi trước camera, thở theo vòng tròn, và nhịp thở ra sẽ dài ra khi tín hiệu ổn định.';

  @override
  String get practiceHonestNote =>
      'Nhịp thở chỉ theo một heuristic tín hiệu camera, không đo mức độ bình tĩnh, tập trung hay trạng thái y tế nào. Không có gì bị ghi hay tải lên.';

  @override
  String get practiceDurationLabel => 'Thời lượng buổi tập';

  @override
  String practiceMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String get practiceStartButton => 'Bắt đầu tập';

  @override
  String get practiceStopButton => 'Dừng';

  @override
  String get practiceInhale => 'Hít vào';

  @override
  String get practiceHold => 'Giữ';

  @override
  String get practiceExhale => 'Thở ra';

  @override
  String get practiceRemaining => 'Còn lại';

  @override
  String get practiceSummaryTitle => 'Tổng kết buổi tập';

  @override
  String get practiceSummaryAverage => 'Điểm proxy trung bình';

  @override
  String get practiceSummaryDuration => 'Thời lượng';

  @override
  String get practiceSummaryCycles => 'Chu kỳ thở';

  @override
  String get practiceStartAgain => 'Tập lại';

  @override
  String get homeResearchTitle => 'Nghiên cứu';

  @override
  String get homeResearchSubtitle =>
      'Phát hiện mốc và thí nghiệm tự chạy bằng camera';

  @override
  String get homeResearchAction => 'Mở';

  @override
  String get homeResearchBadge => 'Mới';

  @override
  String get researchTitle => 'Nghiên cứu';

  @override
  String get researchSubtitle =>
      'Bốn phát hiện mốc, mỗi cái kèm giới hạn và nguồn — cùng hai thí nghiệm ngắn bạn tự chạy trên máy này để xem proxy camera phản ứng ra sao.';

  @override
  String get researchHonestNote =>
      'Không có gì ở đây đo sự chú ý, bình tĩnh hay trạng thái y tế nào. Các thí nghiệm chỉ mô tả tín hiệu camera.';

  @override
  String get researchMilestonesTitle => 'Phát hiện mốc';

  @override
  String get researchExperimentsTitle => 'Thí nghiệm tự chạy';

  @override
  String get researchLimitLabel => 'Giới hạn';

  @override
  String get researchSourceLabel => 'Nguồn';

  @override
  String get researchOpenSource => 'Mở nguồn';

  @override
  String get researchStartButton => 'Bắt đầu thí nghiệm';

  @override
  String get researchStopButton => 'Dừng';

  @override
  String get researchResultTitle => 'Kết quả thí nghiệm';

  @override
  String get researchResultAverage => 'Điểm proxy trung bình';

  @override
  String get researchResultStability => 'Độ ổn định trung bình';

  @override
  String get researchResultLighting => 'Độ sáng trung bình';

  @override
  String get researchResultPresence => 'Độ hiện diện trung bình';

  @override
  String get researchResultNote =>
      'Kết quả này chỉ mô tả tín hiệu camera trong 30 giây đó. Nó không phải bằng chứng về sự chú ý, bình tĩnh hay trạng thái tinh thần nào.';

  @override
  String get researchRunAgain => 'Chạy lại';

  @override
  String get researchBackToList => 'Về danh sách';

  @override
  String get researchMilestone1Title =>
      '1929 — Điện não đồ đầu tiên trên người';

  @override
  String get researchMilestone1Body =>
      'Hans Berger ở Jena (Đức) ghi được hoạt động điện của não người từ da đầu và mô tả sóng alpha (khoảng 8–13 Hz, rõ nhất khi nghỉ ngơi, nhắm mắt). Đó là khởi đầu của điện não đồ — và của mọi kỹ thuật ghi não không xâm lấn sau này.';

  @override
  String get researchMilestone1Limit =>
      'Thiết bị thô sơ, chỉ vài đối tượng ban đầu; đây là điểm khởi đầu, chưa phải công cụ lâm sàng đã kiểm chứng.';

  @override
  String get researchMilestone1Source =>
      'Berger, H. (1929). Über das Elektrenkephalogramm des Menschen. Archiv für Psychiatrie und Nervenkrankheiten.';

  @override
  String get researchMilestone2Title => '1988 — Đánh vần bằng sóng P300';

  @override
  String get researchMilestone2Body =>
      'Farwell và Donchin cho thấy con người có thể chọn chữ cái trên màn hình chỉ bằng sự chú ý: não phát ra đáp ứng P300 khoảng 300 ms sau kích thích hiếm và được chú ý, và máy tính giải mã được chữ nào đã chọn. Đó là một trong những BCI không xâm lấn đầu tiên có ứng dụng thực tế — hỗ trợ giao tiếp.';

  @override
  String get researchMilestone2Limit =>
      'Chậm (thời đó chỉ vài ký tự mỗi phút), cần hiệu chuẩn và huấn luyện theo từng người; nó giải mã lựa chọn trong các phương án hiển thị, không phải suy nghĩ tự do.';

  @override
  String get researchMilestone2Source =>
      'Farwell, L. A., & Donchin, E. (1988). Talking off the top of your head. Electroencephalography and Clinical Neurophysiology.';

  @override
  String get researchMilestone3Title =>
      '2004 — Bộ dữ liệu EEG tưởng tượng vận động mở';

  @override
  String get researchMilestone3Body =>
      'Bộ dữ liệu EEG Motor Movement/Imagery trên PhysioNet ghi 109 người thực hiện và tưởng tượng cử động tay, chân (64 kênh). Nó trở thành chuẩn mở để xây dựng và so sánh bộ giải mã — Lab của Nemro phát lại ba đoạn trích từ đây (S001, S002 và S003).';

  @override
  String get researchMilestone3Limit =>
      'Dữ liệu phòng lab, người khỏe mạnh làm theo hiệu lệnh — khác xa dùng thực tế hàng ngày; độ chính xác trên tập này không suy ra hiệu quả lâm sàng.';

  @override
  String get researchMilestone3Source =>
      'PhysioNet EEG Motor Movement/Imagery Dataset (EEGMMIDB); Schalk et al., BCI2000 (2004).';

  @override
  String get researchMilestone4Title =>
      '2010 — Không phải ai cũng điều khiển được BCI';

  @override
  String get researchMilestone4Body =>
      'Nhóm Berlin BCI tổng kết: một tỉ lệ đáng kể người dùng — thường được trích khoảng 15–30% — không bao giờ đạt điều khiển BCI tưởng tượng vận động ổn định dù đã huấn luyện, hiện tượng gọi là \'BCI illiteracy\'. Hiệu quả BCI phụ thuộc vào từng người, không chỉ vào công nghệ.';

  @override
  String get researchMilestone4Limit =>
      'Tỉ lệ thay đổi theo định nghĩa \'điều khiển được\', nhiệm vụ và thời lượng huấn luyện; không có nghĩa não của những người đó có vấn đề.';

  @override
  String get researchMilestone4Source =>
      'Blankertz, B., et al. (2010). Neurophysiological predictor of SMR-based BCI performance. NeuroImage.';

  @override
  String get researchExperimentStillTitle => 'Ngồi yên 30 giây';

  @override
  String get researchExperimentStillBody =>
      'Ngồi trước camera và giữ yên nhất có thể trong 30 giây. Xem thành phần ổn định và điểm số thay đổi ra sao.';

  @override
  String get researchExperimentStillReading =>
      'Nếu bạn ngồi yên, độ ổn định thường tăng và điểm số tăng theo. Điều đó cho thấy điểm số phản ứng với chuyển động — không phải với sự tập trung, bình tĩnh hay nỗ lực.';

  @override
  String get researchExperimentCoverTitle => 'Che camera rồi mở ra';

  @override
  String get researchExperimentCoverBody =>
      'Bắt đầu chạy, che camera bằng tay vài giây rồi mở ra. Xem thành phần hiện diện và điểm số thay đổi ra sao.';

  @override
  String get researchExperimentCoverReading =>
      'Che ống kính làm sụp độ tương phản vùng trung tâm, nên độ hiện diện và điểm số rơi theo — không cần thay đổi trạng thái tinh thần nào. Điểm số đi theo hình ảnh nó nhận được.';

  @override
  String get labDecoderModelLabel => 'Bộ giải mã';

  @override
  String get labDecoderModelLogistic => 'Logistic';

  @override
  String get labDecoderModelCentroid => 'Centroid';

  @override
  String labDecoderModelCentroidLine(Object count) {
    return 'Centroid gần nhất · công suất mu/beta · $count kênh';
  }

  @override
  String labDecoderTrainingInSample(Object train) {
    return 'Huấn luyện ngay trên đoạn phát lại ($train); không có run held-out.';
  }

  @override
  String labDecoderAccuracyInSample(Object percent) {
    return 'Độ chính xác nội mẫu: $percent% (ngẫu nhiên 50%)';
  }

  @override
  String get labDecoderInSampleNote =>
      'Độ chính xác nội mẫu tâng bốc mô hình: nó được kiểm tra trên chính các cửa sổ đã học, nên không thể so sánh với độ chính xác held-out.';
}
