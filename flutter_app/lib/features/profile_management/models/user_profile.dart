class UserProfile {
  UserProfile({
    this.email,
    this.fcmToken,
    this.referCode,
    this.firebaseId,
    this.mobileNumber,
    this.name,
    this.profileUrl,
    this.userId,
    this.allTimeRank,
    this.allTimeScore,
    this.coins,
    this.registeredDate,
    this.status,

  });

  UserProfile.fromJson(Map<String, dynamic> json)
      : allTimeRank = json['all_time_rank'] as String? ?? '',
        mobileNumber = json['mobile'] as String? ?? '',
        name = json['name'] as String? ?? '',
        profileUrl = json['profile'] as String? ?? '',
        registeredDate = json['date_registered'] as String? ?? '',
        status = json['status'] as String? ?? '',
        userId = json['id'] as String? ?? '',
        firebaseId = json['firebase_id'] as String? ?? '',
        allTimeScore = json['all_time_score'] as String? ?? '',
        coins = json['coins'] as String? ?? '',
        referCode = json['refer_code'] as String? ?? '',
        fcmToken = json['fcm_id'] as String? ?? '',
        email = json['email'] as String? ?? '';

  final String? name;
  final String? userId;
  final String? firebaseId;
  final String? profileUrl;
  final String? email;
  final String? mobileNumber;
  final String? status;
  final String? allTimeScore;
  final String? allTimeRank;
  final String? coins;
  final String? registeredDate;
  final String? referCode;

  final String? fcmToken;


  UserProfile copyWith({
    String? profileUrl,
    String? name,
    String? allTimeRank,
    String? allTimeScore,
    String? coins,
    String? status,
    String? mobile,
    String? email,

  }) {
    return UserProfile(
      fcmToken: fcmToken,
      userId: userId,
      profileUrl: profileUrl ?? this.profileUrl,
      email: email ?? this.email,
      name: name ?? this.name,
      firebaseId: firebaseId,
      referCode: referCode,
      allTimeRank: allTimeRank ?? this.allTimeRank,
      allTimeScore: allTimeScore ?? this.allTimeScore,
      coins: coins ?? this.coins,
      mobileNumber: mobile ?? mobileNumber,
      registeredDate: registeredDate,
      status: status ?? this.status,

    );
  }

  UserProfile copyWithProfileData(String? name, String? mobile, String? email) {
    return UserProfile(
      fcmToken: fcmToken,
      referCode: referCode,
      userId: userId,
      profileUrl: profileUrl,
      email: email,
      name: name,
      firebaseId: firebaseId,
      allTimeRank: allTimeRank,
      allTimeScore: allTimeScore,
      coins: coins,
      mobileNumber: mobile,
      registeredDate: registeredDate,
      status: status,

    );
  }

}
