import 'package:flutter/material.dart';

class FAQsPage extends StatefulWidget {
  const FAQsPage({super.key});

  @override
  _FAQsPageState createState() => _FAQsPageState();
}

class _FAQsPageState extends State<FAQsPage> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: "What is CodeCraft?",
      answer:
          "CodeCraft is a web-based, multi-platform system designed to help users learn and practice coding in Java and Python through gamified challenges. It integrates coding challenges, quizzes, and debugging exercises, offering an engaging environment for both educators (Mentors) and learners (Apprentices).",
    ),
    FAQItem(
      question: "Who can use CodeCraft?",
      answer:
          "CodeCraft is designed for two types of users: Mentors (educators or experienced coders) and Apprentices (learners or beginner developers). Mentors create coding challenges and quizzes, while Apprentices participate in the challenges to improve their coding skills.",
    ),
    FAQItem(
      question: "How do apprentices join a mentors organization?",
      answer:
          "Apprentices need an invite code from a mentor to request to join their organization. The mentor can then accept or reject the apprentice's request",
    ),
    FAQItem(
      question: "What programming languages are supported in CodeCraft?",
      answer:
          "CodeCraft supports coding challenges in Java and Python, allowing apprentices to practice and improve their skills in these two popular languages.",
    ),
    FAQItem(
      question: "Is CodeCraft available on multiple platforms?",
      answer:
          "Yes, CodeCraft is a multi-platform web application accessible via both web browsers and mobile devices. This flexibility allows users to engage with coding challenges and learning materials anytime, anywhere, ensuring a seamless learning experience across different devices.",
    ),
    FAQItem(
      question:
          "How does the Programming Concepts Learning Materials Page work?",
      answer:
          "This page provides essential theoretical knowledge through tutorials, examples, and explanations of specific programming concepts. It prepares apprentices for the coding challenges they will face, ensuring they have a solid understanding before applying their knowledge.",
    ),
    FAQItem(
      question: "What is the Code Clash Module?",
      answer:
          "The Code-Clash Module allows mentors to create customized coding competitions for their apprentices with a set timer. Apprentices compete to submit valid and correct code first, fostering a competitive learning environment.",
    ),
    FAQItem(
      question:
          "How do apprentices benefit from participating in these modules?",
      answer:
          "By engaging in the various modules, apprentices enhance their coding skills through practical application, receive immediate feedback, and build a strong theoretical foundation. The structured approach helps them track their progress and encourages continuous improvement.",
    ),
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 32.0), // Increased padding for centering
      child: ListView.builder(
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          return FAQCard(
            faq: _faqs[index],
            isExpanded: _expandedIndex ==
                index, // Check if this card should be expanded
            onTap: () {
              setState(() {
                // Toggle the current index; close others
                _expandedIndex = _expandedIndex == index ? null : index;
              });
            },
          );
        },
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}

class FAQCard extends StatelessWidget {
  final FAQItem faq;
  final bool isExpanded;
  final VoidCallback onTap;

  const FAQCard({
    super.key,
    required this.faq,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8),
        elevation: 2,
        color: isExpanded
            ? Theme.of(context).primaryColor.withOpacity(0.7)
            : Colors.white,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align children to the start (left)
          children: [
            ListTile(
              title: Text(
                faq.question,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: (isExpanded
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.7)
                                  : Colors.white)
                              .computeLuminance() >
                          0.5
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Theme.of(context).hintColor,
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  faq.answer,
                  style: TextStyle(
                    color: (isExpanded
                                    ? Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.7)
                                    : Colors.white)
                                .computeLuminance() >
                            0.5
                        ? Colors.black87
                        : Colors.white70,
                  ),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
