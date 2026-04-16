class UserProfile {
  UserProfile({
    this.birthDate,
    this.gender,
    this.relationship,
    this.occupation,
    this.stressLevel,
    this.sleepLevel,
    this.zodiacSign,
    this.usagePurpose,
  });

  final String? birthDate;
  final String? gender;
  final String? relationship;
  final String? occupation;
  final String? stressLevel;
  final String? sleepLevel;
  final String? zodiacSign;
  final String? usagePurpose;

  Map<String, dynamic> toMap() => {
        'birthDate': birthDate,
        'gender': gender,
        'relationship': relationship,
        'occupation': occupation,
        'stressLevel': stressLevel,
        'sleepLevel': sleepLevel,
        'zodiacSign': zodiacSign,
        'usagePurpose': usagePurpose,
      };

  factory UserProfile.fromMap(Map<String, dynamic>? map) => UserProfile(
        birthDate: map?['birthDate'] as String?,
        gender: map?['gender'] as String?,
        relationship: map?['relationship'] as String?,
        occupation: map?['occupation'] as String?,
        stressLevel: map?['stressLevel'] as String?,
        sleepLevel: (map?['sleepLevel'] ?? map?['sleepSchedule']) as String?,
        zodiacSign: map?['zodiacSign'] as String?,
        usagePurpose: map?['usagePurpose'] as String?,
      );
}
