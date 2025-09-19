import 'dart:math';
import 'package:flutter/material.dart';

class CardWheelScroll extends StatefulWidget {
  @override
  _CardWheelScrollState createState() => _CardWheelScrollState();
}

class _CardWheelScrollState extends State<CardWheelScroll> {
  late PageController _pageController;
  int currentPage = 0;

  final List<Color> cardColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.6, initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _navigate(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(color: cardColors[index])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Align(
        alignment: Alignment.centerRight, // ✅ right side alignment
        child: PageView.builder(
          controller: _pageController,
          itemCount: cardColors.length,
          physics: BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            double difference = 0;
            double scale = 1.0;
            double opacity = 0.5;
            double rotationY = 0.0;

            if (_pageController.position.haveDimensions) {
              difference = (_pageController.page! - index);
              scale = 1 - (difference.abs() * 0.2);
              opacity = 1 - (difference.abs() * 0.6);
              opacity = opacity.clamp(0.3, 1.0);
              rotationY = difference * 0.4; // tilt effect like wheel
            }

            bool isCenter = index == currentPage;

            return GestureDetector(
              onTap: () {
                if (isCenter) {
                  _navigate(index);
                } else {
                  _goToPage(index);
                }
              },
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(scale)
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateY(rotationY),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 40),
                    decoration: BoxDecoration(
                      color: cardColors[index],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if (isCenter)
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Card ${index + 1}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCenter ? 28 : 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Example detail screen
class DetailScreen extends StatelessWidget {
  final Color color;
  DetailScreen({required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(title: Text("Detail Screen")),
      body: Center(
        child: Text(
          "Details of this card",
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
