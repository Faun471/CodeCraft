// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:codecraft/utils/theme_utils.dart';
// import 'package:flutter/material.dart';

// class LeaderboardScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> leaderboardData = [
//     {'rank': 1, 'name': 'Player Name Here', 'score': 12, 'isTop': true},
//     {'rank': 2, 'name': 'Player Name Here', 'score': 11, 'isTop': false},
//     {'rank': 3, 'name': 'Player Name Here', 'score': 9, 'isTop': false},
//     {'rank': 4, 'name': 'Player Name Here', 'score': 6, 'isTop': false},
//     {'rank': 5, 'name': 'Player Name Here', 'score': 5, 'isTop': false},
//   ];

//   LeaderboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Leaderboard Screen',
//             style: TextStyle(
//                 color: ThemeUtils.getTextColor(
//               Theme.of(context).primaryColor,
//             ))),
//       ),
//       backgroundColor: Theme.of(context).primaryColor.withOpacity(0.75),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Container(
//             width: 640,
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor,
//               borderRadius: BorderRadius.circular(16.0),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.2),
//                   blurRadius: 10,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // Header
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Logo
//                       Image.asset(
//                         'assets/images/logo.png',
//                         width: 50,
//                         height: 50,
//                         fit: BoxFit.contain,
//                       ),
//                       // Title
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           AutoSizeText(
//                             'FINAL LEADERBOARD',
//                             maxFontSize: 24,
//                             style: TextStyle(
//                               color: ThemeUtils.getTextColor(
//                                 Theme.of(context).primaryColor,
//                               ),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             'GAME NAME',
//                             style: TextStyle(
//                               color: ThemeUtils.getTextColor(
//                                 Theme.of(context).primaryColor,
//                               ).withOpacity(0.5),
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 36),

//                 // Leaderboard List
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: leaderboardData.length,
//                     shrinkWrap: true,
//                     itemBuilder: (context, index) {
//                       var player = leaderboardData[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
//                         child: LeaderboardRow(
//                           rank: player['rank'],
//                           name: player['name'],
//                           score: player['score'],
//                           isTop: player['isTop'],
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 // Footer
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'CodeCraft',
//                         style: TextStyle(
//                           color: ThemeUtils.getTextColor(
//                             Theme.of(context).primaryColor,
//                           ),
//                         ),
//                       ),
//                       Text(
//                         'Date: XX/XX/XXXX',
//                         style: TextStyle(
//                           color: ThemeUtils.getTextColor(
//                             Theme.of(context).primaryColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class LeaderboardRow extends StatelessWidget {
//   final int rank;
//   final String name;
//   final int score;
//   final bool isTop;

//   const LeaderboardRow({
//     super.key,
//     required this.rank,
//     required this.name,
//     required this.score,
//     required this.isTop,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Row(
//           children: [
//             ClipOval(
//               child: Container(
//                 color: isTop
//                     ? Colors.amber
//                     : Theme.of(context).colorScheme.onPrimary,
//                 width: 50,
//                 height: 50,
//                 child: Center(
//                   child: Text(
//                     '$rank',
//                     style: TextStyle(
//                       color: ThemeUtils.getTextColor(
//                         isTop
//                             ? Colors.amber
//                             : Theme.of(context).colorScheme.onPrimary,
//                       ),
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Badge(
//               backgroundColor: Colors.transparent,
//               isLabelVisible: isTop,
//               alignment: Alignment.topCenter,
//               offset: const Offset(-11, -25),
//               label: Image.asset(
//                 'assets/images/crown.png',
//                 width: 30,
//                 height: 30,
//                 alignment: Alignment.center,
//                 fit: BoxFit.contain,
//               ),
//               child: const CircleAvatar(
//                 backgroundColor: Colors.teal,
//                 radius: 25,
//                 child: Icon(
//                   Icons.person,
//                   color: Colors.white,
//                   size: 30,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 name,
//                 style: TextStyle(
//                   color: ThemeUtils.getTextColor(
//                     Theme.of(context).primaryColor,
//                   ),
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//             Text(
//               '$score pts',
//               style: TextStyle(
//                 color: ThemeUtils.getTextColor(
//                   Theme.of(context).primaryColor,
//                 ),
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
