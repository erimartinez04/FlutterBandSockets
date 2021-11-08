import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/band.dart';
import 'package:flutter_application_1/services/socket_service.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
          title:
              const Text("BandNames", style: TextStyle(color: Colors.black87)),
          elevation: 1,
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                  ? Icon(Icons.check_circle, color: Colors.blue[300])
                  : Icon(Icons.offline_bolt, color: Colors.red[300]),
            )
          ],
          backgroundColor: Colors.white),
      body: Column(
        children: <Widget>[
          showGraphics(),
          Expanded(
              child: ListView.builder(
            itemCount: bands.length,
            itemBuilder: (context, i) => _bandTile(bands[i]),
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        elevation: 1,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => {
        socketService.socket.emit('deleteBand', {'id': band.id})
      },
      background: Container(
        color: Colors.red[300],
        padding: const EdgeInsets.only(left: 9.0),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle(color: Colors.white)),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
        onTap: () => {
          socketService.socket.emit('vote-band', {'id': band.id})
        },
      ),
    );
  }

  List<Band> bands = [
    /* Band(id: "1", name: "Metallica", votes: 5),
    Band(id: "2", name: "Queen", votes: 1),
    Band(id: "3", name: "Aerosmith", votes: 2),
    Band(id: "4", name: "Guns & Roses", votes: 5) */
  ];
  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('activeBands', handleActiveBands);

    super.initState();
  }

  handleActiveBands(dynamic payload) {
    print(payload);
    bands = (payload as List).map((ban) => Band.fromMap(ban)).toList();
    setState(() {});
  }

  addNewBand() {
    final textController = new TextEditingController();
    if (Platform.isAndroid) {
// Android
      return showDialog(
          context: context,
          builder: (contex) {
            return AlertDialog(
              title: const Text(
                'New Band Name:',
                style: TextStyle(color: Colors.blue),
              ),
              content: TextField(controller: textController),
              actions: <Widget>[
                MaterialButton(
                    textColor: Colors.blue,
                    child: const Text('Add'),
                    elevation: 5,
                    onPressed: () => {addBandToList(textController.text)})
              ],
            );
          });
    } else if (Platform.isIOS) {
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title:
                  Text('New Band Name:', style: TextStyle(color: Colors.blue)),
              content: CupertinoTextField(
                controller: textController,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                    isDefaultAction: true,
                    child: const Text('Add'),
                    onPressed: () => {addBandToList(textController.text)}),
                CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: const Text('Dismiss'),
                    onPressed: () => Navigator.pop(context))
              ],
            );
          });
    }
  }

  void addBandToList(String name) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
      socketService.socket.emit('addBand', {'name': name});
      //setState(() {});
      //add band
    }
    Navigator.pop(context);
  }

  Widget showGraphics() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    return Container(
        padding: EdgeInsets.only(top: 10),
        width: double.infinity,
        height: 200,
        child: PieChart(dataMap: dataMap));
  }
}
