import 'package:flutter/material.dart';

import '../todolist/todolist.dart';
class Initial extends StatelessWidget {
  const Initial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
        body: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              color:Colors.white60,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('images/girl.jpg',width: double.infinity,fit: BoxFit.cover,),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Manage your \n',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Everyday task list \n',
                          style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'lorem impsum dotor sit amet consetetuar sasasadccsdsdsd\n',
                          style: TextStyle(fontSize: 12),
                        ),
                        TextSpan(
                          text: 'sadimmasa is there a demo stattssss',
                          style: TextStyle(fontSize:12),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:  Color.fromRGBO(255, 116, 97, 1.0), // Text color
                      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                    ),onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>TaskListScreen()));
                }, child:const Text("get Started") ),
              ],
            ),
          ),

        )
      );

  }
}
