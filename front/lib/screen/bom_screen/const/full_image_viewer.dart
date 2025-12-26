import 'package:flutter/material.dart';

class FullImageViewerScreen extends StatefulWidget {
  final List<String> imagePaths; // 한 장이 아니라 리스트로 받음
  final int initialIndex;        // 클릭한 사진의 번호부터 시작

  const FullImageViewerScreen({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<FullImageViewerScreen> createState() => _FullImageViewerScreenState();
}

class _FullImageViewerScreenState extends State<FullImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${_currentIndex + 1} / ${widget.imagePaths.length}', 
                   style: const TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagePaths.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Hero(
                // Hero 태그는 리스트와 동일해야 하므로 인덱스를 포함함
                tag: 'hero_img_$index', 
                child: Image.asset(
                  widget.imagePaths[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}