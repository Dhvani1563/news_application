import 'package:flutter/material.dart';
import 'package:newsapp/models/post.dart';
import 'package:newsapp/services/api_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:newsapp/presentations/NewsDetailScreen.dart';
import 'package:newsapp/presentations/crimescreen..dart';
import 'package:newsapp/presentations/searchscreen.dart';
import 'package:newsapp/presentations/profile.dart';
import 'package:newsapp/presentations/automationnewsscreen.dart';
import 'package:newsapp/presentations/travelnewsscreen.dart';
import 'package:newsapp/presentations/home_screen.dart';
import 'package:newsapp/presentations/shorts_screen.dart';

class SportsNewsScreen extends StatefulWidget {
  const SportsNewsScreen({super.key});

  @override
  State<SportsNewsScreen> createState() => _SportsNewsScreenState();
}

class _SportsNewsScreenState extends State<SportsNewsScreen> {
  Future<List<Post>>? sportsPosts;
  final HtmlUnescape unescape = HtmlUnescape();
  String selectedCategory = "Sports";

  @override
  void initState() {
    super.initState();
    sportsPosts = ApiService().fetchSportsNews();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildCategoriesList(),
              _buildSectionTitle("Latest Sports News"),
              Expanded(child: _buildVerticalNewsList()),
            ],
          ),
        ),
      ),
    );
  }

  /// ✅ **App Bar**
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
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

  /// ✅ **Categories List**
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
                  MaterialPageRoute(
                    builder: (context) => VideoFeedScreen(videoPosts: shortsVideos),
                  ),
                );
              } else {
                setState(() {
                  selectedCategory = category["title"];
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

  /// ✅ **Section Title**
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

  /// ✅ **Vertical News List**
  Widget _buildVerticalNewsList() {
    return FutureBuilder<List<Post>>(
      future: sportsPosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('⚠️ No sports news available!'));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data![index];
              return _buildNewsCard(post);
            },
          );
        }
      },
    );
  }

 /// ✅ **News Card UI with Darker Grey Text Background & Rounded Bottom**
Widget _buildNewsCard(Post post) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewsDetailScreen(post: post)),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          /// ✅ Image Section
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: post.featuredImageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),

          /// ✅ Text Section with Dark Grey Background & Rounded Bottom
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[400], // ✅ Darker grey background for text
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)), // ✅ Rounded bottom
            ),
            child: Text(
              unescape.convert(post.title),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.hindVadodara(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // ✅ Slightly darker text for better contrast
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}