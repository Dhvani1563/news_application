import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsapp/models/post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ApiService {
  final String baseUrl = "https://mantavyanews.com/wp-json/wp/v2/posts?_embed=true";
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // ✅ Initialize Local Notifications
  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // ✅ Generic Fetch Posts with Filters
  Future<List<Post>> fetchPosts({
    String searchQuery = "",
    String category = "",
    String tag = "",
    String city = "",
    String date = "",
    int page = 1,
  }) async {
    try {
      String url = "$baseUrl&page=$page";

      if (searchQuery.isNotEmpty) url += "&search=$searchQuery";
      if (category.isNotEmpty) url += "&categories=$category";
      if (tag.isNotEmpty) url += "&tags=$tag";
      if (date.isNotEmpty) {
        url += "&after=${date}T00:00:00&before=${date}T23:59:59";
      }

      print("📡 Fetching posts from: $url");
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        // ✅ Filter city on client-side based on tag slugs
        List<Post> posts = jsonData.map((json) => Post.fromJson(json)).toList();

        if (city.isNotEmpty) {
          posts = posts.where((post) =>
              post.content.toLowerCase().contains(city.toLowerCase()) ||
              post.title.toLowerCase().contains(city.toLowerCase())).toList();
        }

        return posts;
      } else {
        throw Exception("❌ Failed to load news. Status Code: \${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Error fetching posts: $e");
      throw Exception("Error fetching news: $e");
    }
  }

  // ✅ Sports News
  Future<List<Post>> fetchSportsNews({int page = 1, String city = "", String date = ""}) async {
    const String sportsCategories = "65735,116";
    const String sportsTags = "1086";
    return fetchPosts(category: sportsCategories, tag: sportsTags, page: page, city: city, date: date);
  }

  // ✅ Crime News
  Future<List<Post>> fetchCrimeNews({
    String searchQuery = "",
    int page = 1,
    String tag = "",
    String? afterDate,
    String city = "",
  }) async {
    const String baseCrimeTags = "456649,469569,469607";
    const String categories = "94,438669";
    String combinedTags = baseCrimeTags;
    if (tag.isNotEmpty) combinedTags += ",\$tag";

    return fetchPosts(
      category: categories,
      tag: combinedTags,
      searchQuery: searchQuery,
      city: city,
      date: afterDate ?? "",
      page: page,
    );
  }

  // ✅ Travel News
  Future<List<Post>> fetchTravelNews({int page = 1, String city = "", String date = ""}) async {
    const String travelCategory = "65735";
    const String travelTags = "574123,685";
    return fetchPosts(category: travelCategory, tag: travelTags, page: page, city: city, date: date);
  }

  // ✅ Tech & Auto News
  Future<List<Post>> fetchTechAutoNews({int page = 1, String searchQuery = "", String city = "", String date = ""}) async {
    const String techAutoCategory = "127";
    const String techTags = "571913,522764,572214";
    return fetchPosts(category: techAutoCategory, tag: techTags, searchQuery: searchQuery, page: page, city: city, date: date);
  }

  // ✅ Breaking News
  Future<List<Post>> fetchBreakingNews() async {
    const String breakingNewsTag = "514991";
    return fetchPosts(tag: breakingNewsTag);
  }

  // ✅ Check & Notify New Breaking News
  Future<void> checkForNewBreakingNews() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastNewsId = prefs.getInt('last_breaking_news_id');

    List<Post> breakingNews = await fetchBreakingNews();

    if (breakingNews.isNotEmpty) {
      int latestNewsId = breakingNews.first.id;

      if (lastNewsId == null || latestNewsId > lastNewsId) {
        await _sendNotification(
          breakingNews.first.title,
          breakingNews.first.link,
        );
        await prefs.setInt('last_breaking_news_id', latestNewsId);
      }
    }
  }

  // ✅ Trigger Local Notification
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

  // ✅ YouTube Shorts
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

      print("🎥 Total Shorts Found: \${shortsVideos.length}");
      return shortsVideos;
    } catch (e) {
      print("⚠️ Error fetching YouTube Shorts: $e");
      return [];
    }
  }
}
