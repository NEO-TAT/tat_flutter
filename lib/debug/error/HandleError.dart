import 'package:sprintf/sprintf.dart';

class HandleError {
  static void sendError(String file , Exception e){
    String error = sprintf( "File : %s , Error : %s" , [file , e.toString() ]);
    print( error );
  }
}