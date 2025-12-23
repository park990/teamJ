// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:front/screen/bom_screen/model/post_model.dart';
// import 'package:front/theme/app_colors.dart';

// class PostDetailScreen extends ConsumerWidget {
//   final PostId; // 게시글 정보를 통째로 받거나, id만 받아서 새로 호출할 수 있습니다.

//   const PostDetailScreen({super.key, required this.PostId});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text('상세보기', style: wazzupBarFont),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. 작성자 정보 및 날짜
//             Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             const SizedBox(height: 4),
//             Text(post.displayDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//             const Divider(height: 30),

//             // 2. 제목
//             Text(post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 20),

//             // 3. 내용
//             Text(post.content, style: const TextStyle(fontSize: 16, height: 1.5)),
            
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
// }