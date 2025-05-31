import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:purity_path/utils/consts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'questions/frequency_question.dart';
import 'questions/quantity_question.dart';
import 'questions/triggers_question.dart';
import 'questions/motivation_question.dart';
import 'goals_informations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionnaireManager extends StatefulWidget {
  const QuestionnaireManager({super.key});

  @override
  State<QuestionnaireManager> createState() => _QuestionnaireManagerState();
}

class _QuestionnaireManagerState extends State<QuestionnaireManager> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4; // Reduced to 3 questions total

  // Store user responses
  int? frequencyResponse;
  int? quantityResponse;
  String? triggerResponse;
  String otherTrigger = '';
  String? motivationResponse;
  // Removed wantReminders since we're removing that question

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void goToNextPage() async {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final isGuest = prefs.getBool("isGuest") ?? false;

      if (isGuest) {
        final Map<String, dynamic> triggerData = {
          'triggers':
              triggerResponse == 'Other' ? otherTrigger : triggerResponse,
          'frequency': frequencyResponse,
          'quantity': quantityResponse,
          'motivation': motivationResponse,
        };
        await prefs.setString("choice", jsonEncode(triggerData));

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GoalsInformation()),
        );
      } else {
        final Map<String, dynamic> triggerData = {
          'triggers':
              triggerResponse == 'Other' ? otherTrigger : triggerResponse,
          'frequency': frequencyResponse,
          'quantity': quantityResponse,
          'motivation': motivationResponse,
        };
        await prefs.setString("guestChoice", jsonEncode(triggerData));
        final user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
              'hasCompletedQuestionnaire': true,
              'triggers':
                  triggerResponse == 'Other' ? otherTrigger : triggerResponse,
              'frequency': frequencyResponse,
              'quantity': quantityResponse,
              'motivation': motivationResponse,
            });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GoalsInformation()),
        );
      }
    }
  }

  void goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / _totalPages,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(AppColors.primary),
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // Question pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  FrequencyQuestion(
                    selectedValue: frequencyResponse,
                    onValueChanged: (value) {
                      setState(() {
                        frequencyResponse = value;
                      });
                    },
                    onNext: goToNextPage,
                    onPrevious: goToPreviousPage,
                    canProceed: frequencyResponse != null,
                  ),
                  QuantityQuestion(
                    selectedValue: quantityResponse,
                    onValueChanged: (value) {
                      setState(() {
                        quantityResponse = value;
                      });
                    },
                    onNext: goToNextPage,
                    onPrevious: goToPreviousPage,
                    canProceed: quantityResponse != null,
                  ),
                  TriggersQuestion(
                    selectedValue: triggerResponse,
                    otherValue: otherTrigger,
                    onValueChanged: (value) {
                      setState(() {
                        triggerResponse = value;
                      });
                    },
                    onOtherChanged: (value) {
                      setState(() {
                        otherTrigger = value;
                      });
                    },
                    onNext: goToNextPage,
                    onPrevious: goToPreviousPage,
                    canProceed:
                        triggerResponse != null &&
                        (triggerResponse != 'Other' || otherTrigger.isNotEmpty),
                  ),
                  MotivationQuestion(
                    selectedValue: motivationResponse,
                    onValueChanged: (value) {
                      setState(() {
                        motivationResponse = value;
                      });
                    },
                    onNext: goToNextPage,
                    onPrevious: goToPreviousPage,
                    canProceed: motivationResponse != null,
                    nextButtonText:
                        'Complete', // Changed to Complete since this is now the last question
                  ),
                  // Removed RemindersQuestion
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
