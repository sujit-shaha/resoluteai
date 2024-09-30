import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';
import 'package:resoluteai/models/meeting_details.dart';
import 'package:resoluteai/pages/home_screen.dart';
import 'package:resoluteai/utils/user.utils.dart';
import 'package:resoluteai/widgets/control_panel.dart';
import 'package:resoluteai/widgets/remote_connection.dart';

class MeetingPage extends StatefulWidget {
  final String? meetingId;
  final String? name;
  final MeetingDetails meetingDetails;

  const MeetingPage(
      {super.key, this.meetingId, this.name, required this.meetingDetails});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final _localRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints = {"audio": true, "video": true};
  bool isConnectionFailed = false;
  bool isMeetingHelperInitialized = false; // Flag for meetingHelper initialization

  WebRTCMeetingHelper? meetingHelper;

  @override
  Widget build(BuildContext context) {
    // Check if meetingHelper is initialized, otherwise show a loading indicator
    if (!isMeetingHelperInitialized) {
      return _buildLoadingView();
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      body: _buildMeetRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: CircularProgressIndicator(), // Show a loading spinner while initializing
      ),
    );
  }

  void startMeeting() async {
    try {
      final String userId = await loadUserId();
      print("inside startMeeting");

      // Initialize the meeting helper
      meetingHelper = WebRTCMeetingHelper(
        url: "http://192.168.96.48:4000/api/meeting/get", // Ensure this URL is correct
        meetingId: widget.meetingDetails.id,
        userId: userId,
        name: widget.name,
      );

      // Get local media stream
      MediaStream _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;
      meetingHelper!.stream = _localStream;

      // Setup listeners for WebRTC events
      _setupMeetingHelperListeners();

      // Set the flag indicating the meetingHelper is ready
      setState(() {
        isMeetingHelperInitialized = true;
      });
    } catch (e) {
      // Log and handle errors if meetingHelper fails to initialize
      print("Error initializing meetingHelper: $e");
      setState(() {
        isConnectionFailed = true; // Flag that the connection failed
      });
    }
  }

  void _setupMeetingHelperListeners() {
    if (meetingHelper == null) {
      print("meetingHelper is null, cannot setup listeners");
      return;
    }

    meetingHelper!.on("open", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("user-left", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("video-toggle", context, (ev, context) {
      setState(() {});
    });

    meetingHelper!.on("audio-toggle", context, (ev, context) {
      setState(() {});
    });

    meetingHelper!.on("meeting-ended", context, (ev, context) {
      onMeetingEnd();
    });

    meetingHelper!.on("connection-setting-changed", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("stream-changed", context, (ev, context) {
      setState(() {
        isConnectionFailed = false;
      });
    });

    meetingHelper!.on("connection", context, (ev, context) {
      print("WebSocket connection established.");
      setState(() {
        isConnectionFailed = false;
      });
    });
  }

  _buildMeetRoom() {
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isNotEmpty
            ? GridView.count(
          crossAxisCount: meetingHelper!.connections.length < 3 ? 1 : 2,
          children: List.generate(meetingHelper!.connections.length, (index) {
            return Padding(
              padding: EdgeInsets.all(1),
              child: RemoteConnection(
                renderer: meetingHelper!.connections[index].renderer,
                connection: meetingHelper!.connections[index],
              ),
            );
          }),
        )
            : Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Waiting for Participants to join the meeting",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 32),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 0,
          child: SizedBox(
            width: 150,
            height: 200,
            child: RTCVideoView(_localRenderer),
          ),
        ),
      ],
    );
  }

  initRenderer() async {
    await _localRenderer.initialize();
  }

  @override
  void initState() {
    super.initState();
    initRenderer();
    startMeeting();
  }

  @override
  void deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
  }

  void onMeetingEnd() {
    if (meetingHelper != null) {
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHomePage();
    }
  }

  void handleReconnect() {
    if (meetingHelper != null) {
      meetingHelper!.reconnect();
    } else {
      print("meetingHelper is null, cannot reconnect");
    }
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleAudio();
      });
    } else {
      print("meetingHelper is null, cannot toggle audio");
    }
  }

  bool isVideoEnabled() {
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
  }

  void onVideoToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideo();
      });
    } else {
      print("meetingHelper is null, cannot toggle video");
    }
  }

  bool isAudioEnabled() {
    return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
  }

  void goToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (ctx) => HomeScreen(),
      ),
    );
  }
}
