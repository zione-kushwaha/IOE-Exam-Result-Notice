import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:project_5/imagelist.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}

class Notice {
  final String number;
  final String title;
  final String date;
  final String downloadLink;

  Notice({
    required this.number,
    required this.title,
    required this.date,
    required this.downloadLink,
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selected = 1;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  void initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        );
  }

  Future<void> onSelectNotification(String? payload) async {
    // Handle notification tap
    print('Notification tapped: $payload');
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', 'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'new_notice_payload',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: const Text('IOE Result Notice'),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                CarouselSlider(
   items:imagelist ,
   options: CarouselOptions(
      height: 200,
      aspectRatio: 16/9,
      viewportFraction: 0.8,
      initialPage: 0,
      enableInfiniteScroll: true,
      reverse: false,
      autoPlay: true,
      autoPlayInterval: const Duration(seconds: 2),
      autoPlayAnimationDuration: const Duration(milliseconds: 800),
      autoPlayCurve: Curves.fastOutSlowIn,
      enlargeCenterPage: true,
      enlargeFactor: 0.3,
      scrollDirection: Axis.horizontal,
   )
 ),

            Expanded(
              child: FutureBuilder<List<Notice>>(
                future: fetchNotices(selected),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No notices available.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var notice = snapshot.data![index];
                        return Card(
                          child: ListTile(
                            title: Text(notice.title),
                            subtitle: Text('Date: ${notice.date}',
                                style: const TextStyle(fontSize: 12)),
                            leading: CircleAvatar(
                              child: Text(notice.number),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                launchUrl(
                                    Uri.parse('http://exam.ioe.edu.np${notice.downloadLink}'));
                              },
                              icon: const Icon(Icons.download, color: Colors.red),
                            ),
                            onTap: () {
                              openPage(notice.number);
                              showNotification('New Notice', notice.title);
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12, left: 10),
              child: const Text(
                "Pages",
                style: TextStyle(fontSize: 15, color: Colors.purple),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (int i = 1; i <= 50; i++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selected = i;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 15, top: 5),
                          height: 40,
                          width: 65,
                          child: Center(child: Text('$i')),
                          decoration: BoxDecoration(
                              color: getcolor(i % 4),
                              gradient: LinearGradient(
                                  colors
: [getcolor(i % 4).withOpacity(0.4), getcolor(i % 4)]),
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color getcolor(int i) {
    switch (i) {
      case 0:
        return const Color.fromARGB(255, 243, 33, 33);
      case 1:
        return Colors.orange;
      case 2:
        return const Color.fromARGB(255, 238, 246, 10);
      case 3:
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  Future<List<Notice>> fetchNotices(int i) async {
    final response =
        await http.get(Uri.parse('http://exam.ioe.edu.np/?page=$i'));

    if (response.statusCode == 200) {
      return parseHtmlToNotices(response.body);
    } else {
      throw Exception('Failed to fetch notices');
    }
  }

  List<Notice> parseHtmlToNotices(String html) {
    final document = parse(html);

    List<Notice> notices = [];

    for (var row
        in document.querySelectorAll('table#datatable tbody tr')) {
      Notice notice = Notice(
        number: row.querySelector('td:nth-child(1)')?.text ?? '',
        title: row.querySelector('td:nth-child(3) a')?.text ?? '',
        date: row.querySelector('td:nth-child(5)')?.text ?? '',
        downloadLink:
            row.querySelector('td:nth-child(3) >a')?.attributes['href'] ?? '',
      );

      notices.add(notice);
    }

    return notices;
  }

  Future<void> openPage(String pageNumber) async {
    print('Open page $pageNumber');
  }
}
