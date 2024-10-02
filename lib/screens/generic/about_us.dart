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
              height: minHeight,
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: const Text(
                      'Incididunt commodo quis esse fugiat est enim irure duis duis.'
                      'Enim ipsum cillum nisi tempor minim velit.'
                      'Officia dolor Lorem id ullamco deserunt incididunt velit.',
                      textAlign: TextAlign.center,
                      maxLines: 3,
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Our Mission',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: const Text(
                          'To assist future developers by offering an interactive, cross-platform web application with dynamic animations and engaging unit tests that makes learning Python and Java easier. With the help of dynamic animations, we hope to make coding more approachable and entertaining for novices, facilitating their retention of newly acquired knowledge and addressing the lack of variety in the field.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Our Vision',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: const Text(
                          'To be a beneficial supplementary learning tool for novice programmers, providing a fun and dynamic approach to deepen their grasp of Python and Java. Our goal is to enhance the current educational materials by offering interactive visual aids and practical testing opportunities, assisting users in bridging the knowledge gap between theory and implementation as they advance their coding abilities.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: const Text(
                      'Our team is composed of highly skilled individuals who are passionate about programming and education. We are dedicated to providing a platform that will help aspiring developers improve their coding skills and knowledge.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Member(
                        name: "Glenn Genre I. Mamanao",
                        position: "Lead Developer",
                        email: "mamanaoglenngenre@gmail.com",
                        imageUrl:
                            "https://scontent.fcrk1-1.fna.fbcdn.net/v/t39.30808-6/378125430_1510004556478969_7834789049005275261_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=a5f93a&_nc_eui2=AeELD-gn8j_0TlFBqaRCacRpSGINP_Tpw39IYg0_9OnDfyhtAucLRFEyJ9HLQIxB7T2bZ5kH3KQ_G4K_yx2aAYZb&_nc_ohc=0AsA9rcQPK8Q7kNvgHDeeEk&_nc_ht=scontent.fcrk1-1.fna&_nc_gid=ALdk_CfNOmYn1OptpTiDcA7&oh=00_AYD4Zt3Xd9EY21jC24Z7MDSVtgAM7t-VRWOs4pzBZbZCbg&oe=6703315A",
                      )),
                      Expanded(
                          child: Member(
                        name: "Francheska Ella S. Horlador",
                        position: "Project Manager & Quality Assurance",
                        email: "francheskahrldr@gmail.com",
                        imageUrl:
                            'https://scontent.fcrk1-3.fna.fbcdn.net/v/t1.6435-9/83547343_2706498506137842_6817607193320226816_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=13d280&_nc_eui2=AeFfjtpcljM4tsm6Al-StfGjg9OwauQQu-eD07Bq5BC751WdiEn6k_MkOf5rV1EkOZatVYD8koJ_evhXdBqo8ohq&_nc_ohc=Zi6NhQqNPB4Q7kNvgEXSt-s&_nc_ht=scontent.fcrk1-3.fna&oh=00_AYATdwAZwlQ9pi-eZnWI-A05ttQpWjflfMD2IIhaqRD-bg&oe=6724D9B6',
                      )),
                      Expanded(
                          child: Member(
                        name: "Justin Rei R. Pahayac",
                        position: "System Analyst",
                        email: "justinpahayac@gmail.com",
                        imageUrl:
                            'https://scontent.fmnl4-4.fna.fbcdn.net/v/t1.6435-9/133601686_10159364694899947_4811827179496767424_n.jpg?_nc_cat=100&ccb=1-7&_nc_sid=dd6889&_nc_eui2=AeGZsI1YzyeJjMyS5R6TysNnu4zb81jly-C7jNvzWOXL4OKrbUO1__P_NOznJV78XUx52m60_FM3ZEGpuueAACdu&_nc_ohc=QGK3YsqrpcEQ7kNvgEfSlsf&_nc_ht=scontent.fmnl4-4.fna&_nc_gid=At1qZWt41VPSxZbB6lCJIp5&oh=00_AYAKFvH1uvbqC86Kf7MuwZwiel16xSAHx-e6pZi-RywolA&oe=6724CB8A',
                      )),
                    ],
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
  final String imageUrl;

  const Member({
    super.key,
    this.name = 'Member Name',
    this.position = 'Member Position',
    this.email = 'Member Email',
    this.imageUrl = 'assets/member_picture.png',
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
              backgroundImage: NetworkImage(widget.imageUrl),
            ),
            const SizedBox(height: 10),
            Text(
              widget.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width < 800 ? 14 : 16,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              widget.email,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.position,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
