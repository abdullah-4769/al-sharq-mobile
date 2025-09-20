/*import 'package:flutter/material.dart';

class OKRNavigatorHome extends StatefulWidget {
  @override
  _OKRNavigatorHomeState createState() => _OKRNavigatorHomeState();
}

class _OKRNavigatorHomeState extends State<OKRNavigatorHome>
    with TickerProviderStateMixin {
  int selectedCard = 1;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void selectCard(int index) {
    if (selectedCard != index) {
      setState(() {
        selectedCard = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "OKR'",
                    style: TextStyle(
                      color: Color(0xFFE44D26),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "Nav",
                    style: TextStyle(
                      color: Color(0xFFE44D26),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Text(
              "Navigator",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    buildCard(
                      index: 0,
                      title: "Start",
                      subtitle: "Game",
                      description:
                      "Jump into action! Play solo at your own pace or team up for a collaborative strategy challenge.",
                      buttonText: "Tap to Start",
                      color: Color(0xFFF28C82),
                      isSelected: selectedCard == 0,
                      position: getPosition(0),
                    ),
                    buildCard(
                      index: 1,
                      title: "Join",
                      subtitle: "a Challenge",
                      description:
                      "Accept an invite or launch a duel. Compete with friends or colleagues to sharpen your OKR skills.",
                      buttonText: "Tap to Join",
                      color: Color(0xFF92D2A7),
                      isSelected: selectedCard == 1,
                      position: getPosition(1),
                    ),
                    buildCard(
                      index: 2,
                      title: "Check",
                      subtitle: "Scoreboard",
                      description:
                      "Track your performance, see where you rank, and celebrate your milestones with badges and trophies.",
                      buttonText: "Tap to Check",
                      color: Color(0xFF6B8EC2),
                      isSelected: selectedCard == 2,
                      position: getPosition(2),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Function to calculate dynamic position
  int getPosition(int index) {
    if (index == selectedCard) return 0; // middle
    if ((selectedCard + 1) % 3 == index) return 1; // neeche
    return -1; // upar
  }


  Widget buildCard({
    required int index,
    required String title,
    required String subtitle,
    required String description,
    required String buttonText,
    required Color color,
    required bool isSelected,
    required int position,
  }) {
    double baseHeight = isSelected ? 220.0 : 180.0;
    double topOffset = MediaQuery.of(context).size.height / 4 - (position * 100.0);
    double angle = isSelected ? 0.0 : (position == 1 ? 0.05 : -0.05); // Slight curve effect

    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: topOffset,
      left: 66.0,
      child: Transform.rotate(
        angle: angle,
        child: GestureDetector(
          onTap: () => selectCard(index),
          child: Container(
            height: baseHeight,
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "\n$subtitle",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: isSelected ? 4 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}*/
import 'package:apivideo_live_stream/apivideo_live_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// Placeholder for constants.dart
class Constants {
  static const List<String> choices = <String>['Settings'];
}

// Custom color scheme
MaterialColor apiVideoOrange = const MaterialColor(0xFFFA5B30, const {
  50: const Color(0xFFFBDDD4),
  100: const Color(0xFFFFD6CB),
  200: const Color(0xFFFFD1C5),
  300: const Color(0xFFFFB39E),
  400: const Color(0xFFFA5B30),
  500: const Color(0xFFF8572A),
  600: const Color(0xFFF64819),
  700: const Color(0xFFEE4316),
  800: const Color(0xFFEC3809),
  900: const Color(0xFFE53101),
});

// Placeholder for types/params.dart
class Params {
  String streamKey = "your-stream-key"; // Replace with actual stream key
  String rtmpUrl = "rtmp://your-rtmp-url"; // Replace with actual RTMP URL
  VideoConfig video = VideoConfig(bitrate: 1); // Default video config
  AudioConfig audio = AudioConfig(); // Default audio config
}

// Placeholder for settings_screen.dart
class SettingsScreen extends StatefulWidget {
  final Params params;
  const SettingsScreen({required this.params});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Params _params;

  @override
  void initState() {
    _params = widget.params;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Column(
        children: [
          TextField(
            onChanged: (value) => _params.streamKey = value,
            decoration: InputDecoration(labelText: 'Stream Key'),
          ),
          TextField(
            onChanged: (value) => _params.rtmpUrl = value,
            decoration: InputDecoration(labelText: 'RTMP URL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _params),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}

class LiveViewPage extends StatefulWidget {
  const LiveViewPage({Key? key}) : super(key: key);

  @override
  _LiveViewPageState createState() => _LiveViewPageState();
}

class _LiveViewPageState extends State<LiveViewPage>
    with WidgetsBindingObserver {
  final ButtonStyle buttonStyle =
  ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  Params config = Params();
  late final ApiVideoLiveStreamController _controller;
  bool _isStreaming = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    _controller = createLiveStreamController();

    _controller.initialize().catchError((e) {
      showInSnackBar(e.toString());
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.startPreview();
    }
  }

  ApiVideoLiveStreamController createLiveStreamController() {
    return ApiVideoLiveStreamController(
      initialAudioConfig: config.audio,
      initialVideoConfig: config.video,
      onConnectionSuccess: () {
        print('Connection succeeded');
      },
      onConnectionFailed: (error) {
        print('Connection failed: $error');
        _showDialog(context, 'Connection failed', '$error');
        if (mounted) {
          setIsStreaming(false);
        }
      },
      onDisconnection: () {
        showInSnackBar('Disconnected');
        if (mounted) {
          setIsStreaming(false);
        }
      },
      onError: (error) {
        _showDialog(context, 'Error', '$error');
        if (mounted) {
          setIsStreaming(false);
        }
      },
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Live Stream Example'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (choice) => _onMenuSelected(choice, context),
            itemBuilder: (BuildContext context) {
              return Constants.choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Center(
                      child: ApiVideoCameraPreview(controller: _controller),
                    ),
                  ),
                ),
              ),
              _controlRowWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _onMenuSelected(String choice, BuildContext context) {
    if (choice == "Settings") { // Changed from Constants.Settings to "Settings"
      _awaitResultFromSettingsFinal(context);
    }
  }

  void _awaitResultFromSettingsFinal(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(params: config),
      ),
    );
    if (result != null) {
      setState(() {
        config = result;
        _controller.setVideoConfig(config.video);
        _controller.setAudioConfig(config.audio);
      });
    }
  }

  Widget _controlRowWidget() {
    final ApiVideoLiveStreamController? liveStreamController = _controller;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.cameraswitch),
          color: apiVideoOrange,
          onPressed: liveStreamController != null
              ? onSwitchCameraButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.mic_off),
          color: apiVideoOrange,
          onPressed: liveStreamController != null
              ? onToggleMicrophoneButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.fiber_manual_record),
          color: Colors.red,
          onPressed: liveStreamController != null && !_isStreaming
              ? onStartStreamingButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          onPressed: liveStreamController != null && _isStreaming
              ? onStopStreamingButtonPressed
              : null,
        ),
      ],
    );
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> switchCamera() async {
    final ApiVideoLiveStreamController? liveStreamController = _controller;

    if (liveStreamController == null) {
      showInSnackBar('Error: create a camera controller first.');
      return;
    }

    return await liveStreamController.switchCamera();
  }

  Future<void> toggleMicrophone() async {
    final ApiVideoLiveStreamController? liveStreamController = _controller;

    if (liveStreamController == null) {
      showInSnackBar('Error: create a camera controller first.');
      return;
    }

    return await liveStreamController.toggleMute();
  }

  Future<void> startStreaming() async {
    final ApiVideoLiveStreamController? controller = _controller;

    if (controller == null) {
      print('Error: create a camera controller first.');
      return;
    }

    return await controller.startStreaming(
      streamKey: config.streamKey,
      url: config.rtmpUrl,
    );
  }

  Future<void> stopStreaming() async {
    final ApiVideoLiveStreamController? controller = _controller;

    if (controller == null) {
      print('Error: create a camera controller first.');
      return;
    }

    return await controller.stopStreaming();
  }

  void onSwitchCameraButtonPressed() {
    switchCamera().then((_) {
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      if (error is PlatformException) {
        _showDialog(
          context,
          "Error",
          "Failed to switch camera: ${error.message}",
        );
      } else {
        _showDialog(context, "Error", "Failed to switch camera: $error");
      }
    });
  }

  void onToggleMicrophoneButtonPressed() {
    toggleMicrophone().then((_) {
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
      if (error is PlatformException) {
        _showDialog(
          context,
          "Error",
          "Failed to toggle mute: ${error.message}",
        );
      } else {
        _showDialog(context, "Error", "Failed to toggle mute: $error");
      }
    });
  }

  void onStartStreamingButtonPressed() {
    startStreaming().then((_) {
      if (mounted) {
        setIsStreaming(true);
      }
    }).catchError((error) {
      if (error is PlatformException) {
        _showDialog(
          context,
          "Error",
          "Failed to start stream: ${error.message}",
        );
      } else {
        _showDialog(context, "Error", "Failed to start stream: $error");
      }
    });
  }

  void onStopStreamingButtonPressed() {
    stopStreaming().then((_) {
      if (mounted) {
        setIsStreaming(false);
      }
    }).catchError((error) {
      if (error is PlatformException) {
        _showDialog(
          context,
          "Error",
          "Failed to stop stream: ${error.message}",
        );
      } else {
        _showDialog(context, "Error", "Failed to stop stream: $error");
      }
    });
  }

  void setIsStreaming(bool isStreaming) {
    setState(() {
      if (isStreaming) {
        WakelockPlus.enable();
      } else {
        WakelockPlus.disable();
      }
      _isStreaming = isStreaming;
    });
  }
}

Future<void> _showDialog(
    BuildContext context,
    String title,
    String description,
    ) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(description),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Dismiss'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LiveViewPage(),
      theme: ThemeData(
        primarySwatch: apiVideoOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}