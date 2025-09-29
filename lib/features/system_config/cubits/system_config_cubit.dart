//State
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/model/answer_mode.dart';
import 'package:flutterquiz/features/system_config/model/supported_question_language.dart';
import 'package:flutterquiz/features/system_config/model/system_config_model.dart';
import 'package:flutterquiz/features/system_config/system_config_repository.dart';

abstract class SystemConfigState {}

class SystemConfigInitial extends SystemConfigState {}

class SystemConfigFetchInProgress extends SystemConfigState {}

class SystemConfigFetchSuccess extends SystemConfigState {
  SystemConfigFetchSuccess({
    required this.systemConfigModel,
    required this.defaultProfileImages,
    required this.supportedLanguages,
    required this.emojis,
  });

  final SystemConfigModel systemConfigModel;
  final List<QuizLanguage> supportedLanguages;
  final List<String> emojis;

  final List<String> defaultProfileImages;
}

class SystemConfigFetchFailure extends SystemConfigState {
  SystemConfigFetchFailure(this.errorCode);

  final String errorCode;
}

class SystemConfigCubit extends Cubit<SystemConfigState> {
  SystemConfigCubit(this._systemConfigRepository)
      : super(SystemConfigInitial());
  final SystemConfigRepository _systemConfigRepository;

  Future<void> getSystemConfig() async {
    emit(SystemConfigFetchInProgress());
    try {
      var supportedLanguages = <QuizLanguage>[];
      final systemConfig = await _systemConfigRepository.getSystemConfig();
      final defaultProfileImages = await _systemConfigRepository
          .getImagesFromFile('assets/files/defaultProfileImages.json');

      final emojis = await _systemConfigRepository
          .getImagesFromFile('assets/files/emojis.json');

      if (systemConfig.languageMode) {
        supportedLanguages =
            await _systemConfigRepository.getSupportedQuestionLanguages();
      }

      emit(
        SystemConfigFetchSuccess(
          systemConfigModel: systemConfig,
          defaultProfileImages: defaultProfileImages,
          supportedLanguages: supportedLanguages,
          emojis: emojis,
          // supportedLanguageList: supportedLanguageList,
        ),
      );
    } on Exception catch (e) {
      emit(SystemConfigFetchFailure(e.toString()));
    }
  }

  List<QuizLanguage> get supportedQuizLanguages =>
      state is SystemConfigFetchSuccess
          ? (state as SystemConfigFetchSuccess).supportedLanguages
          : [];

  List<String> getEmojis() => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).emojis
      : [];

  SystemConfigModel? get systemConfigModel => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).systemConfigModel
      : null;

  String get shareAppText => systemConfigModel?.shareAppText ?? '';

  bool get isLanguageModeEnabled => systemConfigModel?.languageMode ?? false;

  AnswerMode get answerMode =>
      systemConfigModel?.answerMode ?? AnswerMode.showAnswerCorrectness;

  bool get isQuizZoneEnabled => systemConfigModel?.quizZoneMode ?? false;

  String get appVersion => Platform.isIOS
      ? systemConfigModel?.appVersionIos ?? '1.0.0+1'
      : systemConfigModel?.appVersion ?? '1.0.0+1';

  String get appUrl => Platform.isIOS
      ? systemConfigModel?.iosAppLink ?? ''
      : systemConfigModel?.appLink ?? '';







  bool get isForceUpdateEnable => systemConfigModel?.forceUpdate ?? false;

  bool get isAppUnderMaintenance => systemConfigModel?.appMaintenance ?? false;

  int get perCoin => systemConfigModel?.perCoin ?? 0;

  int get coinAmount => systemConfigModel?.coinAmount ?? 0;

  int get minimumCoinLimit => systemConfigModel?.coinLimit ?? 0;

  double get maxCoinsWinningPercentage =>
      systemConfigModel?.minWinningPercentage ?? 0;

  double get quizWinningPercentage =>
      systemConfigModel?.quizWinningPercentage ?? 0;

  int get maxWinningCoins => systemConfigModel?.maxWinningCoins ?? 0;

  int get reviewAnswersDeductCoins =>
      systemConfigModel?.reviewAnswersDeductCoins ?? 0;

  int get lifelinesDeductCoins => systemConfigModel?.lifelineDeductCoins ?? 0;

  List<String> get defaultAvatarImages => state is SystemConfigFetchSuccess
      ? (state as SystemConfigFetchSuccess).defaultProfileImages
      : [];

  int quizTimer(QuizTypes type) {
    final m = systemConfigModel;
    return switch (type) {
          QuizTypes.quizZone => m?.quizTimer,
          _ => m?.quizTimer,
        } ??
        0;
  }

  int quizCorrectAnswerCreditScore(QuizTypes type) {
    final m = systemConfigModel;
    return switch (type) {
          QuizTypes.quizZone => m?.quizZoneCorrectAnswerCreditScore,
          _ => m?.score,
        } ??
        0;
  }

  int quizWrongAnswerDeductScore(QuizTypes type) {
    final m = systemConfigModel;
    return switch (type) {
          QuizTypes.quizZone => m?.quizZoneWrongAnswerDeductScore,
          _ => m?.score,
        } ??
        0;
  }

  /// will return true ONLY if ALL login methods are disabled.
  bool get areAllLoginMethodsDisabled {
    final m = systemConfigModel!;

    return !(m.isEmailLoginEnabled ||
        m.isGmailLoginEnabled ||
        m.isAppleLoginEnabled ||
        m.isPhoneLoginEnabled);
  }

  bool get isEmailLoginMethodEnabled =>
      systemConfigModel?.isEmailLoginEnabled ?? false;

  bool get isGmailLoginMethodEnabled =>
      systemConfigModel?.isGmailLoginEnabled ?? false;

  bool get isAppleLoginMethodEnabled =>
      systemConfigModel?.isAppleLoginEnabled ?? false;

  bool get isPhoneLoginMethodEnabled =>
      systemConfigModel?.isPhoneLoginEnabled ?? false;
}
