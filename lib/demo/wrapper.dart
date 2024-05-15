import 'package:flutter/material.dart';
import 'package:best_note/model/mn_video_player.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> urls = [
      'https://cdn.pixabay.com/photo/2020/05/27/05/22/portrait-5225730_960_720.jpg',
      'https://imgv3.fotor.com/images/homepage-feature-card/Fotor-AI-photo-enhancement-tool.jpg',
      'https://thumbs.dreamstime.com/b/image-wood-texture-boardwalk-beautiful-autumn-landscape-background-free-copy-space-use-background-backdrop-to-132997627.jpg',
      'https://www.foleon.com/hubfs/Blogs/5%20sites%20for%20free%20stock%20photos/stockfoto.jpg'
    ];
    urls.insert(2, 'https://onlinejpgtools.com/images/examples-onlinejpgtools/sunflower.jpg');
    return Scaffold(
        backgroundColor: Colors.amber[200],
        appBar: AppBar(
          title: Text('wrapper'),
          backgroundColor: Colors.brown,
        ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Wrap(
            children: [
              mnTextField('Hi This is Bob again. I love pasta and beautiful gals here in mugdabaad. Hi This is Bob again. I love pasta and beautiful gals here in mugdabaad. '),
              imageViewer(urls[1]),
              gapper(),
              imageViewer(urls[2]),
              gapper(),
              MnvPlayer(videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
              gapper(),
              imageViewer(urls[3]),
              gapper(),
              mnTextField('Hi! This is Bob. I love to read here. Please follow my note. I would love to follow you back.'),
              Container(
                child: Image.network(urls[0]),
                width: 150,
                margin: EdgeInsets.all(5),
              )
            ],
          ),
        ),
      ),
    );
  }
}



Widget mnTextField(String initVal){
  return TextFormField(
    initialValue: initVal,
    style: TextStyle(
      fontSize: 18,
      color: Colors.grey[800],
    ),
    maxLines: null,
    decoration: InputDecoration(
      border: InputBorder.none,
    ),
  );
}


Widget imageViewer(String url){
  return Container(
    child: Image.network(url),
    width: 150,
    margin: EdgeInsets.all(5),
  );
}

Widget gapper(){
  return Container(
  width: 7,
  height: 70,
  color: Colors.grey[400],
  );
}