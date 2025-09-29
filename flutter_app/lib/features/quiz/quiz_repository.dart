import 'package:flutterquiz/features/quiz/models/category.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/quiz/models/subcategory.dart';
import 'package:flutterquiz/features/quiz/quiz_exception.dart';
import 'package:flutterquiz/features/quiz/quiz_remote_data_source.dart';

class QuizRepository {
  //QuizLocalDataSource _quizLocalDataSource;

  factory QuizRepository() {
    _quizRepository._quizRemoteDataSource = QuizRemoteDataSource();
    //_quizRepository._quizLocalDataSource = QuizLocalDataSource();
    return _quizRepository;
  }

  QuizRepository._internal();

  static final QuizRepository _quizRepository = QuizRepository._internal();
  late QuizRemoteDataSource _quizRemoteDataSource;
  

  Future<List<Category>> getCategory({
    required String languageId,
    required String type,
    String? subType,
  }) async {
    try {
      final result = await _quizRemoteDataSource.getCategoryWithUser(
        languageId: languageId,
        type: type,
        subType: subType,
      );

      return result.map(Category.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Category>> getCategoryWithoutUser({
    required String languageId,
    required String type,
    String? subType,
  }) async {
    try {
      final result = await _quizRemoteDataSource.getCategory(
        languageId: languageId,
        type: type,
        subType: subType,
      );

      return result.map(Category.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Subcategory>> getSubCategory(String category) async {
    try {
      final result = await _quizRemoteDataSource.getSubCategory(category);

      return result.map(Subcategory.fromJson).toList();
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<int> getUnlockedLevel(String category, String subCategory) async {
    try {
      return await _quizRemoteDataSource.getUnlockedLevel(
        category,
        subCategory,
      );
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateLevel({
    required String category,
    required String subCategory,
    required String level,
  }) async {
    try {
      await _quizRemoteDataSource.updateLevel(
        category: category,
        level: level,
        subCategory: subCategory,
      );
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<List<Question>> getQuestions(
    QuizTypes? quizType, {
    String? languageId,
    String? categoryId,
    String? subcategoryId,
    String? numberOfQuestions,
    String? level,
    
    
  }) async {
    try {
      final List<Map<String, dynamic>> result;

      if (quizType == QuizTypes.quizZone) {
        //if level is 0 means need to fetch questions by get_question api endpoint
        if (level! == '0') {
          final type = categoryId!.isNotEmpty ? 'category' : 'subcategory';
          final id = type == 'category' ? categoryId : subcategoryId!;
          result =
              await _quizRemoteDataSource.getQuestionByCategoryOrSubcategory(
            type: type,
            id: id,
          );
        } else {
          result = await _quizRemoteDataSource.getQuestionsForQuizZone(
            languageId: languageId!,
            categoryId: categoryId!,
            subcategoryId: subcategoryId!,
            level: level,
          );
        }
      } else {
        result = [];
      }

      return result.map(Question.fromJson).toList(growable: false);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }


  Future<void> setQuizCategoryPlayed({
    required String type,
    required String categoryId,
    required String subcategoryId,
    required String typeId,
  }) async {
    try {
      await _quizRemoteDataSource.setQuizCategoryPlayed(
        type: type,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        typeId: typeId,
      );
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }

  Future<void> unlockPremiumCategory({required String categoryId}) async {
    try {
      await _quizRemoteDataSource.unlockPremiumCategory(categoryId: categoryId);
    } catch (e) {
      throw QuizException(errorMessageCode: e.toString());
    }
  }
}
