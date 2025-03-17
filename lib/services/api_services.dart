import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsapp/models/post.dart';

class ApiService {
  final String baseUrl = "https://mantavyanews.com/wp-json/wp/v2/posts?_embed=true";

  // ✅ Fetch All Posts
  Future<List<Post>> fetchPosts({String searchQuery = "", String category = "", String tag = ""}) async {
    try {
      String url = baseUrl;

      if (searchQuery.isNotEmpty) url += "&search=$searchQuery";
      if (category.isNotEmpty) url += "&categories=$category";
      if (tag.isNotEmpty) url += "&tags=$tag";

      print("📡 Fetching posts from: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception("❌ Failed to load news. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error fetching posts: $e");
      throw Exception("Error fetching news: $e");
    }
  }

  // ✅ Fetch Sports News
  Future<List<Post>> fetchSportsNews() async {
    const String sportsCategories = "65735,116"; // Add correct category IDs
    const String sportsTags = "1086"; // Add correct tag IDs
    return fetchPosts(category: sportsCategories, tag: sportsTags);
  }

  // ✅ Fetch Crime News
  Future<List<Post>> fetchCrimeNews({String searchQuery = ""}) async {
    const String crimeCategories = "94,438669"; // Crime categories
    const String crimeTags = "456649,469569,469607"; // Crime tags
    return fetchPosts(category: crimeCategories, tag: crimeTags, searchQuery: searchQuery);
  }

  // ✅ Fetch Travel News
Future<List<Post>> fetchTravelNews() async {
  const String travelCategory = "65735"; // Found related category ID
  const String travelTags = "574123,685"; // Found tags for flight-related news
  return fetchPosts(category: travelCategory, tag: travelTags);
}


  // ✅ Fetch Tech & Auto News
  Future<List<Post>> fetchTechAutoNews({String searchQuery = ""}) async {
    const String techAutoCategory = "127"; // Tech category
    const String techTags = "571913,522764,572214"; // Tech tags
    return fetchPosts(category: techAutoCategory, tag: techTags, searchQuery: searchQuery);
  }
    final String youtubeApiKey = "AIzaSyBuUH3_8xOxbefHdJT3NW6dkZuvO9fgLzg"; // Replace with your YouTube API Key
  final String youtubeChannelId = "UCIXeA1npsX8jbl62TdP9-PA"; // Mantavya News Channel ID
  

 Future<List<Post>> fetchYouTubeShorts() async {
  try {
    String url =
        "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$youtubeChannelId"
        "&maxResults=20&type=video&videoDuration=short&key=$youtubeApiKey";

    print("📡 Fetching YouTube Shorts from: $url");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("❌ Failed to fetch Shorts videos");
    }

    final data = json.decode(response.body);
    List<Post> shortsVideos = [];

    for (var item in data["items"]) {
      String videoId = item["id"]["videoId"];
      String title = item["snippet"]["title"];
      String thumbnail = item["snippet"]["thumbnails"]["high"]["url"];
      String videoUrl = "https://www.youtube.com/shorts/$videoId";

      print("🎥 Found video: $title");

      // Checking if it is a Short
      bool isShort = title.toLowerCase().contains("#shorts");

      print(isShort ? "✅ This is a Shorts video" : "❌ This is NOT a Shorts video");

      shortsVideos.add(Post(
        id: 0,
        title: title,
        slug: "",
        content: "",
        date: "",
        link: videoUrl,
        author: 0,
        featuredImageUrl: thumbnail,
        videoUrl: videoUrl,
      ));
    }

    print("🎥 Total Shorts Found: ${shortsVideos.length}");
    return shortsVideos;
  } catch (e) {
    print("⚠️ Error fetching YouTube Shorts: $e");
    return [];
  }
}
}