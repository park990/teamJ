// screen/bom_screen/widgets/post_images.dart
import 'package:flutter/material.dart';
import 'package:front/screen/bom_screen/const/full_image_viewer.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';

class PostImages extends StatelessWidget {
  final Post post;
  final List<String> images;

  const PostImages({super.key, required this.post, required this.images});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: images.length,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final String heroTag = 'post_${post.id}_$index';
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => FullImageViewerScreen(imagePaths: images, initialIndex: index),
                fullscreenDialog: true,
              )),
              child: Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(images[index], width: 280, height: 220, fit: BoxFit.cover),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}