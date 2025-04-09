import 'package:flutter/material.dart';
import 'package:newsapp/models/post.dart';
import 'package:newsapp/services/api_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:newsapp/presentations/NewsDetailScreen.dart';
import 'package:newsapp/presentations/searchscreen.dart';
import 'package:newsapp/presentations/profile.dart';
import 'package:newsapp/presentations/home_screen.dart';
import 'package:newsapp/presentations/crimescreen.dart';
import 'package:newsapp/presentations/sportscreen.dart';
import 'package:newsapp/presentations/travelnewsscreen.dart';
import 'package:newsapp/presentations/shorts_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AutomationNewsScreen extends StatefulWidget {
  const AutomationNewsScreen({super.key});

  @override
  State<AutomationNewsScreen> createState() => _AutomationNewsScreenState();
}

class _AutomationNewsScreenState extends State<AutomationNewsScreen> {
  List<Post> automationPosts = [];
  final HtmlUnescape unescape = HtmlUnescape();
  int page = 1;
  bool isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  String selectedCategory = "Tech";

  @override
  void initState() {
    super.initState();
    _fetchAutomationNews();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchAutomationNews() async {
    List<Post> newPosts = await ApiService(). fetchTechAutoNews(page: page);
    setState(() {
      automationPosts.addAll(newPosts);
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !isLoadingMore) {
      _loadMoreNews();
    }
  }

  Future<void> _loadMoreNews() async {
    setState(() {
      isLoadingMore = true;
    });

    page++;
    List<Post> morePosts = await ApiService(). fetchTechAutoNews(page: page);

    setState(() {
      automationPosts.addAll(morePosts);
      isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildCategoriesList(),
            _buildSectionTitle("Latest Tech News"),
            Expanded(child: _buildVerticalNewsList()),
          ],
        ),
      ),
    );
  }

  /// ✅ App Bar
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
            },
            child: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
                },
                child: const Icon(Icons.search, size: 26, color: Colors.black),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyProfile()));
                },
                child: const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Categories Bar
  Widget _buildCategoriesList() {
    final List<Map<String, dynamic>> categories = [
      {"title": "Sports", "icon": Icons.sports_soccer, "screen": const SportsNewsScreen()},
      {"title": "Crime", "icon": Icons.gavel, "screen": const CrimeNewsScreen()},
      {"title": "Tech", "icon": Icons.memory, "screen": const AutomationNewsScreen()},
      {"title": "Travel", "icon": Icons.flight, "screen": const TravelNewsScreen()},
      {"title": "Shorts", "icon": Icons.play_circle_fill},
    ];

    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          bool isSelected = selectedCategory == category["title"];
          Color categoryColor = Colors.blue.shade800;

          return GestureDetector(
            onTap: () async {
              if (category["title"] == "Shorts") {
                final shortsVideos = await ApiService().fetchYouTubeShorts();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VideoFeedScreen(videoPosts: shortsVideos)),
                );
              } else {
                setState(() {
                  selectedCategory = category["title"];
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => category["screen"]),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? categoryColor.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: categoryColor),
              ),
              child: Row(
                children: [
                  Icon(category["icon"], size: 18, color: categoryColor),
                  const SizedBox(width: 6),
                  Text(
                    category["title"],
                    style: GoogleFonts.hindVadodara(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: categoryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ✅ Section Title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: GoogleFonts.hindVadodara(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade900, Colors.blue.shade300],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ News List
  Widget _buildVerticalNewsList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: automationPosts.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == automationPosts.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildNewsCard(automationPosts[index]);
      },
    );
  }

  /// ✅ News Card with Share Buttons
  Widget _buildNewsCard(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailScreen(post: post)));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: post.featuredImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _imagePlaceholder(),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 40, color: Colors.red),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      unescape.convert(post.title),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.hindVadodara(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                    onPressed: () => _shareToWhatsApp(post),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                    onPressed: () => _shareToFacebook(post),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.lightBlue),
                    onPressed: () => _shareToTwitter(post),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.telegram, color: Colors.blueAccent),
                    onPressed: () => _shareToTelegram(post),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Social Sharing Methods
  void _shareToWhatsApp(Post post) async {
    final url = "https://wa.me/?text=${Uri.encodeComponent("${post.title}\n${post.link}")}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _shareToFacebook(Post post) async {
    final url = "https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(post.link)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _shareToTwitter(Post post) async {
    final url = "https://twitter.com/intent/tweet?text=${Uri.encodeComponent("${post.title}\n${post.link}")}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _shareToTelegram(Post post) async {
    final url = "https://t.me/share/url?url=${Uri.encodeComponent(post.link)}&text=${Uri.encodeComponent(post.title)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Widget _imagePlaceholder() => Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator()));
}
