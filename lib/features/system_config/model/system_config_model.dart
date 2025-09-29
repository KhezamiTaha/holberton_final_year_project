import 'package:flutterquiz/features/system_config/model/answer_mode.dart';

class SystemConfigModel {
  SystemConfigModel({
    required this.answerMode,
    required this.appLink,
    required this.appMaintenance,
    required this.appVersion,
    required this.appVersionIos,
    required this.coinAmount,
    required this.coinLimit,
    required this.earnCoin,
    required this.falseValue,
    required this.forceUpdate,
    required this.iosAppLink,
    required this.iosGameID,
    required this.iosMoreApps,
    required this.languageMode,
    required this.lifelineDeductCoins,
    required this.maxWinningCoins,
    required this.minWinningPercentage,
    required this.quizWinningPercentage,
    required this.moreApps,
    required this.optionEMode,
    required this.perCoin,
    required this.quizZoneCorrectAnswerCreditScore,
    required this.quizZoneWrongAnswerDeductScore,
    required this.quizTimer,
    required this.referCoin,
    required this.reviewAnswersDeductCoins,
    required this.shareAppText,
    required this.systemTimezone,
    required this.systemTimezoneGmt,
    required this.trueValue,
    required this.truefalseMode,
    required this.botImage,
    required this.score,
    required this.quizZoneMode,
    required this.isEmailLoginEnabled,
    required this.isGmailLoginEnabled,
    required this.isAppleLoginEnabled,
    required this.isPhoneLoginEnabled,
  });

  SystemConfigModel.fromJson(Map<String, dynamic> json) {
    androidGameID = json['android_game_id'] as String? ?? '';

    appLink = json['app_link'] as String? ?? '';
    appMaintenance = json['app_maintenance'] == '1';
    appVersion = json['app_version'] as String? ?? '';
    appVersionIos = json['app_version_ios'] as String? ?? '';

    coinAmount = int.parse(json['coin_amount'] as String? ?? '0');
    coinLimit = int.parse(json['coin_limit'] as String? ?? '0');

    currencySymbol = json['currency_symbol'] as String? ?? r'$';

    earnCoin = json['earn_coin'] as String? ?? '';

    falseValue = json['false_value'] as String? ?? '';
    forceUpdate = json['force_update'] == '1';

    iosAppLink = json['ios_app_link'] as String? ?? '';

    iosGameID = json['ios_game_id'] as String? ?? '';

    iosMoreApps = json['ios_more_apps'] as String? ?? '';

    languageMode = (json['language_mode'] ?? '0') == '1';
    lifelineDeductCoins =
        int.parse(json['quiz_zone_lifeline_deduct_coin'] as String? ?? '0');

    maxWinningCoins =
        int.parse(json['maximum_winning_coins'] as String? ?? '0');
    minWinningPercentage = double.parse(
      json['minimum_coins_winning_percentage'] as String? ?? '0',
    );
    quizWinningPercentage = double.parse(
      json['quiz_winning_percentage'] as String? ?? '0',
    );
    moreApps = json['more_apps'] as String? ?? '';
    optionEMode = json['option_e_mode'] as String? ?? '';

    perCoin = int.parse(json['per_coin'] as String? ?? '0');
    quizZoneCorrectAnswerCreditScore = int.parse(
      json['quiz_zone_correct_answer_credit_score'] as String? ?? '0',
    );
    quizZoneWrongAnswerDeductScore = int.parse(
      json['quiz_zone_wrong_answer_deduct_score'] as String? ?? '0',
    );

    quizTimer = int.parse(json['quiz_zone_duration'] as String? ?? '0');
    referCoin = json['refer_coin'] as String? ?? '';
    reviewAnswersDeductCoins =
        int.parse(json['review_answers_deduct_coin'] as String? ?? '0');


    shareAppText = json['shareapp_text'] as String? ?? '';
    answerMode = AnswerMode.fromString(json['answer_mode'] as String);
    systemTimezone = json['system_timezone'] as String? ?? '';
    systemTimezoneGmt = json['system_timezone_gmt'] as String? ?? '';
    trueValue = json['true_value'] as String? ?? '';
    truefalseMode = (json['true_false_mode'] ?? '0') == '1';
    botImage = json['bot_image'] as String? ?? '';

    quizZoneMode = (json['quiz_zone_mode'] ?? '0') == '1';

    isEmailLoginEnabled = (json['email_login'] == '1');
    isGmailLoginEnabled = (json['gmail_login'] == '1');
    isAppleLoginEnabled = (json['apple_login'] == '1');
    isPhoneLoginEnabled = (json['phone_login'] == '1');
  }



  late String androidGameID;

  late AnswerMode answerMode;
  late String appLink;
  late bool appMaintenance;
  late String appVersion;
  late String appVersionIos;

  late int coinAmount;
  late int coinLimit;

  late String currencySymbol;

  late String earnCoin;

  late String falseValue;
  late bool forceUpdate;

  late String iosAppLink;

  late String iosGameID;

  late String iosMoreApps;

  late bool languageMode;
  late int lifelineDeductCoins;

  late int maxWinningCoins;
  late double minWinningPercentage;
  late double quizWinningPercentage;
  late String moreApps;
  late String optionEMode;

  late int perCoin;
  late int quizZoneCorrectAnswerCreditScore;
  late int quizZoneWrongAnswerDeductScore;

  late int quizTimer;

  late String referCoin;
  late int reviewAnswersDeductCoins;

  late String shareAppText;
  late String systemTimezone;
  late String systemTimezoneGmt;
  late String trueValue;
  late bool truefalseMode;
  late final String botImage;

  late final bool quizZoneMode;

  late final int score;

  late final bool isEmailLoginEnabled;
  late final bool isGmailLoginEnabled;
  late final bool isAppleLoginEnabled;
  late final bool isPhoneLoginEnabled;
}
