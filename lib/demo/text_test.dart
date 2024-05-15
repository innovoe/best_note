import 'package:flutter/material.dart';
import 'package:best_note/model/text_field_generator.dart';

class TextTest extends StatefulWidget {
  const TextTest({Key? key}) : super(key: key);

  @override
  State<TextTest> createState() => _TextTestState();
}

class _TextTestState extends State<TextTest> {
  List<Widget> inputs = [];
  List<TextFieldGenerator> tfgList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[200],
      appBar: AppBar(
        title: Text('Testing testing ok ok'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
              onPressed: (){
                for(TextFieldGenerator tf in tfgList){
                  print(tf.mnValue());
                }
              },
              icon: Icon(Icons.refresh)
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: inputs,
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextFieldGenerator tfg = TextFieldGenerator();
          setState((){
            inputs.add(tfg.mnInput());
            tfgList.add(tfg);
          });
        },
        child: Text('print'),
      ),
    );
  }
}
