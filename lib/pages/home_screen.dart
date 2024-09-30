import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:resoluteai/api/meeting_api.dart';
import 'package:resoluteai/models/meeting_details.dart';
import 'package:resoluteai/pages/join_screen.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:http/http.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String meeetingId = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meeting App"),
        backgroundColor: Colors.redAccent,
      ),
      body: Form(
        key: globalKey,
        child: formUI(),
      ),
    );
  }

  formUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "welcome to WebRTC Meeting App",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            FormHelper.inputFieldWidget(
                context, "meetingId", "Enter your Meeting Id", (val) {
              if (val.isEmpty) {
                return "Meeting id can`t be Empty";
              }
              return null;
            }, (onsaved) {
              meeetingId = onsaved;
            },
                borderRadius: 15,
                borderFocusColor: Colors.redAccent,
                borderColor: Colors.redAccent,
                hintColor: Colors.grey),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: FormHelper.submitButton(
                    "Join Meeting",
                    () {
                      if (validateAndSave()) {
                        validateMeeting(meeetingId);
                      }
                    },
                  ),
                ),
                Flexible(
                  child: FormHelper.submitButton(
                    "Start Meeting",
                    () async {
                      var response = await startMeeting();
                      final body = json.decode(response!.body);

                      final meetId = body['data'];
                      validateMeeting(meetId);
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void validateMeeting(String meetingId) async {
    try {
      Response response = await joinMeeting(meetingId);
      var data = json.decode(response.body);
      final meetingDetails = MeetingDetails.fromJson(data["data"]);
      goToJoinScreen(meetingDetails);
    } catch (err) {
      FormHelper.showSimpleAlertDialog(
          context, "Meeting App", "Invalid Meeting Id", "OK", () {
        Navigator.of(context).pop();
      });
    }
  }

  goToJoinScreen(MeetingDetails meetingDetails) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => JoinScreen(
          meetingDetails: meetingDetails,
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}
