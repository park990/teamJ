import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front/provider/gathering_keyword_provider.dart';

class GatheringKeywords extends ConsumerWidget {
  const GatheringKeywords({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Provider에서 데이터 가져오기
    final keywords = ref.watch(gatheringKeywordProvider);
    print('데이터개수: ${keywords.length}');
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          ...keywords.map((item){
            return Material(
              child: Ink(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.brown[300]!),
                  ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap:() {
                    debugPrint('클릭된 키워드 : ${item.slug}');
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8
                    ),
                    child: Text(
                      item.title, style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}