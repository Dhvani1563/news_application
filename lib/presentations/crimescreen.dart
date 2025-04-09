import 'package:flutter/material.dart';
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
import 'package:newsapp/presentations/travelnewsscreen.dart';
import 'package:newsapp/presentations/automationnewsscreen.dart';
import 'package:newsapp/presentations/shorts_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CrimeNewsScreen extends StatefulWidget {
  const CrimeNewsScreen({super.key});

  @override
  State<CrimeNewsScreen> createState() => _CrimeNewsScreenState();
}

class _CrimeNewsScreenState extends State<CrimeNewsScreen> {
  final HtmlUnescape unescape = HtmlUnescape();
  final ScrollController _scrollController = ScrollController();

  List<Post> _crimePosts = [];
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String selectedCategory = "Crime";
  String? _selectedCityTag;
  DateTime? _selectedDate;

  final List<Map<String, String>> _cities = [
    {"name": "All", "tag": ""},
    {"name": "Ahmedabad", "tag": "469569"},
    {"name": "Surat", "tag": "456649"},
    {"name": "Rajkot", "tag": "469607"},
    {"name": "Vadodara", "tag": "469610"},
    {"name": "Bhavnagar", "tag": "469612"},
    {"name": "Jamnagar", "tag": "469613"},
    {"name": "Gandhinagar", "tag": "469615"},
    {"name": "Junagadh", "tag": "469616"},
    {"name": "Anand", "tag": "469617"},
    {"name": "Nadiad", "tag": "469618"},
    {"name": "Navsari", "tag": "469619"},
    {"name": "Bharuch", "tag": "469620"},
    {"name": "Mehsana", "tag": "469621"},
    {"name": "Bhuj", "tag": "469622"},
    {"name": "Palanpur", "tag": "469623"},
    {"name": "Valsad", "tag": "469624"},
    {"name": "Vapi", "tag": "469625"},
    {"name": "Porbandar", "tag": "469626"},
    {"name": "Amreli", "tag": "469627"},
    {"name": "Surendranagar", "tag": "469628"}
  ];

  @override
  void initState() {
    super.initState();
    _fetchCrimePosts();
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _fetchCrimePosts({bool reset = false}) async {
    if (_isLoading || (!_hasMore && !reset)) return;
    if (reset) {
      setState(() {
        _crimePosts.clear();
        _page = 1;
        _hasMore = true;
      });
    }

    setState(() => _isLoading = true);

    try {
      final newPosts = await ApiService().fetchCrimeNews(
        page: _page,
        tag: _selectedCityTag ?? "",
        afterDate: _selectedDate?.toIso8601String(),
      );
      setState(() {
        _page++;
        _crimePosts.addAll(newPosts);
        if (newPosts.length < 10) _hasMore = false;
      });
    } catch (e) {
      debugPrint("Error fetching crime news: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      _fetchCrimePosts();
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
            _buildAppBar(),
            _buildCategoriesList(),
            _buildFilters(),
            _buildSectionTitle("Latest Crime News"),
            Expanded(child: _buildVerticalNewsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _selectedCityTag,
              hint: const Text("City"),
              isExpanded: true,
              items: _cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city["tag"],
                  child: Text(city["name"]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCityTag = value);
                _fetchCrimePosts(reset: true);
              },
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            icon: const Icon(Icons.date_range, size: 18),
            label: Text(
              _selectedDate != null ? _selectedDate!.toLocal().toString().split(' ')[0] : 'Pick Date',
              style: const TextStyle(fontSize: 14),
            ),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
                _fetchCrimePosts(reset: true);
              }
            },
          ),
        ],
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
        style: GoogleFonts.hindVadodara(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildVerticalNewsList() {
    if (_crimePosts.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_crimePosts.isEmpty) {
      return const Center(child: Text('⚠️ No crime news available!'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _crimePosts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _crimePosts.length) {
          final post = _crimePosts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewsDetailScreen(post: post)),
              );
            },
            child: _buildNewsCard(post),
          );
        } else {
          return const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: CircularProgressIndicator(),
          ));
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
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    unescape.convert(post.title),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hindVadodara(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                      onPressed: () => _shareOnWhatsApp(post.link),
                    ),
                    IconButton(
                      icon: const Icon(Icons.facebook, color: Colors.blue),
                      onPressed: () => _shareOnFacebook(post.link),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareOnWhatsApp(String link) async {
    final uri = Uri.parse("https://wa.me/?text=$link");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch WhatsApp");
    }
  }

  void _shareOnFacebook(String link) async {
    final uri = Uri.parse("https://www.facebook.com/sharer/sharer.php?u=$link");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch Facebook");
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
