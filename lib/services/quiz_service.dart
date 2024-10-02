import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/services.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createQuiz(Quiz quiz, String organizationId) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('quizzes')
          .doc(quiz.id)
          .set(quiz.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error creating quiz: $e');
    }
  }

  Future<Quiz> getQuizFromId(String quizId, String organizationId) async {
    try {
      final doc = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('quizzes')
          .doc(quizId)
          .get();

      if (!doc.exists) {
        throw Exception('Quiz not found');
      }

      final data = doc.data() as Map<String, dynamic>;

      return Quiz.fromJson(data);
    } catch (e) {
      throw Exception('Error getting quiz: $e');
    }
  }

  Future<void> createQuizzesFromJson(String jsonFilePath, String orgId) async {
    try {
      final String response = await rootBundle.loadString(jsonFilePath);
      final List<dynamic> data = json.decode(response);
      for (var jsonText in data) {
        Quiz quiz = Quiz.fromJson(jsonText);
        await createQuiz(quiz, orgId);
      }
    } catch (e) {
      throw Exception('Error creating quizzes: $e');
    }
  }

  Future<void> deleteQuiz(String organizationId, String quizId) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('quizzes')
          .doc(quizId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting quiz: $e');
    }
  }

  Future<List<Quiz>> getQuizzes(String organizationId) async {
    try {
      final snapshot = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('quizzes')
          .get();

      List<Quiz> quizzes = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        quizzes.add(Quiz.fromJson(data));
      }

      return quizzes;
    } catch (e) {
      throw Exception('Error getting quizzes: $e');
    }
  }

  Future<Quiz> getQuiz(String organizationId, String quizId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('quizzes')
          .doc(quizId)
          .get();

      if (!doc.exists) {
        throw Exception('Quiz not found');
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      final quiz = Quiz.fromJson(data);

      return quiz;
    } catch (e) {
      throw Exception('Error getting quiz: $e');
    }
  }

  Future<List<QuizResult>> getCompletedQuizzes(String userId) async {
    final doc = await DatabaseHelper().currentUser.get();

    final data = doc.data() as Map<String, dynamic>;

    final Map<String, dynamic> quizResults = data['quizResults'] ?? {};

    return quizResults.values
        .map((e) => QuizResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Stream<List<QuizResult>> streamCompletedQuizzes() {
    return DatabaseHelper().currentUser.snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;

      final Map<String, dynamic> quizResults = data['quizResults'] ?? {};

      return quizResults.values
          .map((e) => QuizResult.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> saveQuizResultsWithAnswers(Quiz quiz) async {
    try {
      await DatabaseHelper().currentUser.get().then((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;

          Map<String, dynamic> quizResults =
              data['quizResults'] as Map<String, dynamic>? ?? {};

          Map<String, String?> userAnswers = {};
          for (var question in quiz.questions) {
            userAnswers[question.questionText] = question.userAnswer;
          }

          int score = 0;

          for (final question in quiz.questions) {
            if (question.userAnswer == question.correctAnswer) score++;
          }

          QuizResult result = QuizResult(
            id: quiz.id!,
            score: score,
            answers: userAnswers,
            completedAt: DateTime.now(),
            attempts: quiz.questions.map((q) => q.attempts).toList(),
          );

          quizResults[quiz.id!] = result.toJson();

          DatabaseHelper().currentUser.set({
            'quizResults': quizResults,
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      throw Exception('Error saving quiz results: $e');
    }
  }

  Stream<List<Quiz>> getQuizzesStream(String organizationId) {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('quizzes')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;

        return Quiz.fromJson(data);
      }).toList();
    });
  }

  Future<QuizResult?> getQuizResult(String quizId) async {
    final doc = await DatabaseHelper().currentUser.get();

    final data = doc.data() as Map<String, dynamic>;

    final Map<String, dynamic> quizResults = data['quizResults'] ?? {};

    final quizResultData = quizResults[quizId];

    if (quizResultData == null) {
      return null;
    }

    return QuizResult.fromJson(quizResultData);
  }
}
