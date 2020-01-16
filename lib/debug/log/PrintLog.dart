import 'package:sprintf/sprintf.dart';

class Log{

  static void e(String file , String data) {
    String log = sprintf( "LogLevel: Error , Class : %10s , %s" , [file , data] );
    print(log);
  }

  static void d(String file , String data) {
    String log = sprintf( "LogLevel: Debug , Class : %10s , %s" , [file , data] );
    print(log);
  }

}