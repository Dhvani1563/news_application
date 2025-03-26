import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Sample notifications (Replace this with API data)
  final List<Map<String, String>> notifications = [
    {
      "title": "Breaking News!",
      "message": "A major sports event is happening now!",
      "time": "10 min ago"
    },
    {
      "title": "New Article Published",
      "message": "Check out the latest tech trends of 2025.",
      "time": "1 hr ago"
    },
    {
      "title": "Weather Update",
      "message": "Heavy rain expected tomorrow. Stay safe!",
      "time": "3 hrs ago"
    },
  ];

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
      body: notifications.isEmpty
          ? _buildNoNotifications()
          : _buildNotificationList(),
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
            "No new notifications",
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

  /// ✅ **Notification List UI**
  Widget _buildNotificationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const Icon(Icons.notifications, color: Colors.blue),
            title: Text(
              notification["title"]!,
              style: GoogleFonts.hindVadodara(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification["message"]!,
                  style: GoogleFonts.hindVadodara(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  notification["time"]!,
                  style: GoogleFonts.hindVadodara(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
            onTap: () {
              // Handle notification click (if needed)
            },
          ),
        );
      },
    );
  }
}
