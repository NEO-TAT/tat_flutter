import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/debug/log/debug_log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const simpleTaskKey = "simpleTask";
const rescheduledTaskKey = "rescheduledTask";
const failedTaskKey = "failedTask";
const simpleDelayedTask = "simpleDelayedTask";
const simplePeriodicTask = "simplePeriodicTask";
const simplePeriodic1HourTask = "simplePeriodic1HourTask";

final _log = createNamedLog('BG_Debug_Page');

void callbackDispatcher() {
  final debugAreaName = (callbackDispatcher).toString();
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        _log('$simpleTaskKey was executed. inputData = $inputData', areaName: debugAreaName);

        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("test", true);
        _log('Bool from prefs: ${prefs.getBool("test")}', areaName: debugAreaName);

        break;
      case rescheduledTaskKey:
        final key = inputData!['key']!;
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('unique-$key')) {
          _log('has been running before, task is successful', areaName: debugAreaName);
          return true;
        }

        await prefs.setBool('unique-$key', true);
        _log('reschedule task', areaName: debugAreaName);

        return false;
      case failedTaskKey:
        _log('failed task', areaName: debugAreaName);
        return Future.error('failed');

      case simpleDelayedTask:
        _log('$simpleDelayedTask was executed', areaName: debugAreaName);
        break;

      case simplePeriodicTask:
        _log('$simplePeriodicTask was executed', areaName: debugAreaName);
        break;

      case simplePeriodic1HourTask:
        _log('$simplePeriodic1HourTask was executed', areaName: debugAreaName);
        break;

      case Workmanager.iOSBackgroundTask:
        _log('The iOS background fetch was triggered', areaName: debugAreaName);

        final tempDir = await getTemporaryDirectory();
        final tempPath = tempDir.path;

        _log('You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath',
            areaName: debugAreaName);
        break;
    }

    return Future.value(true);
  });
}

class BGServiceDebugPage extends StatelessWidget {
  const BGServiceDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter WorkManager Example"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Plugin initialization",
                style: Theme.of(context).textTheme.headline5,
              ),
              ElevatedButton(
                child: const Text("Start the Flutter background service"),
                onPressed: () {
                  Workmanager().initialize(
                    callbackDispatcher,
                    isInDebugMode: true,
                  );
                },
              ),
              const SizedBox(height: 16),

              //This task runs once.
              //Most likely this will trigger immediately
              ElevatedButton(
                child: const Text("Register OneOff Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    simpleTaskKey,
                    simpleTaskKey,
                    inputData: <String, dynamic>{
                      'int': 1,
                      'bool': true,
                      'double': 1.0,
                      'string': 'string',
                      'array': [1, 2, 3],
                    },
                  );
                },
              ),
              ElevatedButton(
                child: const Text("Register rescheduled Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    rescheduledTaskKey,
                    rescheduledTaskKey,
                    inputData: <String, dynamic>{
                      'key': Random().nextInt(64000),
                    },
                  );
                },
              ),
              ElevatedButton(
                child: const Text("Register failed Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    failedTaskKey,
                    failedTaskKey,
                  );
                },
              ),
              //This task runs once
              //This wait at least 10 seconds before running
              ElevatedButton(
                  child: const Text("Register Delayed OneOff Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      simpleDelayedTask,
                      simpleDelayedTask,
                      initialDelay: const Duration(seconds: 10),
                    );
                  }),
              const SizedBox(height: 8),
              //This task runs periodically
              //It will wait at least 10 seconds before its first launch
              //Since we have not provided a frequency it will be the default 15 minutes
              ElevatedButton(
                  onPressed: Platform.isAndroid
                      ? () {
                          Workmanager().registerPeriodicTask(
                            simplePeriodicTask,
                            simplePeriodicTask,
                            initialDelay: const Duration(seconds: 10),
                          );
                        }
                      : null,
                  child: const Text("Register Periodic Task (Android)")),
              //This task runs periodically
              //It will run about every hour
              ElevatedButton(
                  onPressed: Platform.isAndroid
                      ? () {
                          Workmanager().registerPeriodicTask(
                            simplePeriodicTask,
                            simplePeriodic1HourTask,
                            frequency: const Duration(hours: 1),
                          );
                        }
                      : null,
                  child: const Text("Register 1 hour Periodic Task (Android)")),
              const SizedBox(height: 16),
              Text(
                "Task cancellation",
                style: Theme.of(context).textTheme.headline5,
              ),
              ElevatedButton(
                child: const Text("Cancel All"),
                onPressed: () async {
                  await Workmanager().cancelAll();
                  _log('Cancel all tasks completed', areaName: (BGServiceDebugPage).toString());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
