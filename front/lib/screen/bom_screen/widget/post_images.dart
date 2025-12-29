// screen/bom_screen/widgets/post_images.dart
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
    print('${images}이미지이미지이미지이미지');
    if(images.isEmpty) {

      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final String heroTag = 'post_${post.id}_$index';
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => FullImageViewerScreen(imagePaths: images, initialIndex: index),
                fullscreenDialog: true,
              )),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(imageUrl: images[index],
                fit:BoxFit.cover,
                placeholder: (context, url) =>
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image),
                ),
                
              ),
            );
          },
        ),
      ),
    );
  }
}