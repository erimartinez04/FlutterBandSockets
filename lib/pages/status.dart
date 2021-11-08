import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/socket_service.dart';
import 'package:provider/provider.dart';

class statusPage extends StatelessWidget {
  const statusPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('ServerStatus:3  ${socketService.serverStatus}')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.message),
          onPressed: () {
            socketService.socket.emit('Flutter_emit',
                {'name': 'Flutter', 'message': 'Hi from Flutter'});
          }),
    );
  }
}
