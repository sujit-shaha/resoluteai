import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
class ControlPanel extends StatelessWidget {

  final bool? videoEnabled;
  final bool? audioEnabled;
  final bool? isConnectionFailed;
  final VoidCallback? onVideoToggle;
  final VoidCallback? onAudioToggle;
  final VoidCallback? onMeetingEnd;
  final VoidCallback? onReconnect;




   ControlPanel({
    this.videoEnabled,
     this.audioEnabled,
     this.isConnectionFailed,
     this.onAudioToggle,
     this.onMeetingEnd,
     this.onReconnect,
     this.onVideoToggle
});


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      color: Colors.blueGrey.shade900,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buildControls(),


      ),
    );
  }
  List<Widget> buildControls(){
    if(!isConnectionFailed!){
      return <Widget>[
        IconButton(onPressed: onVideoToggle, icon: Icon(videoEnabled! ? Icons.videocam : Icons.videocam_off),color: Colors.white,iconSize: 32,),

        IconButton(onPressed: onAudioToggle, icon: Icon(audioEnabled! ? Icons.mic : Icons.mic_off),color: Colors.white,iconSize: 32,),

        const SizedBox(width: 25,),

        Container(
          width: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red
          ),
          child: IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: onMeetingEnd,
            color: Colors.white,
          ),
        )

      ];
    }
    else{
      return <Widget>[
        FormHelper.submitButton(
          "Reconnect",
          onReconnect as Function,
          btnColor: Colors.red,
          borderRadius: 10,
          width: 200,
          height: 40,
        )
      ];
    }
  }
}
