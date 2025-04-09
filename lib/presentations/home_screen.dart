import 'package:flutter/material.dart';
import 'package:newsapp/presentations/NewsDetailScreen.dart';
import 'package:newsapp/models/post.dart';
import 'package:newsapp/services/api_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsapp/presentations/searchscreen.dart';
import 'package:newsapp/presentations/profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newsapp/presentations/crimescreen.dart';
import 'package:newsapp/presentations/shorts_screen.dart';
import 'package:newsapp/presentations/automationnewsscreen.dart';
import 'package:newsapp/presentations/sportscreen.dart';
import 'package:newsapp/presentations/travelnewsscreen.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:newsapp/presentations/notification.dart';
import 'package:flutter/rendering.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ScrollController _verticalScrollController;
  late ScrollController _horizontalScrollController;
  int breakingNewsCount = 0;
  String selectedCategory = '';
  double horizontalListHeight = 250;
  bool isScrollingUp = false;

  List<Post> loadedPosts = [];
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _verticalScrollController = ScrollController();
    _horizontalScrollController = ScrollController();

    _fetchBreakingNewsCount();
    _fetchInitialPosts();

    _verticalScrollController.addListener(() {
      if (_verticalScrollController.position.userScrollDirection == ScrollDirection.reverse && !isScrollingUp) {
        setState(() {
          horizontalListHeight = 100;
          isScrollingUp = true;
        });
      } else if (_verticalScrollController.position.userScrollDirection == ScrollDirection.forward && isScrollingUp) {
        setState(() {
          horizontalListHeight = 250;
          isScrollingUp = false;
        });
      }

      if (_verticalScrollController.position.pixels >= _verticalScrollController.position.maxScrollExtent - 100) {
        _loadMorePosts();
      }
    });

    _horizontalScrollController.addListener(() {
      if (_horizontalScrollController.position.pixels >= _horizontalScrollController.position.maxScrollExtent - 100) {
        _loadMoreBreakingNews();
      }
    });
  }

  Future<void> _fetchInitialPosts() async {
    final initialPosts = await ApiService().fetchPosts();
    setState(() {
      loadedPosts = initialPosts;
    });
  }

  Future<void> _fetchBreakingNewsCount() async {
    List<Post> breakingNews = await ApiService().fetchBreakingNews();
    setState(() {
      breakingNewsCount = breakingNews.length;
    });
  }

  Future<void> _loadMorePosts() async {
    if (isLoadingMore) return;
    isLoadingMore = true;

    List<Post> morePosts = await ApiService().fetchPosts(); // Add pagination later if needed
    setState(() {
      loadedPosts.addAll(morePosts);
    });

    isLoadingMore = false;
  }

  Future<void> _loadMoreBreakingNews() async {
    List<Post> moreBreakingNews = await ApiService().fetchBreakingNews();
    setState(() {
      loadedPosts.addAll(moreBreakingNews);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildCategoriesList(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: horizontalListHeight,
              child: _buildHorizontalNewsList(),
            ),
            _buildSectionTitle("Latest News"),
            Expanded(child: _buildVerticalNewsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Image.asset('lib/assets/Hamburger.png', width: 24, height: 24),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
                },
                child: Image.asset('lib/assets/Search.png', width: 24, height: 24),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen()));
                  _fetchBreakingNewsCount();
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset('lib/assets/Notification.png', width: 24, height: 24),
                    if (breakingNewsCount > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Text(
                            '$breakingNewsCount',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyProfile()));
                },
                child: const CircleAvatar(radius: 15, backgroundColor: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 28),
              ),
              const SizedBox(height: 32),
              Text("Home", style: GoogleFonts.hindVadodara(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              _buildDrawerItem("Categories"),
              _buildDrawerItem("Bookmark"),
              _buildDrawerItem("About"),
              _buildDrawerItem("Our Apps"),
              _buildDrawerItem("Privacy"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList() {
    final List<Map<String, dynamic>> categories = [
      {"title": "Sports", "icon": Icons.sports_soccer, "screen": SportsNewsScreen()},
      {"title": "Crime", "icon": Icons.gavel, "screen": CrimeNewsScreen()},
      {"title": "Tech", "icon": Icons.memory, "screen": AutomationNewsScreen()},
      {"title": "Travel", "icon": Icons.flight, "screen": TravelNewsScreen()},
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
                setState(() => selectedCategory = category["title"]);
                Navigator.push(context, MaterialPageRoute(builder: (context) => category["screen"]));
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
                    style: GoogleFonts.hindVadodara(fontSize: 14, fontWeight: FontWeight.w600, color: categoryColor),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalNewsList() {
    return ListView.builder(
      controller: _horizontalScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: loadedPosts.length,
      itemBuilder: (context, index) => _buildHorizontalPostItem(loadedPosts[index]),
    );
  }

  Widget _buildVerticalNewsList() {
    return RefreshIndicator(
      onRefresh: _fetchInitialPosts,
      child: ListView.builder(
        controller: _verticalScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: loadedPosts.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == loadedPosts.length && isLoadingMore) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ));
          }
          return _buildVerticalPostItem(loadedPosts[index]);
        },
      ),
    );
  }

  Widget _buildHorizontalPostItem(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailScreen(post: post)));
      },
      child: Container(
        width: 320,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              child: CachedNetworkImage(imageUrl: post.featuredImageUrl, width: double.infinity, height: 180, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                HtmlUnescape().convert(post.title),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.hindVadodara(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalPostItem(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => NewsDetailScreen(post: post)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(imageUrl: post.featuredImageUrl, width: 120, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    HtmlUnescape().convert(post.title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hindVadodara(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text("Tap to read more...", style: GoogleFonts.hindVadodara(fontSize: 14, color: Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(title, style: GoogleFonts.hindVadodara(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDrawerItem(String title) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(title, style: GoogleFonts.hindVadodara(fontSize: 18)),
      ),
    );
  }
}
