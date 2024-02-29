import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';

void main() async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
   Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arce search bar',
      home:App(),
    );
  }
}

class App  extends StatefulWidget{
  @override
 _AppState createState()=> _AppState();
}

class _AppState extends State<App>{
  TextEditingController textController= TextEditingController();
 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text('ARCE'),
       // Adjust the appBar according to your requirements
     ),
     body: Padding(
       padding: const EdgeInsets.all(10.0),
       child: AnimSearchBar(
         width: 400,
         textController: textController,
         onSuffixTap: () {
           setState(() {
             textController.clear();
           });
         }, onSubmitted: (String ) {  },
       ),
     ),
   );
 }
}