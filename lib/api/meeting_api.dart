import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:resoluteai/utils/user.utils.dart';


String MEETING_API_URL = "http://192.168.96.48:4000/api/meeting";

var client = http.Client();

Future<http.Response?> startMeeting() async{
  Map<String,String> requestHeaders = {'Content-Type' : 'application/json'};
   var userId = await loadUserId();

   var response = await client.post(Uri.parse('$MEETING_API_URL/start'),
   headers: requestHeaders,
   body: jsonEncode({'hostId': userId,'hostName': ''}));

   if(response.statusCode == 200){
     print("Success");
     return response;
   }else{
     print(response.statusCode);
     return null;
   }
}

Future<http.Response?> joinUser(String id,String name) async{
  Map<String,String> requestHeaders = {'Content-Type' : 'application/json'};
  var userId = await loadUserId();

  var response = await client.post(Uri.parse('$MEETING_API_URL/joinUser'),
      headers: requestHeaders,
      body: jsonEncode({'meetingId': id,
        'userId': userId,
        'name': name,
        'joined': true,
        'isAlive': true,}));

  if(response.statusCode == 200){
    print("Success");
    return response;
  }else{
    print(response.statusCode);
    return null;
  }
}


Future<http.Response> joinMeeting(String meetingId) async {
  var response = await http.get(Uri.parse('$MEETING_API_URL/join?id=$meetingId'));

  if(response.statusCode>=200 && response.statusCode < 400){
    return response;
  }
  throw UnsupportedError('Not Valid Meeting');

}