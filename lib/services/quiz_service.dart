import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createQuiz(Quiz quiz, String organizationId) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('quizzes')
          .doc(quiz.id)
          .set({
        'title': quiz.title,
        'timer': quiz.timer,
        'questions': quiz.questions
            .map((question) => {
                  'questionText': question.questionText,
                  'answerOptions': question.answerOptions,
                  'correctAnswer': question.correctAnswer,
                })
            .toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error creating quiz: $e');
    }
  }

  Future<void> updateQuiz(Quiz quiz, String organizationId) async {
    try {
      await _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('quizzes')
          .doc(quiz.id)
          .update(quiz.toJson());
    } catch (e) {
      throw Exception('Error updating quiz: $e');
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

      final quiz = Quiz.fromJson(data);

      return quiz;
    } catch (e) {
      throw Exception('Error getting quiz: $e');
    }
  }

  Future<void> markQuizAsCompleted(String quizId) async {
    try {
      await DatabaseHelper().currentUser.get().then((doc) {
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;

          if (data['completedQuizzes'] == null) {
            DatabaseHelper().currentUser.set({
              'completedQuizzes': [quizId],
            }, SetOptions(merge: true));
            return;
          }

          List<String> completedQuizzes =
              (data['completedQuizzes'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList();

          if (completedQuizzes.contains(quizId)) {
            return;
          }

          completedQuizzes.add(quizId);

          DatabaseHelper().currentUser.set({
            'completedQuizzes': completedQuizzes,
          }, SetOptions(merge: true));
        }
      });
    } catch (e) {
      throw Exception('Error marking quiz as completed: $e');
    }
  }

  Future<List<String>> getCompletedQuizzes(String userId) async {
    final doc = await DatabaseHelper().currentUser.get();

    final data = doc.data() as Map<String, dynamic>;

    final List<dynamic> completedQuizzesData = data['completedQuizzes'] ?? [];

    return completedQuizzesData.map((e) => e.toString()).toList();
  }

  Stream<List<String>> streamCompletedQuizzes() {
    return DatabaseHelper().currentUser.snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      final List<dynamic> completedQuizzesData = data['completedQuizzes'] ?? [];
      return completedQuizzesData.map((e) => e.toString()).toList();
    });
  }
}
