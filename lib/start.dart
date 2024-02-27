import 'package:flutter/material.dart';

class start extends StatefulWidget{
  const start({super.key});

  @override
  State<start> createState()=> _startState();

}
class _startState extends State<start>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('ARCE'),
        actions:[
          IconButton(onPressed: (){}, icon: Icon(Icons.search))
        ]
      ),
    );
  }
}


