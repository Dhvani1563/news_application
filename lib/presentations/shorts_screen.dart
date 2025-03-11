import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:newsapp/models/post.dart';

class VideoFeedScreen extends StatefulWidget {
  final List<Post>? videoPosts;

  const VideoFeedScreen({super.key, required this.videoPosts});

  @override
  _VideoFeedScreenState createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoPosts == null || widget.videoPosts!.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text(
            "No Shorts Available",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videoPosts!.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return VideoPostWidget(
            video: widget.videoPosts![index],
            isPlaying: index == _currentIndex, // ✅ Auto-play current video
          );
        },
      ),
    );
  }
}

class VideoPostWidget extends StatefulWidget {
  final Post video;
  final bool isPlaying;

  const VideoPostWidget({super.key, required this.video, required this.isPlaying});

  @override
  _VideoPostWidgetState createState() => _VideoPostWidgetState();
}

class _VideoPostWidgetState extends State<VideoPostWidget> {
  late WebViewController _webViewController;
  bool isMuted = false; // ✅ Default: Speaker ON
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    String videoUrl = widget.video.videoUrl
        .replaceAll("youtube.com/shorts/", "youtube.com/embed/")
        .split("?")[0]; // ✅ Convert to embed format

    // ✅ Add autoplay & JS API parameters
    String finalUrl = "$videoUrl?autoplay=1&mute=${isMuted ? 1 : 0}&playsinline=1&controls=0&modestbranding=1&rel=0&enablejsapi=1";

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(Uri.parse(finalUrl))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (String url) {
          // ✅ Inject JavaScript to force autoplay
          _webViewController.runJavaScript("""
            setTimeout(() => {
              document.querySelector('video')?.play();
            }, 500);
          """);
        },
      ));
  }

  @override
  void didUpdateWidget(VideoPostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.video.videoUrl != widget.video.videoUrl) {
      _initializeWebView();
    }

    // ✅ Auto-Play on Scroll
    if (widget.isPlaying) {
      _resumeVideo();
    } else {
      _pauseVideo();
    }
  }

  // ✅ Auto-Pause When Scrolling Away
  void _pauseVideo() {
    _webViewController.runJavaScript("document.querySelector('video')?.pause();");
    setState(() {
      isPaused = true;
    });
  }

  // ✅ Auto-Play When Scrolling to Video
  void _resumeVideo() {
    _webViewController.runJavaScript("document.querySelector('video')?.play();");
    setState(() {
      isPaused = false;
    });
  }

  // ✅ Toggle Mute/Unmute
  void _toggleMute() {
    _webViewController.runJavaScript(
      isMuted
          ? "document.querySelector('video').muted = false;"
          : "document.querySelector('video').muted = true;"
    );
    setState(() {
      isMuted = !isMuted;
    });
  }

  // ✅ Play/Pause Video on Tap
  void _toggleVideo() {
    if (isPaused) {
      _resumeVideo();
    } else {
      _pauseVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleVideo,
      child: Stack(
        children: [
          // ✅ Full-Screen WebView Video
          Positioned.fill(child: WebViewWidget(controller: _webViewController)),

          // ✅ Video Title Overlay
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black54,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),

          // ✅ Side Action Buttons (Like, Share, Mute/Unmute)
          Positioned(
            bottom: 40,
            right: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ✅ Mute/Unmute Button
                IconButton(
                  icon: Icon(
                    isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _toggleMute,
                ),
                const Text("Sound", style: TextStyle(color: Colors.white, fontSize: 14)),

                const SizedBox(height: 10),

                // ✅ Like Button
                IconButton(
                  icon: const Icon(Icons.thumb_up, color: Colors.white, size: 30),
                  onPressed: () {},
                ),

                const SizedBox(height: 10),

                // ✅ Share Button
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 30),
                  onPressed: () {},
                ),
                const Text("Share", style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
