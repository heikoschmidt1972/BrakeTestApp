import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
//import 'package:flutter/foundation.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<UdpSocketService>(create: (_) => udpSocketService),
        ChangeNotifierProvider<UdpDataProvider>(
          create: (context) => UdpDataProvider(udpSocketService),
        ),
      ],
      child: MyApp(),
    ),
  );
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

class StreamServiceTest {
  final _controller = StreamController<int>.broadcast();
  Stream<int> get stream => _controller.stream;

  StreamServiceTest() {
    _initializeit();
  }

  void _initializeit() async {
    bool _hook = true;
    int i = 0;

    while (_hook) {
      await Future.delayed(Duration(milliseconds: 1000));
      i++;
      _controller.add(i);
    }
  }

  void dispose() {
    _controller?.close();
  }
}

class UdpDataProvider extends ChangeNotifier {
  final StreamServiceTest _udpSocketService;
  int _latestData = 0;

  UdpDataProvider(this._udpSocketService) {
    _udpSocketService.stream.listen((data) {
      _latestData = data;
      notifyListeners();
    });
  }

  int get latestData => _latestData;
}

class UdpSocketService {
  final _controller = StreamController<List<int>>.broadcast();
  RawDatagramSocket? _socket;

  UdpSocketService() {
    //_initializeSocket();
  }

  Stream<List<int>> get stream => _controller.stream;

//  void _initializeSocket() async {
//    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 12345);
//    if (_socket != null) {
//      _socket?.listen((RawSocketEvent event) {
//        if (event == RawSocketEvent.read) {
//          Datagram datagram = _socket.receive();
//          if (datagram != null) {
//            _controller.add(datagram.data);
//          }
//        }
//      });
//    }
//  }

  void dispose() {
    _socket?.close();
    _controller?.close();
  }
}

class Counterprovider extends ChangeNotifier {
  int _counter = 0;

  int get counter {
    return _counter;
  }

  set counter(value) {
    _counter = value;
  }

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  void decrementCounter() {
    _counter--;
    notifyListeners();
  }

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
}

class MyHomePage_v2 extends StatelessWidget {
  final String title;

  const MyHomePage_v2({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<Counterprovider>();
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
