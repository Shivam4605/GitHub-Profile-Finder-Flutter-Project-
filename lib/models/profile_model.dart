class ProfileModel {
  String? profileImage;
  String? name;
  String? bio;
  String? follower;
  String? following;
  String? repocount;
  String? createdAt;
  String? userName;

  ProfileModel({
    required this.bio,
    required this.createdAt,
    required this.follower,
    required this.following,
    required this.name,
    required this.repocount,
    required this.profileImage,
    required this.userName,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      bio: json['bio']?.toString() ?? "",
      createdAt: json['created_at']?.toString() ?? "",
      follower: json['followers']?.toString() ?? "0",
      following: json['following']?.toString() ?? "0",
      name: json['name']?.toString() ?? "",
      repocount: json['public_repos']?.toString() ?? "0",
      profileImage: json['avatar_url']?.toString() ?? "",
      userName: json['login']?.toString() ?? "",
    );
  }
}
