import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  PageController controller = PageController(initialPage: 1,viewportFraction: 0.8);
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          title: Text('함지고등학교-중식'),
        ),
        body: PageView(
          controller: controller,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              margin: EdgeInsets.all(10),
              child: Center(
                child: PicScreen(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              margin: EdgeInsets.all(10),
              child: MealScreen(),
            ),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
              margin: EdgeInsets.all(10),
              child: Center(
                child: SubScreen(),
              )
            )
          ],
        )
      ),
    );
  }
}

class MealScreen extends StatefulWidget{
  @override
  MealState createState() => MealState();
}

class MealState extends State<MealScreen>{
  String KEY = "376c66873c3845a485f42bc79baa29ce";
  String school_code = "7240273";
  String office_code = "D10";
  DateTime dateValue = DateTime.now();

  String? mealData = '!오류!\n<이유>\n1. 아침에 가끔 안뜸\n2. 급식 정보가 없음\n3. 네트워크 연결이 안됨\n4. apiKEY오류\n5. 다른오류같으면 제보좀';
  String? checkDate = 'yyyyMMDD';
  String? checkSchoolName = 'OO학교';

  Future datePicker() async{
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(2022),
      lastDate: new DateTime(3000),
    );

    if(picked != null) {
      String url = "https://open.neis.go.kr/hub/mealServiceDietInfo?Type=json&KEY=$KEY&pIndex=1&pSize=100&ATPT_OFCDC_SC_CODE=$office_code&SD_SCHUL_CODE=$school_code&MLSV_YMD=${DateFormat('yyyyMMdd').format(picked)}";
      //String exurl = "https://open.neis.go.kr/hub/mealServiceDietInfo?Type=json&KEY=$KEY&pIndex=1&pSize=100&ATPT_OFCDC_SC_CODE=$office_code&SD_SCHUL_CODE=$school_code&MLSV_YMD=20220413";
      http.Response response = await http.get(
        Uri.parse(url),
      );
      checkDate = jsonDecode(response.body)['mealServiceDietInfo'][1]['row'][0]['MLSV_YMD'];
      checkSchoolName = jsonDecode(response.body)['mealServiceDietInfo'][1]['row'][0]['SCHUL_NM'];
      mealData = jsonDecode(response.body)['mealServiceDietInfo'][1]['row'][0]['DDISH_NM'];
      mealData = mealData?.replaceAll(RegExp(r"[(0-9*.*?)]"), '').replaceAll('<br/>','\n');
      setState(() {
        dateValue=picked;
        //mealData = getMeal(DateFormat('yyyyMMdd').format(dateValue));
        //print((jsonDecode(await getMeal(DateFormat('yyyyMMdd').format(dateValue)))['mealServiceDietInfo'][1]['row'][0]['DDISH_NM']).replaceAll('<br/>','\n'));
      });
    }
  }

  Future reFresh() async{
    setState(() {
      mealData = mealData;
    });
  }

  Future goReport() async{
    final Uri reportUrl = Uri.parse('https://instagram.com/kr.suy?igshid=ZDdkNTZiNTM=');
    if(await canLaunchUrl(reportUrl)){
      launchUrl(reportUrl);
      print('링크이동 성공');
    }else{
      print('링크이동실패');
    }
  }

  showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.pink[50],
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  // getMeal(String date) {
  //   String url = "https://open.neis.go.kr/hub/mealServiceDietInfo?Type=json&KEY=$KEY&pIndex=1&pSize=100&ATPT_OFCDC_SC_CODE=$office_code&SD_SCHUL_CODE=$school_code&MLSV_YMD=$date";
  //   String exurl = "https://open.neis.go.kr/hub/mealServiceDietInfo?Type=json&KEY=$KEY&pIndex=1&pSize=100&ATPT_OFCDC_SC_CODE=$office_code&SD_SCHUL_CODE=$school_code&MLSV_YMD=20220413";
  //   http.Response response = http.get(
  //     Uri.parse(url),
  //   ) as http.Response;
  //   mealData = response.body;
  // }

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 15),
              child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.pink[50],
                      textStyle: TextStyle(
                          fontSize: 25
                      )
                  ),
                  onPressed:datePicker,
                  icon: Icon(
                      Icons.set_meal
                  ),
                  label: Text('${DateFormat('yyyy년 M월 d일').format(dateValue)}')
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Text('$checkDate-$checkSchoolName'),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue[50],
              ),
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.all(10),
              child: Text(
                '$mealData',
                style: TextStyle(
                    fontSize: 30
                ),
              ),
            ),
            Container(
              child: IconButton(onPressed: reFresh, icon: Icon(Icons.refresh)),
            ),
            Container(

              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(15),
                    child:OutlinedButton.icon(onPressed: goReport, icon: Icon(Icons.report), label: Text('오류제보')),
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: OutlinedButton.icon(onPressed: (){showToast('뭐');}, icon: Icon(Icons.remove_red_eye), label: Text('그냥버튼')),
                  ),
                ],
              ),
            )
          ],
        )
    );
  }

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }
}

class PicScreen extends StatefulWidget{
  @override
  PicState createState() => PicState();
}

class PicState extends State<PicScreen>{
  XFile? _image;

  Future getGalleryImage() async{
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future getCameraImage() async{
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        children: [
          Text('아직개발중인패이지\n앱 재시작 후 사진유지를 구현 못함...'),
          ElevatedButton(
            child: Text('gallery'),
            onPressed: getGalleryImage,
          ),
          Center(
            child: _image == null
              ? Text(
              'No Image Selected',
              style: TextStyle(color: Colors.white),
            )
              :CircleAvatar(
              backgroundImage: FileImage(File(_image!.path)),
              radius: 100,
            ),
          ),
          ElevatedButton(
            child: Text('camera'),
            onPressed: getCameraImage,
          )
        ],
      ),
    );
  }
}

class SubScreen extends StatefulWidget{
  @override
  SubState createState() => SubState();
}

class SubState extends State<SubScreen>{
  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Text('여기는 무엇을 넣으면 좋을까\n-수영-v1.0.0-2023.3.1\n문의 인스타 @kr.suy'),
    );
  }
}