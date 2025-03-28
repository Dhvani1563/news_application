import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newsapp/models/post.dart';
import 'package:newsapp/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsapp/presentations/NewsDetailScreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ApiService apiService = ApiService();
  List<Post> breakingNews = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  /// ✅ **Load Notifications from API**
  Future<void> _loadNotifications() async {
    List<Post> news = await apiService.fetchBreakingNews();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastNewsId = prefs.getInt('last_breaking_news_id');

    if (news.isNotEmpty) {
      int latestNewsId = news.first.id;

      if (lastNewsId == null || latestNewsId > lastNewsId) {
        await prefs.setInt('last_breaking_news_id', latestNewsId);
      }
    }

    setState(() {
      breakingNews = news;
    });
  }

  /// ✅ **Function to Remove `#9090` from Title**
  String cleanTitle(String text) {
    return text.replaceAll(RegExp(r'#\d+'), '').trim(); // Removes # followed by numbers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.hindVadodara(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: breakingNews.isEmpty ? _buildNoNotifications() : _buildNotificationList(),
    );
  }

  /// ✅ **No Notifications UI**
  Widget _buildNoNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 10),
          Text(
            "No breaking news available",
            style: GoogleFonts.hindVadodara(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ **Notification List UI (Unchanged, just cleaned title)**
  Widget _buildNotificationList() {
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: breakingNews.length,
        itemBuilder: (context, index) {
          final Post news = breakingNews[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blue),
              title: Text(
                cleanTitle(news.title), // ✅ Cleaned title only
                style: GoogleFonts.hindVadodara(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    news.date,
                    style: GoogleFonts.hindVadodara(fontSize: 12, color: Colors.blueGrey),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewsDetailScreen(post: news)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
