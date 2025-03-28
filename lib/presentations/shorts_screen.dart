import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:newsapp/models/post.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            isPlaying: index == _currentIndex,
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
  WebViewController? _webViewController;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid || Platform.isIOS) {
      String videoUrl = "${widget.video.videoUrl.replaceAll(
          "youtube.com/shorts/", "youtube.com/embed/")}?autoplay=1&mute=1&playsinline=1&enablejsapi=1";

      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..loadRequest(Uri.parse(videoUrl));

      _enableSoundOnPlay();
    }
  }

  void _enableSoundOnPlay() {
    _webViewController?.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (_) {
          _webViewController?.runJavaScript("""
            setTimeout(() => {
              var video = document.querySelector('video');
              if (video) {
                video.muted = true;
                video.play();
                setTimeout(() => {
                  video.muted = false;
                }, 500);
              }
            }, 500);
          """);
        },
      ),
    );
  }

  @override
  void didUpdateWidget(covariant VideoPostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      _resumeVideo();
    } else {
      _pauseVideo();
    }
  }

  void _pauseVideo() {
    _webViewController?.runJavaScript("document.querySelector('video')?.pause();");
    setState(() {
      isPaused = true;
    });
  }

  void _resumeVideo() {
    _webViewController?.runJavaScript("document.querySelector('video')?.play();");
    setState(() {
      isPaused = false;
    });
  }

  void _shareShorts() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 120,
          child: Column(
            children: [
              const Text("Share via", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ✅ WhatsApp Share
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 30),
                    onPressed: () async {
                      String message = "Check out this Shorts: ${widget.video.videoUrl}";
                      String whatsappUrl = "https://wa.me/?text=${Uri.encodeComponent(message)}";
                      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                        await launchUrl(Uri.parse(whatsappUrl));
                      } else {
                        throw 'Could not launch WhatsApp';
                      }
                    },
                  ),

                  // ✅ Facebook Share
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue, size: 30),
                    onPressed: () async {
                      String message = "Check out this Shorts: ${widget.video.videoUrl}";
                      String facebookUrl = "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(widget.video.videoUrl)}";
                      if (await canLaunchUrl(Uri.parse(facebookUrl))) {
                        await launchUrl(Uri.parse(facebookUrl));
                      } else {
                        throw 'Could not launch Facebook';
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text(
            "WebView is not supported on Windows/macOS/Linux",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (isPaused) {
          _resumeVideo();
        } else {
          _pauseVideo();
        }
      },
      child: Stack(
        children: [
          if (Platform.isAndroid || Platform.isIOS)
            WebViewWidget(controller: _webViewController!),

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

          Positioned(
            bottom: 40,
            right: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up, color: Colors.white, size: 30),
                  onPressed: () {},
                ),
                const SizedBox(height: 10),

                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 30),
                  onPressed: _shareShorts,
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
