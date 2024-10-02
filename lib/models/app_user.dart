class AppUser {
  final String? id;
  final String? email;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? mi;
  final String? suffix;
  final String? phoneNumber;
  final String? accountType;
  final int? level;
  final String? orgId;
  final int? experience;
  final List<String>? completedChallenges;
  final List<String>? completedDebuggingChallenges;
  final Map<String, dynamic> quizResults;
  final String? photoURL;

  AppUser({
    this.id,
    this.email,
    this.displayName,
    this.firstName,
    this.lastName,
    this.mi,
    this.suffix,
    this.phoneNumber,
    this.accountType,
    this.level,
    this.orgId,
    this.experience,
    this.completedChallenges,
    this.completedDebuggingChallenges,
    this.quizResults = const {},
    this.photoURL,
  });

  // Factory constructor to create an AppUser from a map
  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      id: data['id'] as String?,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      mi: data['mi'] as String?,
      suffix: data['suffix'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      accountType: data['accountType'] as String?,
      level: data['level'] as int?,
      orgId: data['orgId'] as String?,
      experience: data['experience'] as int?,
      completedChallenges: (data['completedChallenges'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
      completedDebuggingChallenges:
          (data['completedDebuggingChallenges'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList(),
      quizResults: data['quizResults'] as Map<String, dynamic>? ?? {},
      photoURL: data['photoURL'] as String?,
    );
  }

  // Convert AppUser to a map for saving to Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'mi': mi,
      'suffix': suffix,
      'phoneNumber': phoneNumber,
      'accountType': accountType,
      'level': level,
      'orgId': orgId,
      'experience': experience,
      'completedChallenges': completedChallenges,
      'completedDebuggingChallenges': completedDebuggingChallenges,
      'quizResults': quizResults,
      'photoURL': photoURL,
    };
  }

  @override
  String toString() {
    return 'AppUser{id: $id, email: $email, displayName: $displayName, firstName: $firstName, lastName: $lastName, mi: $mi, suffix: $suffix, phoneNumber: $phoneNumber, accountType: $accountType, level: $level, orgId: $orgId, experience: $experience, completedChallenges: $completedChallenges, completedDebuggingChallenges: $completedDebuggingChallenges, quizResults: $quizResults, photoURL: $photoURL}';
  }

  // Add a method to check if the user is empty
  // if the nullable fields are null, then the user is empty
  // if the string fields are empty, then the user is empty
  bool isEmpty() {
    return id == null &&
        email == null &&
        displayName == null &&
        firstName == null &&
        lastName == null &&
        mi == null &&
        suffix == null &&
        phoneNumber == null &&
        accountType == null &&
        level == null &&
        orgId == null &&
        experience == null &&
        completedChallenges == null &&
        completedDebuggingChallenges == null &&
        quizResults.isEmpty &&
        photoURL == null;
  }
}
