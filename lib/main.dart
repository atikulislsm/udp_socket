import 'dart:io';
import 'package:flutter/material.dart';
import 'package:udp/udp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UDP? udpReceiver;
  UDP? udpSender;
  String receivedMessage = '';

  final TextEditingController ipController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    startUdpServer();
  }

  @override
  void dispose() {
    udpReceiver?.close();
    udpSender?.close();
    ipController.dispose();
    portController.dispose();
    messageController.dispose();
    super.dispose();
  }

  void startUdpServer() async {
    udpReceiver = await UDP.bind(Endpoint.any(port: Port(12345)));

    udpReceiver?.asStream().listen((datagram) {
      final message = String.fromCharCodes(datagram!.data);
      setState(() {
        receivedMessage = message;
      });
    });
  }

  void sendUdpMessage(String message, String ipAddress, int port) async {
    udpSender ??= await UDP.bind(Endpoint.any());

    final data = message.codeUnits;
    await udpSender!.send(data, Endpoint.unicast(InternetAddress(ipAddress), port: Port(port)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter UDP Example'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: ipController,
              decoration: InputDecoration(labelText: 'Enter IP Address'),
            ),
            TextField(
              controller: portController,
              decoration: InputDecoration(labelText: 'Enter Port'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Enter message'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final message = messageController.text;
                final ipAddress = ipController.text;
                final port = int.tryParse(portController.text) ?? 12345;

                sendUdpMessage(message, ipAddress, port);
                messageController.clear();
              },
              child: Text('Send Message'),
            ),
            SizedBox(height: 20),
            Text('Received Message: $receivedMessage'),
          ],
        ),
      ),
    );
  }
}
