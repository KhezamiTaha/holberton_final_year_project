
enum QuizTypes {
  practiceSection,
  quizZone,

}

QuizTypes getQuizTypeEnumFromTitle(String? title) {
  if (title == 'quizZone') {
    return QuizTypes.quizZone;
  }  
  return QuizTypes.practiceSection;
}
