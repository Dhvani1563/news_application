import 'package:html/parser.dart';

class Post {
  final int id;
  final String title;
  final String slug;
  final String content;
  final String date;
  final String link;
  final int author;
  final String featuredImageUrl;
  final String videoUrl;

  Post({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.date,
    required this.link,
    required this.author,
    required this.featuredImageUrl,
    required this.videoUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    String featuredImageUrl = '';
    String videoUrl = '';

    // ✅ Extract Featured Image
    try {
      featuredImageUrl = json['_embedded']?['wp:featuredmedia']?[0]['source_url'] ?? '';
    } catch (e) {
      print("⚠️ Error extracting image for Post ID: ${json['id']} - $e");
    }

    // ✅ Extract Video URL
    if (json['content']?['rendered'] != null) {
      String content = json['content']['rendered'];
      var document = parse(content);

      // ✅ Extract YouTube Shorts
      if (content.contains("youtube.com/shorts/")) {
        RegExp youtubeShortsRegex = RegExp(r'https:\/\/www\.youtube\.com\/shorts\/[a-zA-Z0-9_-]+');
        Match? match = youtubeShortsRegex.firstMatch(content);
        if (match != null) {
          videoUrl = match.group(0)!;
        }
      }
    }

    return Post(
      id: json['id'] ?? 0,
      title: json['title']?['rendered'] ?? "No Title",
      slug: json['slug'] ?? "no-slug",
      content: json['content']?['rendered'] ?? "",
      date: json['date'] ?? "Unknown Date",
      link: json['link'] ?? "",
      author: json['author'] ?? 0,
      featuredImageUrl: featuredImageUrl,
      videoUrl: videoUrl,
    );
  }
}
