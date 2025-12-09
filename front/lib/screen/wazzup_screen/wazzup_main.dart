import 'package:flutter/material.dart';

class WazzupMain extends StatelessWidget {
  const WazzupMain({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Center(
          child: Text(
            'WAZZUP 게시판',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.white,
      ),

      body: Column(
        children: [
          _HotBbs(),
          _BbsList(),
        ],
      ),
    );
  }
}

class _HotBbs extends StatelessWidget {
  const _HotBbs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 8,
            left: 16
          ),
          child: Text(
            '이번주 Hot 게시글',
          style: TextStyle(
            fontWeight: FontWeight.w700    
          ),
        ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12
          ),
          child: Column(
            children: [
              _BuildHotItem(rank: 1, title: '1등글의 제목asdfasdfasdfasdfasd',nickName:'Pjy', likes: 1, views:500),
              Divider(color: Colors.grey),
              _BuildHotItem(rank: 2, title: '나는야 신준수 똥벌레다 개똥벌레다',nickName:'Sjs', likes: 1, views:400),
              Divider(color: Colors.grey),
              _BuildHotItem(rank: 3, title: '모니터 선택장애가 있습니다.',nickName:'Jhg', likes: 1, views:300),
              Divider(color: Colors.grey),
              _BuildHotItem(rank: 4, title: '1등글의 제목',nickName:'jjj', likes: 1, views:200),
              Divider(color: Colors.grey),
              _BuildHotItem(rank: 5, title: '1등글의 제목',nickName:'jyp', likes: 1, views:100),
            ],
          ),
        ),

      ],
    );
  }

  Widget _BuildHotItem({
    required int rank,
    required String title,
    required int likes,
    required String nickName,
    required int views,
  }) {
    return InkWell(
      onTap: (){
        
      },
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: rank == 1
                  ? Colors.orangeAccent
                  : rank == 2
                  ? Colors.grey[400]
                  :rank == 3
                  ?Colors.brown[300]
                  :null, 
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$rank',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              '$title',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              '$nickName',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Icon(
            Icons.thumb_up_alt_sharp,
            size: 14,
            color: Colors.blue,
          ),
          SizedBox(width: 4),
          Text('$likes', style: TextStyle(color: Colors.grey)),
          SizedBox(width: 8),
          Icon(Icons.people_outline_outlined,size: 20,),
          Text('$views', style: TextStyle(color: Colors.grey))
        ],
      ),
    );
  }
}

class _BbsList extends StatelessWidget {
  const _BbsList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> BbsTitle = ['자유게시판', '인연찾기', '운동게시판'];
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: BbsTitle.length,
        itemBuilder: (context, index) {
          final title = BbsTitle[index];
          return Column(
            children: [
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
