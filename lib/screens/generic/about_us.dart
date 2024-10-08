import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    double minHeight = MediaQuery.of(context).size.height * 0.3 < 500
        ? 500
        : MediaQuery.of(context).size.height * 0.3;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            width: double.infinity,
            color: Theme.of(context).primaryColor.withOpacity(0.01),
            child: SizedBox(
              height: minHeight * 0.25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'About Us',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            width: double.infinity,
            height: minHeight,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  const Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Our Mission',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Flexible(
                          child: Text(
                            'To assist future developers by offering an interactive, cross-platform web application with dynamic animations and engaging unit tests that makes learning Python and Java easier. With the help of dynamic animations, we hope to make coding more approachable and entertaining for novices, facilitating their retention of newly acquired knowledge and addressing the lack of variety in the field.',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            width: double.infinity,
            height: minHeight,
            color: Theme.of(context).primaryColor.withOpacity(0.01),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Flexible(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Our Vision',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Flexible(
                          child: Text(
                            'To be a beneficial supplementary learning tool for novice programmers, providing a fun and dynamic approach to deepen their grasp of Python and Java. Our goal is to enhance the current educational materials by offering interactive visual aids and practical testing opportunities, assisting users in bridging the knowledge gap between theory and implementation as they advance their coding abilities.',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
            width: double.infinity,
            height: minHeight * 1.5,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Our Team',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Flexible(
                    child: Text(
                      'Our team is composed of highly skilled individuals who are passionate about programming and education. We are dedicated to providing a platform that will help aspiring developers improve their coding skills and knowledge.',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 600) {
                        // Stack members vertically if the screen width is less than 600
                        return const Column(
                          children: [
                            Member(
                              name: "Glenn Genre I. Mamanao",
                              position: "Lead Developer",
                              email: "mamanaoglenngenre@gmail.com",
                              imagePath: "assets/images/mamanao-pic.jpg",
                            ),
                            SizedBox(height: 10),
                            Member(
                              name: "Francheska Ella S. Horlador",
                              position: "Project Manager & Quality Assurance",
                              email: "francheskahrldr@gmail.com",
                              imagePath: 'assets/images/horlador-pic.png',
                            ),
                            SizedBox(height: 10),
                            Member(
                              name: "Justin Rei R. Pahayac",
                              position: "System Analyst",
                              email: "justinpahayac@gmail.com",
                              imagePath: 'assets/images/pahayac-pic.jpg',
                            ),
                          ],
                        );
                      } else {
                        // Arrange members horizontally if the screen width is 600 or more
                        return const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Member(
                                name: "Glenn Genre I. Mamanao",
                                position: "Lead Developer",
                                email: "mamanaoglenngenre@gmail.com",
                                imagePath: "assets/images/mamanao-pic.jpg",
                              ),
                            ),
                            Expanded(
                              child: Member(
                                name: "Francheska Ella S. Horlador",
                                position: "Project Manager & Quality Assurance",
                                email: "francheskahrldr@gmail.com",
                                imagePath: 'assets/images/horlador-pic.png',
                              ),
                            ),
                            Expanded(
                              child: Member(
                                name: "Justin Rei R. Pahayac",
                                position: "System Analyst",
                                email: "justinpahayac@gmail.com",
                                imagePath: 'assets/images/pahayac-pic.jpg',
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Member extends StatefulWidget {
  final String name;
  final String position;
  final String email;
  final String imagePath;

  const Member({
    super.key,
    this.name = 'Member Name',
    this.position = 'Member Position',
    this.email = 'Member Email',
    this.imagePath = 'assets/member_picture.png',
  });

  @override
  _MemberState createState() => _MemberState();
}

class _MemberState extends State<Member> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(widget.imagePath),
            ),
            const SizedBox(height: 10),
            Text(
              widget.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width < 800 ? 14 : 16,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              widget.email,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 5),
            Text(
              widget.position,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
