class UserProfile {
  UserProfile({
    this.ageRange,
    this.gender,
    this.relationship,
    this.occupation,
    this.stressLevel,
    this.sleepSchedule,
    this.zodiacSign,
    this.usagePurpose,
  });

  final String? ageRange;
  final String? gender;
  final String? relationship;
  final String? occupation;
  final String? stressLevel;
  final String? sleepSchedule;
  final String? zodiacSign;
  final String? usagePurpose;

  Map<String, dynamic> toMap() => {
        'ageRange': ageRange,
        'gender': gender,
        'relationship': relationship,
        'occupation': occupation,
        'stressLevel': stressLevel,
        'sleepSchedule': sleepSchedule,
        'zodiacSign': zodiacSign,
        'usagePurpose': usagePurpose,
      };

  factory UserProfile.fromMap(Map<String, dynamic>? map) => UserProfile(
        ageRange: map?['ageRange'] as String?,
        gender: map?['gender'] as String?,
        relationship: map?['relationship'] as String?,
        occupation: map?['occupation'] as String?,
        stressLevel: map?['stressLevel'] as String?,
        sleepSchedule: map?['sleepSchedule'] as String?,
        zodiacSign: map?['zodiacSign'] as String?,
        usagePurpose: map?['usagePurpose'] as String?,
      );
}
