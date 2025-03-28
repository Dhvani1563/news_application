import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsapp/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ApiService {
  final String baseUrl = "https://mantavyanews.com/wp-json/wp/v2/posts?_embed=true";

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // ✅ Initialize Local Notifications
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

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
    const String sportsCategories = "65735,116";
    const String sportsTags = "1086";
    return fetchPosts(category: sportsCategories, tag: sportsTags);
  }

  // ✅ Fetch Crime News
  Future<List<Post>> fetchCrimeNews({String searchQuery = ""}) async {
    const String crimeCategories = "94,438669";
    const String crimeTags = "456649,469569,469607";
    return fetchPosts(category: crimeCategories, tag: crimeTags, searchQuery: searchQuery);
  }

  // ✅ Fetch Travel News
  Future<List<Post>> fetchTravelNews() async {
    const String travelCategory = "65735";
    const String travelTags = "574123,685";
    return fetchPosts(category: travelCategory, tag: travelTags);
  }

  // ✅ Fetch Tech & Auto News
  Future<List<Post>> fetchTechAutoNews({String searchQuery = ""}) async {
    const String techAutoCategory = "127";
    const String techTags = "571913,522764,572214";
    return fetchPosts(category: techAutoCategory, tag: techTags, searchQuery: searchQuery);
  }

  // ✅ Fetch Breaking News
  Future<List<Post>> fetchBreakingNews() async {
    const String breakingNewsTag = "514991";
    return fetchPosts(tag: breakingNewsTag);
  }

  // ✅ Check for New Breaking News & Trigger Notification
  Future<void> checkForNewBreakingNews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastNewsId = prefs.getInt('last_breaking_news_id');

    List<Post> breakingNews = await fetchBreakingNews();

    if (breakingNews.isNotEmpty) {
      int latestNewsId = breakingNews.first.id;

      // ✅ Fix: Ensure lastNewsId is not null
      if (lastNewsId == null || latestNewsId > lastNewsId) {
        await _sendNotification(
          breakingNews.first.title,
          breakingNews.first.link,
        );

        await prefs.setInt('last_breaking_news_id', latestNewsId);
      }
    }
  }

  // ✅ Send Local Notification for Breaking News
  Future<void> _sendNotification(String title, String link) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'breaking_news_channel',
      'Breaking News',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      "Breaking News",
      title,
      platformChannelSpecifics,
      payload: link,
    );
  }

  // ✅ YouTube Shorts API
  final String youtubeApiKey = "AIzaSyBuUH3_8xOxbefHdJT3NW6dkZuvO9fgLzg";
  final String youtubeChannelId = "UCIXeA1npsX8jbl62TdP9-PA";

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
