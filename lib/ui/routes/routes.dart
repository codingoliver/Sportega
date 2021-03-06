import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sportega/ui/holders/news.dart';
import 'package:sportega/ui/holders/photo.dart';
import 'package:sportega/ui/holders/video.dart';
import 'package:sportega/ui/pages/home_page.dart';
import 'package:sportega/ui/pages/news_page.dart';
import 'package:sportega/ui/pages/photo_page.dart';
import 'package:sportega/ui/pages/video_page.dart';

class Routes {
  void navigateToHomePage(BuildContext context) {
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    });
  }

  void navigateToNewsPage(BuildContext context, News news) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => NewsPage(news: news)));
  }

  void navigateToVideoPage(BuildContext context, Video video) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => VideoPage(video: video)));
  }

  void navigateToPhotoPage(BuildContext context, Photo photo) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PhotoPage(photo: photo)));
  }
}
