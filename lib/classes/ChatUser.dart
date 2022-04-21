class ChatUsers {
  String name;
  String messageText;
  String imageURL;
  String time;
  ChatUsers(
      {required this.name,
      required this.messageText,
      this.imageURL = "/alumni/assets/profile_icon.jpg",
      required this.time});
}
