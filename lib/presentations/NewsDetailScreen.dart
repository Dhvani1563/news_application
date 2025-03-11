import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newsapp/models/post.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_html/flutter_html.dart';

class NewsDetailScreen extends StatelessWidget {
  final Post post;

  const NewsDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final HtmlUnescape unescape = HtmlUnescape();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          unescape.convert(post.title),
          style: GoogleFonts.hindVadodara(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade900,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rectangular image container with no rounded borders
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: CachedNetworkImage(
                  imageUrl: post.featuredImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.contain, // Shows the full image without cropping
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.error, color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                unescape.convert(post.title),
                style: GoogleFonts.hindVadodara(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                post.date,
                style: GoogleFonts.hindVadodara(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              // Render the HTML content instead of plain text
              Html(
                data: unescape.convert(post.content),
                style: {
                  "p": Style(
                    fontSize: FontSize(16.0),
                     textAlign: TextAlign.justify,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
