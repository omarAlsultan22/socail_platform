import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../features/questions/data/models/answer_model.dart';
import '../../../../features/questions/data/models/question_model.dart';


class DataConverter {
  List<QuestionModel> data;
  DataConverter({required this.data});

  factory DataConverter.fromQuerySnapshot(QuerySnapshot snapshot) {
    List<QuestionModel> data = [];
    for (var doc in snapshot.docs) {
      final docData = doc.data() as Map<String, dynamic>;
      final answers = (docData['answers'] as List).map((e) => AnswerModel.fromJson(e)).toList();
      final question = docData['question'] as String;

      data.add(QuestionModel(
        question: question,
        answers: answers,
      ));
    }
    return DataConverter(data: data);
  }
}