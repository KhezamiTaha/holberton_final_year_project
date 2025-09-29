
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/quiz/models/answer_option.dart';

import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/question_container.dart';
import 'package:flutterquiz/ui/styles/colors.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/utils/answer_encryption.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class ReviewAnswersScreen extends StatefulWidget {
  const ReviewAnswersScreen({
    required this.questions,
    required this.quizType,
    super.key,
  });

  final List<Question> questions;
  final QuizTypes quizType;
  

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    //arguments will map and keys of the map are following
    //questions and 
    return CupertinoPageRoute(
      builder: (_) =>  ReviewAnswersScreen(
          quizType: arguments!['quizType'] as QuizTypes,   
          questions: arguments['questions'] as List<Question>? ?? <Question>[],
        ),
      );

  }

  @override
  State<ReviewAnswersScreen> createState() => _ReviewAnswersScreenState();
}

class _ReviewAnswersScreenState extends State<ReviewAnswersScreen> {
  late final _pageController = PageController();
  int _currQueIdx = 0;

  late final _firebaseId = context.read<UserDetailsCubit>().getUserFirebaseId();


  late final questionsLength =widget.questions.length;


  late final _correctAnswerIds = List.generate(
    widget.questions.length,
    (i) => AnswerEncryption.decryptCorrectAnswer(
      rawKey: _firebaseId,
      correctAnswer: widget.questions[i].correctAnswer!,
    ),
    growable: false,
  );





  void _onPageChanged(int idx) {

    setState(() => _currQueIdx = idx);
  }

  Color _optionBackgroundColor(String? optionId) {
    if (optionId == _correctAnswerIds[_currQueIdx]) {
      return kCorrectAnswerColor;
    }

    if (optionId == widget.questions[_currQueIdx].submittedAnswerId) {
      return kWrongAnswerColor;
    }

    return Theme.of(context).colorScheme.surface;
  }

  Color _optionTextColor(String? optionId) {
    final correctAnswerId = _correctAnswerIds[_currQueIdx];
    final submittedAnswerId = widget.questions[_currQueIdx].submittedAnswerId;

    return optionId == correctAnswerId || optionId == submittedAnswerId
        ? Theme.of(context).colorScheme.surface
        : Theme.of(context).colorScheme.onTertiary;
  }

  Widget _buildBottomMenu() {
    final colorScheme = Theme.of(context).colorScheme;

    void onTapPageChange({required bool flipLeft}) {
      if (_currQueIdx != (flipLeft ? 0 : questionsLength - 1)) {
        final idx = _currQueIdx + (flipLeft ? -1 : 1);
        _pageController.animateToPage(
          idx,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      height: context.height * UiUtils.bottomMenuPercentage,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.onTertiary.withValues(alpha: 0.2),
              ),
            ),
            padding:
                const EdgeInsets.only(top: 5, left: 8, right: 2, bottom: 5),
            child: GestureDetector(
              onTap: () => onTapPageChange(flipLeft: true),
              child: Icon(
                Icons.arrow_back_ios,
                color: colorScheme.onTertiary,
              ),
            ),
          ),
          // Spacer(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.onTertiary.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(
              '${_currQueIdx + 1} / $questionsLength',
              style: TextStyle(
                color: colorScheme.onTertiary,
                fontSize: 18,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colorScheme.onTertiary.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.all(5),
            child: GestureDetector(
              onTap: () => onTapPageChange(flipLeft: false),
              child: Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.onTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //to build option of given question
  Widget _buildOption(AnswerOption option) {
    return  Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _optionBackgroundColor(option.id),
            ),
            width: double.infinity,
            margin: const EdgeInsets.only(top: 15),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Text(
              option.title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _optionTextColor(option.id),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          );
  }

  
  Widget _buildOptions() => Column(
        children: widget.questions[_currQueIdx].answerOptions!
            .map(_buildOption)
            .toList(),
      );





  Widget _buildQuestionAndOptions(Question question, int index) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuestionContainer(       
            question: question,
            questionColor: Theme.of(context).colorScheme.onTertiary,
          ),
            const SizedBox(),
          //build options
          _buildOptions(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }



  Widget _buildQuestions() {
    return SizedBox(
      height: context.height * (0.85),
      child: PageView.builder(
        onPageChanged: _onPageChanged,
        controller: _pageController,
        itemCount: questionsLength,
        itemBuilder: (_, idx) => Padding(
          padding: EdgeInsets.symmetric(
            vertical: context.height * UiUtils.vtMarginPct,
            horizontal: context.width * UiUtils.hzMarginPct,
          ),
          child:  _buildQuestionAndOptions(widget.questions[idx], idx),
        ),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(
          context.tr('reviewAnswerLbl')!,
        ),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _buildQuestions(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomMenu(),
          ),
        ],
      ),
    );
  }
}
