import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/widgets/screentypes/logo_with_background.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewAboutUs extends StatelessWidget {
  const NewAboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // About Us Section
          LogoWithBackground(
            isVertical: true,
            content: Text(
              'About Us',
              style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Coding Made Fun Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Small screen layout: Image on top
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Image.asset(
                        'assets/images/demo.jpg',
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 20),
                      // Text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coding Made Fun\nLearning Made Easy',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AutoSizeText(
                            'At CodeCraft, we believe that learning to code should be as engaging and exciting as any hands-on experience. '
                            'Our mission is to provide a unique, interactive learning platform that enables aspiring developers to make coding fun and effective.',
                            style: TextStyle(
                              color: AdaptiveTheme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black54,
                            ),
                            maxLines: 5,
                            maxFontSize: 32,
                            minFontSize: 16,
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Large screen layout: Image on the right
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Column (Text)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coding Made Fun\nLearning Made Easy',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'At CodeCraft, we believe that learning to code should be as engaging and exciting as any hands-on experience. '
                              'Our mission is to provide a unique, interactive learning platform that enables aspiring developers to make coding fun and effective.',
                              style: TextStyle(
                                color: AdaptiveTheme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Right Column (Image)
                      Expanded(
                        flex: 1,
                        child: Image.asset(
                          'assets/images/demo.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    children: [
                      // Our Mission Card
                      Card(
                        color: Colors.lightBlue.shade50,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Our Mission',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'To assist future developers by offering an interactive, cross-platform web application with dynamic animations and engaging unit tests that makes learning Python and Java easier. With the help of dynamic animations, we hope to make coding more approachable and entertaining for novices, facilitating their retention of newly acquired knowledge and addressing the lack of variety in the field.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Our Vision Card
                      Card(
                        color: Colors.lightBlue.shade50,
                        elevation: 5,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Our Vision',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'To be a beneficial supplementary learning tool for novice programmers, providing a fun and dynamic approach to deepen their grasp of Python and Java. Our goal is to enhance the current educational materials by offering interactive visual aids and practical testing opportunities, assisting users in bridging the knowledge gap between theory and implementation as they advance their coding abilities.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    // Our Mission Card
                    Expanded(
                      child: Card(
                        color: Colors.lightBlue.shade50,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Our Mission',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'To assist future developers by offering an interactive, cross-platform web application with dynamic animations and engaging unit tests that makes learning Python and Java easier. With the help of dynamic animations, we hope to make coding more approachable and entertaining for novices, facilitating their retention of newly acquired knowledge and addressing the lack of variety in the field.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Our Vision Card
                    Expanded(
                      child: Card(
                        color: Colors.lightBlue.shade50,
                        elevation: 5,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Our Vision',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'To be a beneficial supplementary learning tool for novice programmers, providing a fun and dynamic approach to deepen their grasp of Python and Java. Our goal is to enhance the current educational materials by offering interactive visual aids and practical testing opportunities, assisting users in bridging the knowledge gap between theory and implementation as they advance their coding abilities.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Mission and Vision Section

          // Our Team Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Team Section Title
                Text(
                  'Our Team',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/our team.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Team Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Our team is composed of highly skilled individuals who are passionate about programming and education. '
                    'We are dedicated to providing a platform that helps aspiring developers improve their coding skills and knowledge.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Team Members
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return Column(
                        children: [
                          _buildTeamMemberCard(
                            'Francheska Ella S. Horlador',
                            'Project Manager/Quality Assurance',
                            'assets/images/horlador-pic.png',
                            'francheskahrldr@gmail.com',
                          ),
                          const SizedBox(width: 20),
                          _buildTeamMemberCard(
                            'Glenn Genre I. Mamanao',
                            'Lead Developer',
                            'assets/images/mamanao-pic.jpg',
                            'mamanaoglenngenre@gmail.com',
                          ),
                          const SizedBox(width: 20),
                          _buildTeamMemberCard(
                            'Justin Rei R. Pahayac',
                            'Project Manager',
                            'assets/images/pahayac-pic.jpg',
                            'justinpahayac@gmail.com',
                          ),
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTeamMemberCard(
                          'Francheska Ella S. Horlador',
                          'Project Manager/Quality Assurance',
                          'assets/images/horlador-pic.png',
                          'francheskahrldr@gmail.com',
                        ),
                        const SizedBox(width: 20),
                        _buildTeamMemberCard(
                          'Glenn Genre I. Mamanao',
                          'Lead Developer',
                          'assets/images/mamanao-pic.jpg',
                          'mamanaoglenngenre@gmail.com',
                        ),
                        const SizedBox(width: 20),
                        _buildTeamMemberCard(
                          'Justin Rei R. Pahayac',
                          'Project Manager',
                          'assets/images/pahayac-pic.jpg',
                          'justinpahayac@gmail.com',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Team Member Card Widget
  Widget _buildTeamMemberCard(
    String name,
    String position,
    String imageAsset,
    String email,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.asset(
                imageAsset,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  position,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
