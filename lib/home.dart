import 'dart:async';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'bar_chart.dart';
import 'bloc/hour_bloc.dart';
import 'bloc/minute_bloc.dart';
import 'notification_api.dart';
import '../clock/clock.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String hour = '0';
  String minute = '0';
  bool isActived = false;
  bool isAm = true;
  List<bool> isSelected = List.generate(2, (index) => false);

  @override
  void initState() {
    super.initState();
    NotificationApi.init();
    listenNotification();
    isSelected[0] = true;
  }

  void listenNotification() =>
      NotificationApi.onNotification.stream.listen(onClickNotification);

  void onClickNotification(String? payload) {
    showModalBottomSheet<void>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: BarChart(
            data: [
              TimeOpen(
                payload,
                DateTime.now().difference(DateTime.parse(payload!)).inSeconds,
                charts.ColorUtil.fromDartColor(
                  Colors.blue,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void showSnackBar() {
    String formattedDate = DateFormat('yyyy-MM-dd  hh:mm a').format(
      setDateTime(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alarm active for $formattedDate'),
      ),
    );
  }

  DateTime setDateTime() {
    DateTime now = DateTime.now();
    return DateTime(
        now.year,
        now.month,
        now.hour > (isAm ? int.parse(hour) : int.parse(hour) + 12)
            ? now.day + 1
            : now.hour == (isAm ? int.parse(hour) : int.parse(hour) + 12) &&
                    now.minute >= int.parse(minute) &&
                    now.second > 0
                ? now.day + 1
                : now.day,
        isAm ? int.parse(hour) : int.parse(hour) + 12,
        int.parse(minute));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analog Alarm App',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          const Clock(),
          Container(
            margin: const EdgeInsets.all(30),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BlocBuilder<HourBloc, HourState>(
                      builder: (context, state) {
                        Future.delayed(Duration.zero, () {
                          if (state is LoadedHour) {
                            setState(() {
                              hour = state.hour;
                            });
                          }
                        });
                        return Text(state is LoadedHour ? state.hour : '00',
                            style: const TextStyle(
                                fontSize: 54, fontWeight: FontWeight.bold));
                      },
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(':',
                        style:
                            TextStyle(fontSize: 54, fontWeight: FontWeight.bold)),
                    const SizedBox(
                      width: 5,
                    ),
                    BlocBuilder<MinuteBloc, MinuteState>(
                      builder: (context, state) {
                        Future.delayed(Duration.zero, () {
                          if (state is LoadedMinute) {
                            setState(() {
                              minute = state.minute;
                            });
                          }
                        });
                        return Text(state is LoadedMinute ? state.minute : '00',
                            style: const TextStyle(
                                fontSize: 54, fontWeight: FontWeight.bold));
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ToggleButtons(
                        selectedColor: Colors.blue,
                        borderRadius: BorderRadius.circular(25),
                        children: const [
                          Text(
                            'AM',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'PM',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelected.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isAm = index == 0 ? true : false;
                                isActived = false;
                                isSelected[buttonIndex] = true;
                                NotificationApi.cancel();
                              } else {
                                isSelected[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        isSelected: isSelected,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        isActived ? 'On' : 'Off',
                        style: TextStyle(
                          color: isActived ? Colors.blue : Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Switch(
                        value: isActived,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            isActived = value;
                            if (isActived) {
                              NotificationApi.showNotificationSchedule(
                                  title: 'Alarm',
                                  body: 'Your alarm is on',
                                  payload: setDateTime().toString(),
                                  scheduleDate: setDateTime());
                              Future.delayed(
                                  Duration(
                                      seconds: setDateTime()
                                          .difference(DateTime.now())
                                          .inSeconds), () {
                                isActived = false;
                              });
                              showSnackBar();
                            } else {
                              NotificationApi.cancel();
                            }
                          });
                        })
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}