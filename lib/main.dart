import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitter-prediction',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Twitter-prediction Home'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  String _tweet = "";
  double positive = 0.00;
  double negative = 0.00;

  List<Widget> _getPieChart() {
    if (_tweet == "") {
      return [];
    }
    return [
      const Divider(height: 100),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
      ),
      Text("Tweet: \"$_tweet\""),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
      ),
      PieChart(
        dataMap: {
          "Positf": positive,
          "Négatif": negative,
        },
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: const [Colors.blue, Colors.red],
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: "Émotion",
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: true,
          decimalPlaces: 2,
        ),
      ),
    ];
  }

  Future<void> _onPress() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Response response = await Dio().post(
        "https://twitter-prediction.drfperso.ovh/predict",
        data: {
          "texts": [_tweet]
        },
      );
      double pos = double.parse(response.data["predictions"][0]["positif"]);
      double neg = double.parse(response.data["predictions"][0]["negative"]);
      setState(() {
        positive = pos;
        negative = neg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.title)),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
            ),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Write here your tweet'),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              validator: (value) {
                bool condition = value?.isEmpty ?? false;
                if (condition) {
                  return 'Please write a tweet';
                }
                return null;
              },
              onSaved: (value) => _tweet = value ?? "",
            ),
            ElevatedButton(
              onPressed: _onPress,
              child: const Text('Submit'),
            ),
            ..._getPieChart()
          ],
        ),
      ),
    );
  }
}
