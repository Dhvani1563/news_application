import 'package:flutter/material.dart';
import 'package:newsapp/models/post.dart';
import 'package:newsapp/services/api_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:newsapp/presentations/NewsDetailScreen.dart';
import 'package:newsapp/presentations/searchscreen.dart';
import 'package:newsapp/presentations/profile.dart';
import 'package:newsapp/presentations/sportscreen.dart';
import 'package:newsapp/presentations/automationnewsscreen.dart';
import 'package:newsapp/presentations/travelnewsscreen.dart';
import 'package:newsapp/presentations/home_screen.dart';
import 'package:newsapp/presentations/shorts_screen.dart';

class CrimeNewsScreen extends StatefulWidget {
  const CrimeNewsScreen({super.key});

  @override
  State<CrimeNewsScreen> createState() => _CrimeNewsScreenState();
}

class _CrimeNewsScreenState extends State<CrimeNewsScreen> {
  Future<List<Post>>? crimePosts;
  final HtmlUnescape unescape = HtmlUnescape();
  String selectedCategory = "Crime"; 

  @override
  void initState() {
    super.initState();
    crimePosts = ApiService().fetchCrimeNews();
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
            _buildSectionTitle("Latest Crime News"),
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
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false,
              );
            },
            child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
          ),
          Text(
            "Crime News",
            style: GoogleFonts.hindVadodara(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
                },
                child: const Icon(Icons.search, size: 24, color: Colors.black),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        title,
        style: GoogleFonts.hindVadodara(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red.shade900),
      ),
    );
  }

  Widget _buildVerticalNewsList() {
    return FutureBuilder<List<Post>>(
      future: crimePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('⚠️ No crime news available!'));
        } else {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsDetailScreen(post: post)),
                  );
                },
                child: _buildNewsCard(post),
              );
            },
          );
        }
      },
    );
  }

 Widget _buildNewsCard(Post post) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ✅ News Image with Rounded Top
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: CachedNetworkImage(
              imageUrl: post.featuredImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _imagePlaceholder(),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 40, color: Colors.red),
            ),
          ),
        ),

        /// ✅ Title Section with Grey Background & Rounded Bottom
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[300], // ✅ Grey background
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
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
      ],
    ),
  );
}

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
