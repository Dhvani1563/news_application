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
import 'package:newsapp/presentations/home_screen.dart'; // Import HomeScreen
import 'package:newsapp/presentations/shorts_screen.dart';

class CrimeNewsScreen extends StatefulWidget {
  const CrimeNewsScreen({super.key});

  @override
  State<CrimeNewsScreen> createState() => _CrimeNewsScreenState();
}

class _CrimeNewsScreenState extends State<CrimeNewsScreen> {
  Future<List<Post>>? crimePosts;
  final HtmlUnescape unescape = HtmlUnescape();
  String selectedCategory = "Crime"; // ✅ Default selected

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
            _buildCategoriesList(), // ✅ Icons under AppBar
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
                MaterialPageRoute(builder: (context) => const MainScreen()), // ✅ Navigate to Home Screen
                (route) => false, // Clear all previous routes
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
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildCategoryItem("Sports", Icons.sports_soccer),
          _buildCategoryItem("Crime", Icons.gavel),
          _buildCategoryItem("Travel", Icons.flight),
          _buildCategoryItem("Tech & Auto", Icons.directions_car),
          _buildCategoryItem("Shorts", Icons.play_arrow),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String title, IconData icon) {
  bool isSelected = selectedCategory == title;
  return GestureDetector(
    onTap: () {
      if (title == "Sports") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SportsNewsScreen()));
      } else if (title == "Crime") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CrimeNewsScreen()));
      } else if (title == "Tech & Auto") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AutomationNewsScreen()));
      } else if (title == "Travel") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const TravelNewsScreen()));
      } else if (title == "Shorts") {
        ApiService apiService = ApiService();
        apiService.fetchYouTubeShorts().then((videos) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoFeedScreen(videoPosts: videos),
            ),
          );
        }).catchError((error) {
          print("❌ Error fetching videos: $error");
        });
      } else {
        setState(() {
          selectedCategory = isSelected ? '' : title;
          crimePosts = ApiService().fetchPosts(category: title); // ✅ Fixed Error
        });
      }
    },
    child: Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? Colors.blue : Colors.grey),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.hindVadodara(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 100,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          image: DecorationImage(
                            image: CachedNetworkImageProvider(post.featuredImageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: const Center(child: CircularProgressIndicator()), // Placeholder while loading
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              unescape.convert(post.title),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.hindVadodara(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              post.date,
                              style: GoogleFonts.hindVadodara(fontSize: 12, color: Colors.grey),
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
}
