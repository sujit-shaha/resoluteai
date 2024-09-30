import 'package:flutter/material.dart';
import 'package:resoluteai/api/meeting_api.dart';
import 'package:resoluteai/models/meeting_details.dart';
import 'package:resoluteai/pages/meeting_page.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
class JoinScreen extends StatefulWidget {
  final MeetingDetails? meetingDetails;

  const JoinScreen({super.key, this.meetingDetails});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String userName = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join Meeting"),
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
            SizedBox(
              height: 20,
            ),
            FormHelper.inputFieldWidget(
                context, "userId", "Enter your Name", (val) {
              if (val.isEmpty) {
                return "Name can`t be Empty";
              }
              return null;
            }, (onsaved) {
              userName = onsaved;
            },
                borderRadius: 15,
                borderFocusColor: Colors.redAccent,
                borderColor: Colors.redAccent,
                hintColor: Colors.grey),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: FormHelper.submitButton(
                    "Join Meeting",
                        () async{
                      if (validateAndSave()) {
                        //Meeting Page
                        await joinUser(widget.meetingDetails!.id!,userName);
                        print(userName);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx)=> MeetingPage(meetingDetails: widget.meetingDetails!,meetingId: widget.meetingDetails!.id,name: userName,),),);
                      }
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




  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}