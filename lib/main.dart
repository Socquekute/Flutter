import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart'as http;
import 'package:flutter_tts/flutter_tts.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {



  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? file;
  String? input= "";
  String? translate="" ;
  final TextEditingController textEditing = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  final FlutterTts flutterTts= FlutterTts();

// text to speech in the input
  Future _speaktrans(String text) async{
    await flutterTts.setLanguage(_controller.text);
    await flutterTts.speak(text);
  }
  Future _speakinput(String text) async{
    await flutterTts.setLanguage(textEditing.text);
    await flutterTts.speak(text);
  }
//orc or speech to text:
  Future selectfile() async{
    final result= await FilePicker.platform.pickFiles(allowMultiple: false);
    if(result==null) return;
    final path = result.files.single.path!;
    setState(() {
        file = File(path);
    });
  }

  Future uploadimage() async{
  final request=  http.MultipartRequest("POST", Uri.parse("http://10.0.2.2:5000/uploadimage"));
  final headers= {"Content-type":"multipart/form-data"};
  request.files.add(
    http.MultipartFile("file", file!.readAsBytes().asStream(),file!.lengthSync(), filename: file!.path.split("/").last));
  request.headers.addAll(headers);
  final response = await request.send();
  http.Response res= await  http.Response.fromStream(response);

  print("Upload success");

  setState(() {
   input =  jsonDecode(res.body)['answer'];
  });
  }
  // translate
  Future translatetext() async{
    http.Response response = await http.Client().post(Uri.parse("http://10.0.2.2:5000/translate"),body:{
      'text': input,
      'language': _controller.text,
    });
  setState(() {
    translate = jsonDecode(response.body)['translatedText'];
  });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
      final filename = file!= null ?  basename(file!.path) : "No File Selected";
    return Scaffold(
        appBar: AppBar(

          title: Text("UPLOAD FILE "),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () {selectfile();}, child: Text("Select a file")),
              Text(filename),
              TextField(
                controller: textEditing,
                decoration: InputDecoration(
                  hintText: "Input your language"
                ),
              ),
              ElevatedButton(onPressed: () {uploadimage();}, child: Text("Upload file")),
              Text(input!),
              FloatingActionButton(
                child: Icon(Icons.mic),
                onPressed: () => _speakinput(input!),
              ),
              Text("Translate Text:"),
              TextField(
                controller: _controller,
                 decoration: InputDecoration(
                    hintText: "Input your language to translate",
                 ),
              ),
              Column(
                children: [
                  ElevatedButton(onPressed: () {translatetext();},
                      child: Text("Translate text")),
                  FloatingActionButton(
                    child: Icon(Icons.mic),
                    onPressed: () => _speaktrans(translate!),
                  )
                ],
              ),
              Text(translate!),


            ],
          ),
        )
    );
  }
}