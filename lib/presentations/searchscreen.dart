import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newsapp/models/post.dart';
import 'package:newsapp/services/api_services.dart';
import 'package:newsapp/presentations/NewsDetailScreen.dart';
import 'package:flutter_html/flutter_html.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Post> searchResults = [];
  bool isLoading = false;

  void _searchNews(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      List<Post> results = await ApiService().fetchPosts(searchQuery: query);
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      print("Error fetching search results: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Looking for something today?",
          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// **Search Bar**
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: "Search...",
                        border: InputBorder.none,
                      ),
                      onChanged: _searchNews,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _searchNews(_searchController.text),
                    icon: const Icon(Icons.search, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /// **Loading Indicator**
            if (isLoading) const Center(child: CircularProgressIndicator()),

            /// **Search Results**
            if (!isLoading && searchResults.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final post = searchResults[index];
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
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// **News Image**
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[300],
                                image: post.featuredImageUrl.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(post.featuredImageUrl),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: post.featuredImageUrl.isEmpty
                                  ? Icon(Icons.image, color: Colors.grey[600])
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.title,
                                    style: GoogleFonts.sora(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Html(
                                    data: post.content.length > 80
                                        ? "${post.content.substring(0, 80)}..."
                                        : post.content,
                                    style: {
                                      "body": Style(
                                        fontSize: FontSize(14),
                                        color: Colors.black87,
                                      ),
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

         
            if (!isLoading && searchResults.isEmpty && _searchController.text.isNotEmpty)
              const Center(child: Text("No results found")),
          ],
        ),
      ),
    );
  }
}
