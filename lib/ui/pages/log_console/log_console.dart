import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import 'ansi_parser.dart';

ListQueue<OutputEvent> _outputEventBuffer = ListQueue();
int _bufferSize = 50;
bool _initialized = false;

class MyConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    event.lines.forEach(print);
    if (_outputEventBuffer.length == _bufferSize) {
      _outputEventBuffer.removeFirst();
    }
    _outputEventBuffer.add(event);
  }
}

class LogConsole extends StatefulWidget {
  final bool dark;

  LogConsole({this.dark = false})
      : assert(_initialized, "Please call LogConsole.init() first.");

  static void init({int bufferSize = 50}) {
    if (_initialized) return;
    _bufferSize = bufferSize;
    _initialized = true;
  }

  static String getLog() {
    bool error = false;
    List<OutputEvent> events = [];
    for (OutputEvent event in _outputEventBuffer) {
      events.add(event);
    }
    String log = "";
    for (int i = 0; i < events.length; i++) {
      OutputEvent event = events[i];
      if (event.level == Level.error) {
        error = true;
        log += event.lines.join("\n");
      }
    }
    if (error) {
      log = log.replaceAll(
          "┌───────────────────────────────────────────────────────────", "");
      log = log.replaceAll(
          "└───────────────────────────────────────────────────────────", "");
      log = log.replaceAll(
          "├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄", "");
      log = log.replaceAll("├", "");
      log = log.replaceAll("│", "");
      return log.substring(0, (log.length > 2000) ? 2000 : log.length);
    } else {
      return "沒有任何錯誤";
    }
  }

  @override
  _LogConsoleState createState() => _LogConsoleState();
}

class RenderedEvent {
  final int id;
  final Level level;
  final TextSpan span;
  final String lowerCaseText;

  RenderedEvent(this.id, this.level, this.span, this.lowerCaseText);
}

class _LogConsoleState extends State<LogConsole> {
  ListQueue<RenderedEvent> _renderedBuffer = ListQueue();
  List<RenderedEvent> _filteredBuffer = [];

  var _scrollController = ScrollController();
  var _filterController = TextEditingController();

  Level _filterLevel = Level.verbose;
  double _logFontSize = 14;

  var _currentId = 0;
  bool _scrollListenerEnabled = true;
  bool _followBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollListenerEnabled) return;
      var scrolledToBottom = _scrollController.offset >=
          _scrollController.position.maxScrollExtent;
      setState(() {
        _followBottom = scrolledToBottom;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _renderedBuffer.clear();
    for (var event in _outputEventBuffer) {
      _renderedBuffer.add(_renderEvent(event));
    }
    _refreshFilter();
  }

  void _refreshFilter() {
    var newFilteredBuffer = _renderedBuffer.where((it) {
      var logLevelMatches = it.level.index >= _filterLevel.index;
      if (!logLevelMatches) {
        return false;
      } else if (_filterController.text.isNotEmpty) {
        var filterText = _filterController.text.toLowerCase();
        return it.lowerCaseText.contains(filterText);
      } else {
        return true;
      }
    }).toList();
    setState(() {
      _filteredBuffer = newFilteredBuffer;
    });

    if (_followBottom) {
      Future.delayed(Duration.zero, _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: widget.dark
          ? ThemeData(
              brightness: Brightness.dark,
              accentColor: Colors.blueGrey,
            )
          : ThemeData(
              brightness: Brightness.light,
              accentColor: Colors.lightBlueAccent,
            ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          title: Text("Log Console"),
          actions: [
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _outputEventBuffer.clear();
                didChangeDependencies();
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _logFontSize++;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  _logFontSize--;
                });
              },
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: _buildLogContent(),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
        floatingActionButton: AnimatedOpacity(
          opacity: _followBottom ? 0 : 1,
          duration: Duration(milliseconds: 150),
          child: Padding(
            padding: EdgeInsets.only(bottom: 60),
            child: FloatingActionButton(
              mini: true,
              clipBehavior: Clip.antiAlias,
              child: Icon(
                Icons.arrow_downward,
                color: widget.dark ? Colors.white : Colors.lightBlue[900],
              ),
              onPressed: _scrollToBottom,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogContent() {
    return Container(
      color: widget.dark ? Colors.black : Colors.grey[150],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1600,
          child: ListView.builder(
            shrinkWrap: true,
            controller: _scrollController,
            itemBuilder: (context, index) {
              var logEntry = _filteredBuffer[index];
              return Text.rich(
                logEntry.span,
                key: Key(logEntry.id.toString()),
                style: TextStyle(fontSize: _logFontSize),
              );
            },
            itemCount: _filteredBuffer.length,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return LogBar(
      dark: widget.dark,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: TextField(
              style: TextStyle(fontSize: 20),
              controller: _filterController,
              onChanged: (s) => _refreshFilter(),
              decoration: InputDecoration(
                labelText: "Filter log output",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(width: 20),
          DropdownButton(
            value: _filterLevel,
            items: [
              DropdownMenuItem(
                child: Text("Verbose"),
                value: Level.verbose,
              ),
              DropdownMenuItem(
                child: Text("Debug"),
                value: Level.debug,
              ),
              DropdownMenuItem(
                child: Text("Info"),
                value: Level.info,
              ),
              DropdownMenuItem(
                child: Text("Warning"),
                value: Level.warning,
              ),
              DropdownMenuItem(
                child: Text("Error"),
                value: Level.error,
              ),
              DropdownMenuItem(
                child: Text("WTF"),
                value: Level.wtf,
              ),
              DropdownMenuItem(
                child: Text("Nothing"),
                value: Level.nothing,
              )
            ],
            onChanged: (value) {
              _filterLevel = value;
              _refreshFilter();
            },
          )
        ],
      ),
    );
  }

  void _scrollToBottom() async {
    _scrollListenerEnabled = false;

    setState(() {
      _followBottom = true;
    });

    var scrollPosition = _scrollController.position;
    await _scrollController.animateTo(
      scrollPosition.maxScrollExtent,
      duration: new Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );

    _scrollListenerEnabled = true;
  }

  RenderedEvent _renderEvent(OutputEvent event) {
    var parser = AnsiParser(widget.dark);
    var text = event.lines.join('\n');
    parser.parse(text);
    return RenderedEvent(
      _currentId++,
      event.level,
      TextSpan(children: parser.spans),
      text.toLowerCase(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class LogBar extends StatelessWidget {
  final bool dark;
  final Widget child;

  LogBar({this.dark, this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            if (!dark)
              BoxShadow(
                color: Colors.grey[400],
                blurRadius: 3,
              ),
          ],
        ),
        child: Material(
          color: dark ? Colors.blueGrey[900] : Colors.white,
          child: Padding(
            padding: EdgeInsets.fromLTRB(15, 8, 15, 8),
            child: child,
          ),
        ),
      ),
    );
  }
}
