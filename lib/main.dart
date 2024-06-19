import 'dart:async';
import 'dart:ffi';
import 'package:brake_test_app/Providers/braketest_templates.dart';
import 'package:brake_test_app/Speedometer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
//import 'package:flutter/foundation.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<Counterprovider>(
          create: (context) => Counterprovider()),
      ChangeNotifierProvider<MeasurementStateProvider>(
          create: (context) => MeasurementStateProvider()),
      ChangeNotifierProvider<BrakeTestTemplate_Provider>(
          create: (context) => BrakeTestTemplate_Provider()),
    ],
    child: MyApp(),
  ));
}

void main_old_01() {
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
      title: 'Brake-Test-App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Template_Page_v1(title: 'Home Page Stateless'),
    );
  }
}

class MeasurementStateProvider extends ChangeNotifier {
  double _speed = 0.0;
  String _sspeed = '';
  double _distance = 0.0;
  bool _brake_active = false;
  bool get brake_active => _brake_active;
  set brake_active(value) {
    _brake_active = value;
  }

  void ToggleBrake() {
    if (_brake_active == false)
      _brake_active = true;
    else
      _brake_active = false;

    notifyListeners();
  }
}

class Counterprovider extends ChangeNotifier {
  int _counter = 0;
  String _sspeed = '';
  double speed = 0.0;

  final _controller = StreamController<int>.broadcast();
  Stream<int> get stream => _controller.stream;
  late RawDatagramSocket _socket;

  Counterprovider() {}

  int get counter {
    return _counter;
  }

  double ConvertSpeedToDouble(String ss) {
    double s = 0.0;
    String sss = ss.replaceAll(".", ",");
    try {
      s = double.parse(ss);
    } on Exception catch (e) {
      // TODO
      s = 0.0;
    }

    return s;
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
                _sspeed = speed.toString();
                speed = ConvertSpeedToDouble(_sspeed);

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

class Template_Page_v1 extends StatelessWidget {
  final String title;

  const Template_Page_v1({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Daten von den Providern
    //
    final data = context.watch<Counterprovider>();
    final msp = context.watch<MeasurementStateProvider>();
    BrakeTestTemplate_Provider bttp =
        Provider.of<BrakeTestTemplate_Provider>(context);
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
            Speedometer(
                value: data.speed, width: 180, height: 180, maxspeed: 50),
            SizedBox(height: 12),
            const Text(
              'You have pushed the button this many times:',
            ),

            //==================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                    onPressed: () {
                      data._socket.close();
                    },
                    child: Text('Stoppe Socket')),
                //==================================================
                ElevatedButton(
                    onPressed: () {
                      msp.ToggleBrake();
                    },
                    child: Text('Toggle Brake')),
              ],
            ),
            Container(
              width: 360,
              height: 350,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryFixed,
                  borderRadius: BorderRadius.circular(4)),
              child: ReorderableListView(
                padding: const EdgeInsets.all(10),
                children: [
                  for (final BrakeTestTemplateItem_Provider tile in bttp.ListOf)
                    Padding(
                      key: ValueKey(tile),
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.grey[200],
                        ),
                        child: ListTile(
                          title: Text(
                            tile.type_of_Brake,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(tile.loadState,
                              style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ),
                ],
                onReorder: (oldIndex, newIndex) {
                  bttp.reorderTemplateItems(oldIndex, newIndex);
                },
              ),
            ),
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

class MyHomePage_v2 extends StatelessWidget {
  final String title;

  const MyHomePage_v2({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Daten von den Providern
    //
    final data = context.watch<Counterprovider>();
    final msp = context.watch<MeasurementStateProvider>();
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
            Speedometer(
                value: data.speed, width: 180, height: 180, maxspeed: 50),
            SizedBox(height: 12),
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'Counter is',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              data.speed.toStringAsFixed(2),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            //Text( msp.brake_active ?? 'Aktiv' : 'passiv'),
            Checkbox(
              value: msp.brake_active,
              onChanged: (value) {},
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
                  data._socket.close();
                },
                child: Text('Stoppe Socket')),
            //==================================================
            ElevatedButton(
                onPressed: () {
                  msp.ToggleBrake();
                },
                child: Text('Toggle Brake')),
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
