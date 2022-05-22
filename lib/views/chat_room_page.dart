import 'package:alumni/globals.dart';
import 'package:alumni/views/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatRooms extends StatefulWidget {
  const ChatRooms({Key? key}) : super(key: key);

  @override
  State<ChatRooms> createState() => _ChatRoomsState();
}

class _ChatRoomsState extends State<ChatRooms> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<types.Room>>(
      stream: chat!.rooms(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print(snapshot.data);
        }
        var rooms = snapshot.data;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: ListView.builder(
              itemCount: rooms!.length,
              itemBuilder: ((context, index) {
                var room = rooms[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: ((context) {
                          return ChatPage(room: room);
                        })));
                      },
                      leading: CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(room.imageUrl!),
                      ),
                      title: Text(room.users[1].firstName!),
                    ),
                  ),
                );
              })),
        );
      },
      initialData: const [],
    );
  }
}
