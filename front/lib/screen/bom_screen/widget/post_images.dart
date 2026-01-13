import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:front/screen/bom_screen/const/full_image_viewer.dart';
import 'package:front/screen/bom_screen/model/post_model.dart';

class PostImages extends StatelessWidget {
  final Post post;
  final List<String> images;

  const PostImages({
    super.key,
    required this.post,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    if (images.length == 1) {
      return _singleImage(context);
    }

    if (images.length == 2) {
      return _twoImages(context);
    }

    return _multiImages(context);
  }

  // -----------------------------------------------------------
  // Case 1: 이미지 1장 (집중형)
  // -----------------------------------------------------------
Widget _singleImage(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 7),
    child: GestureDetector(
      onTap: () => _openViewer(context, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 260,
        ),
        child: AspectRatio(
          aspectRatio: 4 / 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: images.first,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image),
            ),
          ),
        ),
      ),
    ),
  );
}

  // -----------------------------------------------------------
  // Case 2: 이미지 2장 (2열 고정)
  // -----------------------------------------------------------
  Widget _twoImages(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: List.generate(images.length, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 4,
                right: index == 1 ? 0 : 4,
              ),
              child: GestureDetector(
                onTap: () => _openViewer(context, index),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // -----------------------------------------------------------
  // Case 3: 이미지 3장 이상 (가로 스크롤)
  // -----------------------------------------------------------
  Widget _multiImages(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: images.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openViewer(context, index),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.cover,
                    memCacheWidth: 300,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // 이미지 뷰어
  // -----------------------------------------------------------
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
