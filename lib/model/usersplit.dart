class Usersplit {
  final int? userID;
  final String? username;
  final String? avatar;

  Usersplit({this.userID, this.username, this.avatar});

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'username': username,
      'avatar': avatar,
    };
  }

  factory Usersplit.fromMap(Map<String, dynamic> map) {
    return Usersplit(
      userID: map['userID'],
      username: map['username'],
      avatar: map['avatar'],
    );
  }
}