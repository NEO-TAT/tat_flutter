import 'package:flutter/cupertino.dart';
import 'package:sprintf/sprintf.dart';

enum LogMode{
  LogError,
  LogDebug
}

class Log{
  static String _lastLog = "";
  static void e( String data ) {
    myLog( LogMode.LogError , data );
  }

  static void error( String data ) {
    myLog( LogMode.LogError , data );
  }


  static void d(String data ) {
    myLog( LogMode.LogDebug , data );
  }


  static myLog(LogMode mode , String data ){
    String log;
    String nowLog = _getFileLogDebug();
    String printLog = "";
    String printMode = "";
    switch(mode){
      case LogMode.LogDebug:
        printLog = _getFileLogDebug();
        printMode = "Debug";
        break;
      case LogMode.LogError:
        printLog = _getFileLogError();
        printMode = "Error";
        break;
    }
    if ( _lastLog != nowLog ){
      print("\n\n");
      log = sprintf( "LogLevel: %s \nClass : %s \nMessage : \n%s" , [ printMode , printLog , data] );
    }
    else{
      log = sprintf( "%s" , [ data] );
    }
    _lastLog = nowLog;
    _printWrapped(log);
  }

  static void _printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  static String _getFileLogError(){
    String log = buildLog(StackTrace.current.toString());
    return log;
  }

  static String _getFileLogDebug(){
    String log = StackTrace.current.toString();
    return log.split('\n')[3].replaceFirst("#3      ", "");
  }

  static String buildLog(String inputLog){
    List<String> logList = inputLog.split("#");
    String log = "";
    int size = (logList.length >= 20) ? 20 : logList.length;
    for ( String logItem in logList.sublist(0,size) ){
      log += '#' + logItem + "\n";
    }
    return log;
  }

}