import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
//import 'package:flutter/foundation.dart';

void main() {
  runApp(ChangeNotifierProvider<Counterprovider>(
    create: (context) => Counterprovider(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage_v2(title: 'Home Page Stateless'),
    );
  }
}

class Counterprovider extends ChangeNotifier {
  int _counter = 0;
  final _controller = StreamController<int>.broadcast();
  Stream<int> get stream => _controller.stream;
  late RawDatagramSocket _socket;

  Counterprovider() {}

  int get counter {
    return _counter;
  }

//  void initSocket() async {
//    clientSocket = await RawDatagramSocket.bind(
//      InternetAddress.anyIPv4,
//      this.port,
//    );
//
//    clientSocket.broadcastEnabled = true;
//  }
  void _initializeSocket() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 7800);
    _counter = -1000;
    notifyListeners();
    int myval = 0;

    try {
      _socket.listen((event) {
        switch (event) {
          case RawSocketEvent.read:
            final datagram = _socket.receive();

            if (datagram?.data != null) {
              String message =
                  String.fromCharCodes(datagram?.data ?? Uint8List(0));
              if (message.length > 0) {
                // hier muss dann eigentlich die Decodierung des JSON-Strings erfolgen
                var response = json.decode(message);
                var speed = response['data']['speed'];
                //var dist = response['data']['brakedistance'];
                //var acc = response['data']['acceleration'];
                // try {
                //   myval = int.parse(speed);
                //
                //   print(myval);
                //
                //   //notifyListeners();
                // } on Exception catch (e) {
                // print(e)
                //_counter = -2000;
                //   notifyListeners();
                // }
                _counter++; // = int.parse(speed);
                notifyListeners();
              }

              //InternetAddress senderAddress = datagram.address';
              //int senderPort = datagram?.port ?? 0;

              //print(
              //    'Received UDP message from SenderAddress:$senderPort: $message');
            }
            //_socket.close();
            break;
          case RawSocketEvent.write:
            /* if (clientSocket.send(ntpQuery, serverAddress, 123) > 0) {
              clientSocket.writeEventsEnabled = false;
            } */
            break;
          case RawSocketEvent.closed:
            break;
          default:
            throw "Unexpected event $event";
        }
      });
    } on Exception catch (e) {
      print(e.toString());
      // TODO
    }
  }

  void _OnSocketData() {}

  set counter(value) {
    _counter = value;
  }

  void StartTimer() async {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      _counter++;
      notifyListeners();
    });
  }

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  void decrementCounter() {
    _counter--;
    notifyListeners();
  }

  /*
  Stream<int?> Receiver() async* {
    // var random = Random(2);
    int port = 7800;
    bool _hook = true;

    InternetAddress ip = InternetAddress('192.168.0.23');
    String? ntpstring = '';
    final clientSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      port,
    );

    clientSocket.broadcastEnabled = true;

    while (_hook) {
      await Future.delayed(Duration(milliseconds: 500));
      _counter++;
      notifyListeners();
      yield this._counter;
      continue;

      final ntpQuery = Uint8List(48);
      ntpQuery[0] = 0x23; // See RFC 5905 7.3

      clientSocket.listen((event) {
        switch (event) {
          case RawSocketEvent.read:
            final datagram = clientSocket.receive();

            if (datagram?.data != null) {
              String message =
                  String.fromCharCodes(datagram?.data ?? Uint8List(0));
              ntpstring = message;
//InternetAddress senderAddress = datagram.address';
              int senderPort = datagram?.port ?? 0;

              //print(
              //    'Received UDP message from SenderAddress:$senderPort: $message');
            } else
              ntpstring = 'Null';

            clientSocket.close();
            break;
          case RawSocketEvent.write:
            /* if (clientSocket.send(ntpQuery, serverAddress, 123) > 0) {
                clientSocket.writeEventsEnabled = false;
              } */
            break;
          case RawSocketEvent.closed:
            break;
          default:
            throw "Unexpected event $event";
        }
      });

      yield ntpstring;
    }
  }
*/
}

class MyHomePage_v2 extends StatelessWidget {
  final String title;

  const MyHomePage_v2({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Daten von den Providern
    //
    final data = context.watch<Counterprovider>();
    //
    //

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'Counter is ${data.counter.toString()}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
                onPressed: () {
                  data.decrementCounter();
                },
                child: Text('---')),
            ElevatedButton(
                onPressed: () {
                  data.StartTimer();
                },
                child: Text('Starte Timer')),
            //================================
            ElevatedButton(
                onPressed: () {
                  data._initializeSocket();
                },
                child: Text('Starte Socket')),
            //==================================================
            ElevatedButton(
                onPressed: () {
                  data.StartTimer();
                },
                child: Text('Stoppe Socket')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          data.incrementCounter();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
