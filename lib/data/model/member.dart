class Member {
  final String id;
  final String firstName;
  final String lastName;
  final int birthYear;
  final String relationship;
  final String avatar;
  final String status;
  bool screenTimeEnabled;

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthYear,
    required this.relationship,
    required this.avatar,
    required this.status,
    required this.screenTimeEnabled,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    birthYear: json['birthYear'] as int,
    relationship: json['relationship'] as String,
    avatar: json['avatar'] as String,
    status: json['status'] as String,
    screenTimeEnabled: json['screenTimeEnabled'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'birthYear': birthYear,
    'relationship': relationship,
    'avatar': avatar,
    'status': status,
    'screenTimeEnabled': screenTimeEnabled,
  };

  String get fullName => '$firstName $lastName';

  int get age => DateTime.now().year - birthYear;

  Member copyWith({
    String? id,
    String? firstName,
    String? lastName,
    int? birthYear,
    String? relationship,
    String? avatar,
    String? status,
    bool? screenTimeEnabled,
  }) {
    return Member(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthYear: birthYear ?? this.birthYear,
      relationship: relationship ?? this.relationship,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      screenTimeEnabled: screenTimeEnabled ?? this.screenTimeEnabled,
    );
  }
}
