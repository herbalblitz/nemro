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
      'Phát lại EEG thật, xem bộ giải mã trên thiết bị ước lượng bàn tay đang tưởng tượng và thử proxy chú ý bằng camera.';

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
  String get homeLiveSubtitle => 'Proxy chú ý bằng camera';

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
  String labDecoderAccuracy(int percent) {
    return 'Độ chính xác trên run giữ lại: $percent% (ngẫu nhiên 50%)';
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
  String get labRunDescription =>
      'S001 · lượt 4 · tưởng tượng nắm tay trái/phải';

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
  String get insightsEmptyBody =>
      'Các phiên Live và Lab đã lưu sẽ xuất hiện ở đây khi có lịch sử phiên.';

  @override
  String get insightsStart => 'Bắt đầu Live';

  @override
  String get learnTitle => 'Học';

  @override
  String get learnSubtitle =>
      'Hiểu đúng về BCI, EEG và giới hạn của công nghệ.';

  @override
  String get learnComingSoon => 'Nội dung song ngữ sẽ có ở S3.';

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
  String get settingsData => 'Dữ liệu';

  @override
  String get settingsDataBody =>
      'Nemro lưu cài đặt cục bộ. Tóm tắt phiên Live chưa được lưu.';

  @override
  String get settingsDeleteData => 'Xóa toàn bộ dữ liệu cục bộ';

  @override
  String get settingsDeleteDataBody =>
      'Thao tác này xóa cài đặt, lựa chọn ngôn ngữ và trạng thái onboarding.';

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
      'Lab đóng gói một đoạn 60 giây từ EEGMMIDB (ODC-BY 1.0). Bộ giải mã là hồi quy logistic nhỏ, huấn luyện trên run 8 và 12 của S001, đánh giá trên run 4: độ chính xác 67%, mức ngẫu nhiên 50%. Chỉ là demo nghiên cứu.';

  @override
  String get aboutRepo => 'Mã nguồn trên GitHub';

  @override
  String get aboutLicense => 'Giấy phép MIT';

  @override
  String get privacyTitle => 'Quyền riêng tư';

  @override
  String get privacyIntro =>
      'Nemro được thiết kế local-first. Phiên bản 0.3.0 không có quyền truy cập Internet. Mẫu EEG, bộ giải mã và proxy camera Live chạy hoàn toàn trên thiết bị.';

  @override
  String get privacyDataTitle => 'Dữ liệu nào được lưu?';

  @override
  String get privacyDataBody =>
      'Cài đặt ngôn ngữ, giao diện và trạng thái onboarding. Tóm tắt phiên Live chỉ hiển thị trên màn hình, chưa được lưu trong 0.3.0. Bộ giải mã Lab xử lý mẫu đi kèm ngay trên thiết bị; không EEG nào được thu thập từ bạn.';

  @override
  String get privacyDecoderTitle => 'AI trên thiết bị';

  @override
  String get privacyDecoderBody =>
      'Bộ giải mã Lab là một mô hình nhỏ đi kèm ứng dụng. Mô hình chạy cục bộ trên mẫu EEG và dự đoán không rời khỏi thiết bị.';

  @override
  String get privacyCameraTitle => 'Camera';

  @override
  String get privacyCameraBody =>
      'Live chỉ mở camera sau khi bạn nhấn Bắt đầu. Khung hình được thu nhỏ và xử lý trên thiết bị để ước lượng proxy thô từ ánh sáng, độ tương phản và chuyển động. Không video hay hình ảnh nào bị ghi, lưu hoặc tải lên. Camera được giải phóng khi bạn dừng hoặc rời ứng dụng; Nemro không yêu cầu quyền micro hay bộ nhớ.';

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
  String get liveStartTitle => 'Proxy chú ý bằng camera';

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
    return 'Điểm proxy chú ý: $score trên 100';
  }
}
