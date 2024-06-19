import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

class BrakeTestTemplatWidget extends StatelessWidget {
  final String title;
  const BrakeTestTemplatWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Daten von den Providern
    //
    //final data = context.watch<Counterprovider>();
    //final msp = context.watch<MeasurementStateProvider>();
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
          children: <Widget>[],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //data.incrementCounter();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
