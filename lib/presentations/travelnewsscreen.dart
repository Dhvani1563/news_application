import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newsapp/models/post.dart';
import 'package:newsapp/presentations/home_screen.dart';
import 'package:newsapp/services/api_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:newsapp/presentations/NewsDetailScreen.dart';
import 'package:newsapp/presentations/searchscreen.dart';
import 'package:newsapp/presentations/profile.dart';
import 'package:newsapp/presentations/sportscreen.dart';
import 'package:newsapp/presentations/automationnewsscreen.dart';
import 'package:newsapp/presentations/crimescreen.dart';
import 'package:newsapp/presentations/shorts_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TravelNewsScreen extends StatefulWidget {
  const TravelNewsScreen({super.key});

  @override
  State<TravelNewsScreen> createState() => _TravelNewsScreenState();
}

class _TravelNewsScreenState extends State<TravelNewsScreen> {
  final HtmlUnescape unescape = HtmlUnescape();
  final ScrollController _scrollController = ScrollController();

  List<Post> travelPosts = [];
  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  String selectedCategory = "Travel";

  String selectedCity = "";
  String selectedDate = "";

  final List<String> cities = [
    "Ahmedabad",
    "Surat",
    "Vadodara",
    "Rajkot",
    "Bhavnagar",
    "Gandhinagar",
    "Jamnagar",
    "Junagadh",
    "Nadiad",
    "Morbi",
    "Bharuch",
    "Mehsana",
    "Anand",
    "Navsari",
    "Valsad",
    "Porbandar",
    "Godhra",
    "Palanpur",
    "Veraval",
    "Dahod",
  ];

  @override
  void initState() {
    super.initState();
    _fetchTravelPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
          !isLoading &&
          hasMore) {
        _fetchTravelPosts();
      }
    });
  }

  Future<void> _fetchTravelPosts({bool reset = false}) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    if (reset) {
      setState(() {
        travelPosts.clear();
        page = 1;
        hasMore = true;
      });
    }

    try {
      final fetchedPosts = await ApiService().fetchTravelNews(
        page: page,
        city: selectedCity,
        date: selectedDate,
      );
      setState(() {
        page++;
        travelPosts.addAll(fetchedPosts);
        if (fetchedPosts.isEmpty) hasMore = false;
      });
    } catch (e) {
      debugPrint("Error fetching travel news: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = DateFormat('yyyy-MM-dd').format(picked));
    }
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
            _buildSectionTitle("Latest Travel News"),
            _buildAppBar(),
            _buildCategoriesList(),
            _buildFilterRow(),
            Expanded(child: _buildVerticalNewsList()),
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
        style: GoogleFonts.hindVadodara(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.orange.shade900,
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
                setState(() => selectedCategory = category["title"]);
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

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedCity.isEmpty ? null : selectedCity,
              hint: const Text("Select City"),
              items: cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
              onChanged: (value) => setState(() => selectedCity = value ?? ""),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: _selectDate,
            child: Text(selectedDate.isEmpty ? "Pick Date" : selectedDate),
          ),
          ElevatedButton(
            onPressed: () => _fetchTravelPosts(reset: true),
            child: const Text("Filter"),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalNewsList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: travelPosts.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < travelPosts.length) {
          final post = travelPosts[index];
          return _buildNewsCard(post);
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildNewsCard(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewsDetailScreen(post: post)),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: post.featuredImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _imagePlaceholder(),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 40, color: Colors.red),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      unescape.convert(post.title),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.hindVadodara(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green, size: 20),
                        onPressed: () => _shareOnWhatsApp(post),
                      ),
                      IconButton(
                        icon: FaIcon(FontAwesomeIcons.facebook, color: Colors.blue, size: 20),
                        onPressed: () => _shareOnFacebook(post),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareOnWhatsApp(Post post) async {
    final url = "https://wa.me/?text=\${Uri.encodeComponent('\${post.title}\n\${post.link}')}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch WhatsApp");
    }
  }

  void _shareOnFacebook(Post post) async {
    final url = "https://www.facebook.com/sharer/sharer.php?u=\${Uri.encodeComponent(post.link)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch Facebook");
    }
  }

  Widget _imagePlaceholder() => Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator()));
}
