class ChatUserModel {
  ChatUserModel({
    required this.createdAt,
    required this.image,
    required this.lastActive,
    required this.name,
    required this.about,
    required this.id,
    required this.isOnline,
    required this.pushToken,
    required this.email,
  });
  late String createdAt;
  late String image;
  late String lastActive;
  late String name;
  late String about;
  late String id;
  late bool isOnline;
  late String pushToken;
  late String email;

  ChatUserModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'] ?? '';
    image = json['image'] ?? '';
    lastActive = json['lastActive'] ?? '';
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    id = json['id'] ?? '';
    isOnline = json['is_online'] ?? '';
    pushToken = json['pushToken'] ?? '';
    email = json['email'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['createdAt'] = createdAt;
    _data['image'] = image;
    _data['lastActive'] = lastActive;
    _data['name'] = name;
    _data['about'] = about;
    _data['id'] = id;
    _data['is_online'] = isOnline;
    _data['pushToken'] = pushToken;
    _data['email'] = email;
    return _data;
  }
}
