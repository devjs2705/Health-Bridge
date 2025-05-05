import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final int uid; // Local user's UID

  const VideoCallScreen({
    Key? key,
    required this.channelName,
    required this.uid,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  static const String appId = '883757eb83784611881c384e5dbae807'; // 🛑 Replace with your real App ID
  static const String token = ''; // 🛑 Provide your token if required
  late final RtcEngine _engine;
  int? remoteUid;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.camera, Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: appId));

    await _engine.enableVideo();
    await _engine.startPreview();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('✅ Local user ${connection.localUid} joined channel ${connection.channelId}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('👥 Remote user $remoteUid joined');
          setState(() {
            this.remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          print('🚪 Remote user $remoteUid left');
          setState(() {
            this.remoteUid = null;
          });
          Navigator.of(context).pop(); // Go back to appointments page if remote user leaves
        },
        onError: (ErrorCodeType code, String msg) {
          print("❌ Agora error: $code - $msg");
        },
      ),
    );

    await _engine.joinChannel(
      token: token,
      channelId: widget.channelName,
      uid: widget.uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Widget _renderRemoteVideo() {
    if (remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Waiting for remote user to join...',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
  }

  Widget _renderLocalPreview() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  void _flipCamera() {
    _engine.switchCamera();
  }

  void _hangUp() async {
    await _engine.leaveChannel();
    Navigator.of(context).pop(); // Go back to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isInitialized
            ? Stack(
          children: [
            _renderRemoteVideo(),
            Positioned(
              top: 16,
              left: 16,
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _renderLocalPreview(),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 40,
              child: FloatingActionButton(
                heroTag: 'flip',
                onPressed: _flipCamera,
                child: const Icon(Icons.flip_camera_ios),
              ),
            ),
            Positioned(
              bottom: 40,
              right: 40,
              child: FloatingActionButton(
                heroTag: 'hangup',
                backgroundColor: Colors.red,
                onPressed: _hangUp,
                child: const Icon(Icons.call_end),
              ),
            ),
          ],
        )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
