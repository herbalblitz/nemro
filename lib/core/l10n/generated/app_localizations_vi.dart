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
      'Camera xử lý trên thiết bị, không lưu video.';

  @override
  String get onboardingConsentCheckbox => 'Tôi đã hiểu và đồng ý';

  @override
  String get onboardingContinue => 'Đồng ý và tiếp tục';

  @override
  String get homeHeadline => 'Vòng lặp AI–não, trong tầm tay.';

  @override
  String get homeSubheadline =>
      'Phát lại EEG thật, xem các mốc nhiệm vụ và học đúng về BCI. Bước tiếp theo là AI giải mã.';

  @override
  String get homeLabTitle => 'Lab';

  @override
  String get homeLabSubtitle => 'Phát lại EEG thật';

  @override
  String get homeLabAction => 'Mở Lab';

  @override
  String get homeLabBadge => 'DEMO';

  @override
  String get homeLiveTitle => 'Live';

  @override
  String get homeLiveSubtitle => 'Theo dõi chú ý';

  @override
  String get homeLiveAction => 'Bật camera';

  @override
  String get homeLiveBadge => 'SẮP CÓ';

  @override
  String get homeRecentTitle => 'Phiên gần nhất';

  @override
  String get homeRecentEmpty =>
      'Chưa có phiên nào được lưu. Hãy thử phát lại EEG trong Lab.';

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
      'Cửa sổ 60 giây thật từ bộ dữ liệu vận động–tưởng tượng của PhysioNet. Nhấn phát để xem tín hiệu thô và các mốc nhiệm vụ.';

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
      'Bộ giải mã trên thiết bị là bước tiếp theo. Màn hình này trước hết phát lại tín hiệu thô và các mốc nhiệm vụ, không giả vờ đọc suy nghĩ.';

  @override
  String get labNextBadge => 'TIẾP THEO';

  @override
  String get labDisclaimer =>
      'Chỉ là bản demo nghiên cứu. Không phải thiết bị y tế và không đọc suy nghĩ.';

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
  String get liveComingSoonTitle => 'Theo dõi chú ý đang được xây dựng';

  @override
  String get liveComingSoonBody =>
      'S2 sẽ dùng camera để ước lượng chú ý, mệt mỏi — hoàn toàn trên thiết bị.';

  @override
  String get liveBadge => 'SẮP CÓ';

  @override
  String get insightsTitle => 'Lịch sử';

  @override
  String get insightsEmptyTitle => 'Chưa có dữ liệu';

  @override
  String get insightsEmptyBody => 'Các phiên Live và Lab sẽ xuất hiện ở đây.';

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
      'Nemro lưu cài đặt cục bộ. Các phiên sẽ được thêm ở phiên bản sau.';

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
  String get aboutSourceBci => 'BCI Competition IV 2a';

  @override
  String get aboutSourceNote =>
      'Lab đóng gói một đoạn 60 giây từ EEGMMIDB theo giấy phép Open Data Commons Attribution 1.0.';

  @override
  String get aboutRepo => 'Mã nguồn trên GitHub';

  @override
  String get aboutLicense => 'Giấy phép MIT';

  @override
  String get privacyTitle => 'Quyền riêng tư';

  @override
  String get privacyIntro =>
      'Nemro được thiết kế local-first. Phiên bản 0.1.0 không có quyền truy cập Internet và không gửi dữ liệu ra ngoài.';

  @override
  String get privacyDataTitle => 'Dữ liệu nào được lưu?';

  @override
  String get privacyDataBody =>
      'Cài đặt ngôn ngữ, giao diện và trạng thái onboarding. Các phiên Lab/Live sẽ được lưu cục bộ khi được thêm ở phiên bản sau.';

  @override
  String get privacyCameraTitle => 'Camera';

  @override
  String get privacyCameraBody =>
      'Khi Live được bật, camera xử lý khung hình trên thiết bị để ước lượng chú ý. Không video nào được lưu hoặc gửi đi.';

  @override
  String get privacyStorageTitle => 'Lưu trữ';

  @override
  String get privacyStorageBody =>
      'Dữ liệu nằm trong vùng riêng của app. Bạn có thể xóa toàn bộ trong Cài đặt.';

  @override
  String get privacySharingTitle => 'Chia sẻ';

  @override
  String get privacySharingBody =>
      'Không có analytics, quảng cáo hay SDK bên thứ ba thu thập dữ liệu.';

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
}
