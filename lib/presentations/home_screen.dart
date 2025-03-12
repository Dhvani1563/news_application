import 'package:flutter/material.dart';
import 'package:newsapp/presentations/NewsDetailScreen.dart';
import 'package:newsapp/models/post.dart';
import 'package:newsapp/services/api_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:newsapp/presentations/searchscreen.dart';
import 'package:newsapp/presentations/profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newsapp/presentations/crimescreen..dart';
import 'package:newsapp/presentations/shorts_screen.dart';
import 'package:newsapp/presentations/automationnewsscreen.dart';
import 'package:newsapp/presentations/sportscreen.dart';
import 'package:newsapp/presentations/travelnewsscreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<List<Post>> posts;
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    posts = ApiService().fetchPosts();
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
            _buildHorizontalNewsList(), // Horizontal slider first
            _buildSectionTitle("Latest News"),
            Expanded(child: _buildVerticalNewsList()), // Vertical news list below
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
    {"title": "Shorts", "icon": Icons.play_circle_fill}, // Shorts category
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
        Color categoryColor = Colors.blue.shade800; // Set same color for all categories

        return GestureDetector(
          onTap: () async {
            if (category["title"] == "Shorts") {
              final shortsVideos = await ApiService().fetchYouTubeShorts();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoFeedScreen(videoPosts: shortsVideos),
                ),
              );
            } else {
              setState(() {
                selectedCategory = category["title"]; // Update selected category
              });
              Navigator.push(
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
              border: Border.all(color: categoryColor), // Matching border color
            ),
            child: Row(
              children: [
                Icon(category["icon"], size: 18, color: categoryColor), // Matching icon color
                const SizedBox(width: 6),
                Text(
                  category["title"],
                  style: GoogleFonts.hindVadodara(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: categoryColor, // Matching text color
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


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(title, style: GoogleFonts.hindVadodara(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

 Widget _buildHorizontalNewsList() {
  return FutureBuilder<List<Post>>(
    future: posts,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Text('No posts available');
      } else {
        return SizedBox(
          height: 250, // Reduced height for better layout
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailScreen(post: post),
                    ),
                  );
                },
                child: Container(
                  width: 320, // Ensures images are not cut off
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: post.featuredImageUrl,
                          width: double.infinity,
                          height: 180, // Ensures full image fits
                          fit: BoxFit.cover, // Avoids image cutting
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            post.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.hindVadodara(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    },
  );
}
 Widget _buildVerticalNewsList() {
  return FutureBuilder<List<Post>>(
    future: posts,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(
          child: Text("No news available", style: GoogleFonts.hindVadodara()),
        );
      } else {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final post = snapshot.data![index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailScreen(post: post),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: post.featuredImageUrl,
                        width: 120, // Fixed width for consistency
                        height: 80, // Fixed height
                        fit: BoxFit.cover, // Ensures full image is visible
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.hindVadodara(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Tap to read more...",
                            style: GoogleFonts.hindVadodara(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    },
  );
}


  Widget _buildDrawerItem(String title) {
    return GestureDetector(
      onTap: () {},
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(title, style: GoogleFonts.hindVadodara(fontSize: 18))),
    );
  }
}