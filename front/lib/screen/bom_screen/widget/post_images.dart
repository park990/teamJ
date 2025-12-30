import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:front/screen/bom_screen/const/full_image_viewer.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';

class PostImages extends StatelessWidget {
  final Post post;
  final List<String> images;

  const PostImages({super.key, required this.post, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    // -----------------------------------------------------------
    // Case 1: 이미지가 1개일 때 (크게, 스크롤 없이 보여줌)
    // -----------------------------------------------------------
    if (images.length == 1) {
      return Padding(
        padding: const EdgeInsets.only(top: 7),
        child: GestureDetector(
          onTap: () => _openViewer(context, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: images[0],
              height: 280, // 1장일 땐 시원하게 280
              width: double.infinity, // 가로 꽉 차게
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 280,
                color: Colors.grey.shade200,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
            ),
          ),
        ),
      );
    }

    // -----------------------------------------------------------
    // Case 2: 이미지가 여러 개일 때 (작게, 가로 스크롤)
    // -----------------------------------------------------------
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: SizedBox(
        height: 180, // 여러 장일 땐 180
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openViewer(context, index),
              child: AspectRatio(
                aspectRatio: 3 / 4, // 3:4 비율 유지
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    memCacheWidth:300,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 뷰어 여는 함수 따로 빼둠 (중복 제거)
  void _openViewer(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullImageViewerScreen(
          imagePaths: images,
          initialIndex: index,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}