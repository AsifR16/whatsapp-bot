import 'dart:async';
import 'dart:convert';
import 'package:email_launcher/email_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:flutter_launch/flutter_launch.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String price = "";
  String silverAsk = "";
  String ask = "";
  String bid = "";
  String gm1 = "";
  String gm995 = "";
  String gm9999 = "";
  String gmtola = "";
  String silver1 = "";
  String cur = "AED";
  String apikey = "";
  double rate1 = 1;
  double rate2 = 1;
  double rate3 = 1;
  double rate4 = 1;
  double rate5 = 1;
  double rate6 = 1;
  double rate7 = 1;
  bool _usd = true;
  bool _loading = false;

  Future getRate() async {
    setState(() {
      _loading = true;
    });
    String url = 'https://merit.odmc.info/public/api/getrate';
    final response = await http.get(Uri.parse(url));
    // debugPrint(response.body);
    Map data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        rate1 = double.tryParse(data['msg']['rate1'].toString()) ?? 1.0;
        rate2 = double.tryParse(data['msg']['rate2'].toString()) ?? 1.0;
        rate3 = double.tryParse(data['msg']['rate3'].toString()) ?? 1.0;
        rate4 = double.tryParse(data['msg']['rate4'].toString()) ?? 1.0;
        rate5 = double.tryParse(data['msg']['rate5'].toString()) ?? 1.0;
        rate6 = double.tryParse(data['msg']['rate6'].toString()) ?? 1.0;
        rate7 = double.tryParse(data['msg']['rate7'].toString()) ?? 1.0;
        getGoldRates();
      });
    }
  }

  Future getApi() async {
    setState(() {
      _loading = true;
    });
    String url = 'https://merit.odmc.info/public/api/getapikey';
    final response = await http.get(Uri.parse(url));
    // print(response.statusCode);
    Map data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        apikey = data['msg'];
        getRate();
      });
    }
  }

  Future getGoldRates() async {
    setState(() {
      _loading = true;
    });
    getGoldRatesUSD();
    String url = 'https://www.goldapi.io/api/XAU/$cur';
    String silverURL = 'https://www.goldapi.io/api/XAG/$cur';
    final response = await http.get(Uri.parse(url), headers: {'x-access-token': '$apikey'});
    final silverResponse = await http.get(Uri.parse(silverURL), headers: {'x-access-token': '$apikey'});
    Map data = jsonDecode(response.body);
    Map silverData = jsonDecode(silverResponse.body);
    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      setState(() {
        double percentage1 = rate1 / 100;
        double percentage2 = rate2 / 100;
        double percentage3 = rate3 / 100;
        double percentage4 = rate4 / 100;
        double percentage5 = rate5 / 100;
        double percentage6 = rate6 / 100;
        /* double ak = double.parse(data['ask'].toString());
       ak = ak + (ak * percentage);*/
        String ask1 =
            calculator(double.parse(data['ask'].toString()), percentage2);
        price = ask1;
        // debugPrint('price:$ask1 , p2:$percentage2');
        gm1 = ((double.parse(price) / 31.1035) * 0.999 * 1).toString();
        // debugPrint('gm1:$gm1');
        gm1 = calculator(double.parse(gm1), percentage3);
        // debugPrint('gm1:$gm1 , p3:$percentage3');
        gm995 = ((double.parse(price) / 31.1035) * 0.995 * 1000).toString();
        // debugPrint('gm995:$gm995 , p4:$percentage4');
        gm995 = calculator(double.parse(gm995), percentage4);
        // debugPrint('gm995:$gm995 , p4:$percentage4');
        gm9999 = ((double.parse(price) / 31.1035) * 0.9999 * 1000).toString();
        // debugPrint('gm9999:$gm9999 , p5:$percentage5');
        gm9999 = calculator(double.parse(gm9999), percentage5);
        // debugPrint('gm9999:$gm9999 , p5:$percentage5');
        gmtola = ((double.parse(price) / 31.1035) * 0.999 * 116.64).toString();
        // debugPrint('gmtola:$gmtola , p6:$gmtola');
        gmtola = calculator(double.parse(gmtola), percentage6);
        // debugPrint('gmtola:$gmtola , p6:$gmtola');
      });
    }
    if (silverResponse.statusCode == 200) {
      setState(() {
        double percentage = rate7 / 100;
        String ask1 =calculator(double.parse(silverData['ask'].toString()), percentage);
        silverAsk = ask1;
        // debugPrint('silverPrice:$ask1 , p2:$percentage');
        silver1 = ((double.parse(silverAsk) / 31.1035) * 1000).toStringAsFixed(2);
      });
    }
  }

  Future getGoldRatesUSD() async {
    setState(() {
      _loading = true;
    });
    String url = 'https://www.goldapi.io/api/XAU/USD';
    final response =
        await http.get(Uri.parse(url), headers: {'x-access-token': '$apikey'});
    Map data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setState(() {
        _loading = false;
      });
      setState(() {
        double percentage1 = rate1 / 100;
        double percentage2 = rate2 / 100;
        // print(double.parse(data['ask'].toString()));
        ask = calculator(double.parse(data['ask'].toString()), percentage2);
        // debugPrint('ask:$ask , p2:$percentage2');
        bid = calculator(double.parse(data['bid'].toString()), percentage1);
        // debugPrint('bid:$bid , p1:$percentage1');
      });
    }
    setState(() {
      _loading = false;
    });
  }

  calculator(double price, double percentage) {
    double ak = price;
    ak = ak + (ak * percentage);
    return ak.toStringAsPrecision(7);
  }

  @override
  int i = 0;
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timer = Timer.periodic(const Duration(seconds:2), (Timer t) {
      getApi();
    });
  }
   void showMemberMenu() async {
    double height = MediaQuery.of(context).size.height;
    double width2 = MediaQuery.of(context).size.width;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(0, height-270, 0, 0),
      items: [
        PopupMenuItem(
          value: 1,
          child: Row(
                  children: [
                    Icon(
                     CupertinoIcons.money_dollar,
                        ),
                    TextButton(
                      child: Text("Banking Details",style:TextStyle(color:Colors.black)),
                      onPressed: () => {Navigator.of(context).push(MaterialPageRoute(builder: (context) => Banking()))},
                              ),
                            ]
                        )
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
                  children: [
                    Icon(
                     CupertinoIcons.phone,
                        ),
                    TextButton(
                      child: Text("Booking Desk",style:TextStyle(color:Colors.black)),
                      onPressed: () => {Navigator.of(context).push(MaterialPageRoute(builder: (context) => Booking()))},
                              ),
                            ]
                        )
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
                  children: [
                    Icon(
                     Icons.people,
                        ),
                    TextButton(
                      child: Text("About Us",style:TextStyle(color:Colors.black)),
                      onPressed: () => {Navigator.of(context).push(MaterialPageRoute(builder: (context) => AboutUs()))},
                              ),
                            ]
                        )
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
                  children: [
                    Icon(
                     Icons.shopping_cart,
                        ),
                    TextButton(
                      child: Text("Products",style:TextStyle(color:Colors.black)),
                      onPressed: () => {Navigator.of(context).push(MaterialPageRoute(builder: (context) => Products()))},
                              ),
                            ]
                        )
        )
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) print(value);
    });
  }
  @override
  Widget build(BuildContext context) {
    var sizeScreen = MediaQuery.of(context).size;
    const Color address = Colors.white;
    const Color main = Color.fromRGBO(255, 215, 0, 1.0);
    const Color sec = Color.fromRGBO(249, 224, 168, 1.0);
    return Scaffold(
      bottomNavigationBar: Container(
        height:60,
        decoration: BoxDecoration(
          color:Color(0xFF7b0f1b)
          ),
        child:Row(
          mainAxisAlignment:MainAxisAlignment.spaceAround,
          children:[
          IconButton(
            enableFeedback:false,
            onPressed:(){
              showMemberMenu();
              },
            icon:const Icon(
              Icons.menu,
              color:Color(0xFFb2874a),
              size:40
              )
            ),
            IconButton(
            enableFeedback:false,
            onPressed:(){},
            icon:const Icon(
              CupertinoIcons.chart_bar,
              color:Colors.white,
              size:35
              )
            ),
            IconButton(
            enableFeedback:false,
            onPressed:(){
              launchWhatsAppUri();
              },
            icon: Image.asset(
              'images/whatsapp.png',
              height:40,
              fit:BoxFit.cover
              )
            ),
            IconButton(
            enableFeedback:false,
            onPressed:(){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Booking()));
              },
            icon:const Icon(
              Icons.call,
              color:Colors.white,
              size:35
              )
            ),
            IconButton(
            enableFeedback:false,
            onPressed:(){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Banking()));
              },
            icon:const Icon(
              CupertinoIcons.money_dollar,
              color:Colors.white,
              size:35
              )
            ),
          ]
          )
        ),
      backgroundColor: const Color.fromRGBO(44, 43, 43, 1.0),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                 image: DecorationImage(
                    image: AssetImage("images/background.jpg"),
                    fit: BoxFit.cover,
                    opacity: 1)),
            height: sizeScreen.height,
            width: sizeScreen.width,
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                    Center(
                    child: Image.asset('images/logo.png',
                      height:200,
                      width:200
                      )
                  ),
                    Container(child:Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children:[Text("Live Rates",style:TextStyle(fontSize:14,color:Colors.white,fontWeight:FontWeight.w600)),TextButton(
                      child: Text("Products",style:TextStyle(fontSize:14,color:Colors.white,fontWeight:FontWeight.w600)),
                      onPressed: () => {Navigator.of(context).push(MaterialPageRoute(builder: (context) => Products()))},
                              )])),
                    Center(
                      child:Column(
                        children:<Widget>[
                        Container(
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(borderRadius:BorderRadius.circular(15),
                            boxShadow: [
                                    BoxShadow(color: Color(0xFFb2874a), spreadRadius: 5,blurRadius:1,offset:const Offset(0,1)),
                                    ]
                            ),
                          child:Table(
                            border: TableBorder.symmetric(outside:BorderSide.none,inside: const BorderSide(width: 1, color: Colors.white, style: BorderStyle.solid)),
                            columnWidths: {0: FractionColumnWidth(.3), 1: FractionColumnWidth(.3), 2: FractionColumnWidth(.3)},
                              children: [
                              TableRow(decoration: BoxDecoration(
                                    color: Color(0xFFb2874a))
                                ,children:[Padding(padding:EdgeInsets.all(10),child:Text("Spot Rate",style:TextStyle(fontSize:14,color:Colors.white,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("BID (\$\)",style:TextStyle(fontSize:14,color:Colors.white,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("ASK (\$\)",style:TextStyle(fontSize:14,color:Colors.white,fontWeight:FontWeight.w600)))]),
                              TableRow(decoration: BoxDecoration(
                                    color: Color(0xFFb2874a))
                                ,children:[Padding(padding:EdgeInsets.all(10),child:Text("Gold Oz",style:TextStyle(fontSize:14,color:Colors.white,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("$bid",style:TextStyle(fontSize:14,color:Colors.white,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("$ask",style:TextStyle(fontSize:14,color:Colors.white,fontWeight:FontWeight.w600)))])
                              ]
                            )
                          )
                        ]
                        )
                      ),
                    const SizedBox(
                    height: 30,
                  ),
                    Center(
                      child:Column(
                        children:<Widget>[
                        Container(
                          margin:EdgeInsets.all(10),
                          decoration:BoxDecoration(borderRadius:BorderRadius.circular(15),
                            boxShadow:[
                              BoxShadow(color: Colors.white, spreadRadius: 5,blurRadius:1,offset:const Offset(0,1))
                            ]
                            ),
                          child:Table(
                            border:TableBorder.symmetric(outside:BorderSide.none,inside: const BorderSide(width:1,color:Colors.black,style:BorderStyle.solid)),
                            columnWidths: {0: FractionColumnWidth(.4), 1: FractionColumnWidth(.2), 2: FractionColumnWidth(.3)},
                            children:[TableRow(decoration:BoxDecoration(color:Colors.white),
                              children:[Padding(padding:EdgeInsets.all(10),child:Text("GOLD 1 GM",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("AED",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("$gm1",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600)))]
                              )]
                            )
                          ),
                        Container(
                          margin:EdgeInsets.all(10),
                          decoration:BoxDecoration(borderRadius:BorderRadius.circular(15),
                            boxShadow:[
                              BoxShadow(color: Colors.white, spreadRadius: 5,blurRadius:1,offset:const Offset(0,1))
                            ]
                            ),
                          child:Table(
                            border:TableBorder.symmetric(outside:BorderSide.none,inside: const BorderSide(width:1,color:Colors.black,style:BorderStyle.solid)),
                            columnWidths: {0: FractionColumnWidth(.4), 1: FractionColumnWidth(.2), 2: FractionColumnWidth(.3)},
                            children:[TableRow(decoration:BoxDecoration(color:Colors.white),
                              children:[Padding(padding:EdgeInsets.all(10),child:Text("Gold 995",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("AED",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("$gm995",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600)))]
                              )]
                            )
                          ),
                        Container(
                          margin:EdgeInsets.all(10),
                          decoration:BoxDecoration(borderRadius:BorderRadius.circular(15),
                            boxShadow:[
                              BoxShadow(color: Colors.white, spreadRadius: 5,blurRadius:1,offset:const Offset(0,1))
                            ]
                            ),
                          child:Table(
                            border:TableBorder.symmetric(outside:BorderSide.none,inside: const BorderSide(width:1,color:Colors.black,style:BorderStyle.solid)),
                            columnWidths: {0: FractionColumnWidth(.4), 1: FractionColumnWidth(.2), 2: FractionColumnWidth(.3)},
                            children:[TableRow(decoration:BoxDecoration(color:Colors.white),
                              children:[Padding(padding:EdgeInsets.all(10),child:Text("Gold 9999",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("AED",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("$gm9999",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600)))]
                              )]
                            )
                          ),
                        Container(
                          margin:EdgeInsets.all(10),
                          decoration:BoxDecoration(borderRadius:BorderRadius.circular(15),
                            boxShadow:[
                              BoxShadow(color: Colors.white, spreadRadius: 5,blurRadius:1,offset:const Offset(0,1))
                            ]
                            ),
                          child:Table(
                            border:TableBorder.symmetric(outside:BorderSide.none,inside: const BorderSide(width:1,color:Colors.black,style:BorderStyle.solid)),
                            columnWidths: {0: FractionColumnWidth(.4), 1: FractionColumnWidth(.2), 2: FractionColumnWidth(.3)},
                            children:[TableRow(decoration:BoxDecoration(color:Colors.white),
                              children:[Padding(padding:EdgeInsets.all(10),child:Text("GOLD 10 Tola bar",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("AED",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("$gmtola",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600)))]
                              )]
                            )
                          ),
                        Container(
                          margin:EdgeInsets.all(10),
                          decoration:BoxDecoration(borderRadius:BorderRadius.circular(15),
                            boxShadow:[
                              BoxShadow(color: Colors.white, spreadRadius: 5,blurRadius:1,offset:const Offset(0,1))
                            ]
                            ),
                          child:Table(
                            border:TableBorder.symmetric(outside:BorderSide.none,inside: const BorderSide(width:1,color:Colors.black,style:BorderStyle.solid)),
                            columnWidths: {0: FractionColumnWidth(.4), 1: FractionColumnWidth(.2), 2: FractionColumnWidth(.3)},
                            children:[TableRow(decoration:BoxDecoration(color:Colors.white),
                              children:[Padding(padding:EdgeInsets.all(10),child:Text("SILVER 1kg",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("AED",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600))),Padding(padding:EdgeInsets.all(10),child:Text("$silver1",style:TextStyle(fontSize:14,color:Colors.black,fontWeight:FontWeight.w600)))]
                              )]
                            )
                          )
                        ]
                        )
                      )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void launchWhatsAppUri() async {
    await FlutterLaunch.launchWhatsapp(phone: "971555168965", message: "Hello");
}

  void _launchEmail(String too) async {
    List<String> to = too.split(',');
    String subject = "";
    String body = "";

    Email email = Email(to: to, subject: subject, body: body);
    EmailLauncher.launch(email).then((value) {
      // success
      // print(value);
    }).catchError((error) {
      // has error
      // print(error);
    });
  }
}

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var sizeScreen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(44, 43, 43, 1.0),
      body:Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                 image: DecorationImage(
                    image: AssetImage("images/background.jpg"),
                    fit: BoxFit.cover,
                    opacity: 1)),
            height: sizeScreen.height,
            width: sizeScreen.width,
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                    Center(
                    child: Image.asset('images/logo.png',
                      height:200,
                      width:200
                      )
                    ),
                    Center(child:Text("About Us",style:TextStyle(color:Color(0xFFb2874a),fontSize:40))),
                    const SizedBox(
                    height: 50,
                    ),
                    Center(child:Text("MERIT GOLD JEWELLERY is a trusted name in the industry for the past many years.The team has been diligently trained in the art of identifying, testing and analyzing precious metals and gemstones. A highly reliable service provider of accurate evaluation and substantial payment for your selling or exchanging gold & silver scraps in Dubai. MERIT also offers quality gold and silver kilo bars, tola bars, coins and bullion bars. Meeting the increasing demand of regional and international markets, MERIT well supplies the finest precious metals to our clients with very friendly personal assistance and Easy, trustworthy and hassle free processing steps sets MERIT GOLD a cut above the rest.",
                      textAlign: TextAlign.center,
                      style:TextStyle(color:Colors.white,fontWeight:FontWeight.w500)
                      )
                      ),
                    ]
                    )
              )
            )
          ]
          )
      );
  }
}

class Products extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var sizeScreen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(44, 43, 43, 1.0),
      body:Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                 image: DecorationImage(
                    image: AssetImage("images/background.jpg"),
                    fit: BoxFit.cover,
                    opacity: 1)),
            height: sizeScreen.height,
            width: sizeScreen.width,
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                    Center(
                    child: Image.asset('images/logo.png',
                      height:200,
                      width:200
                      )
                    ),
                    Center(child:Image.asset('images/products.jpeg'))
                    ]
                    )
              )
            )
          ]
          )
      );
  }
}

class Booking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var sizeScreen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(44, 43, 43, 1.0),
      body:Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                 image: DecorationImage(
                    image: AssetImage("images/background.jpg"),
                    fit: BoxFit.cover,
                    opacity: 1)),
            height: sizeScreen.height,
            width: sizeScreen.width,
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                    Center(
                    child: Image.asset('images/logo.png',
                      height:200,
                      width:200
                      )
                    ),
                    Center(child:Text("BOOKING DESK",style:TextStyle(color:Color(0xFFb2874a),fontSize:25,fontWeight:FontWeight.w600))),
                    const SizedBox(
                    height: 30,
                    ),
                    Center(
                      child: Column(
                        crossAxisAlignment:CrossAxisAlignment.center,
                        children:[
                          Row(
                              children:[
                                Container(
                                  margin: EdgeInsets.all(20),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(width: 1, color: Color(0xFFb2874a))),
                                  child: Icon(
                                      CupertinoIcons.home,
                                      color: Color(0xFFb2874a),
                                              ),
                                        ),
                                const SizedBox(
                                      width: 20,
                                ),
                                Expanded(child:Text("MERIT GOLD JEWELLERY TRADING LLC Office 206, 20th street, Habsi Real Estate Building Al Daghaya, Gold Souq, Deira, Dubai - UAE",style:TextStyle(color:Colors.white)))
                              ]
                            ),
                          Row(
                              children:[
                                Container(
                                  margin: EdgeInsets.all(20),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(width: 1, color: Color(0xFFb2874a))),
                                  child: Icon(
                                      Icons.phone,
                                      color: Color(0xFFb2874a),
                                              ),
                                        ),
                                const SizedBox(
                                      width: 20,
                                ),
                                Expanded(child:Text("+971 55 516 8965",style:TextStyle(color:Colors.white)))
                              ]
                            ),
                          Row(
                              children:[
                                Container(
                                  margin: EdgeInsets.all(20),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(width: 1, color: Color(0xFFb2874a))),
                                  child: Icon(
                                      Icons.email,
                                      color: Color(0xFFb2874a),
                                              ),
                                        ),
                                const SizedBox(
                                      width: 20,
                                ),
                                Expanded(child:Text("MERITGOLDJEWELLERYDUBAI@gmail.com",style:TextStyle(color:Colors.white,fontSize:14)))
                              ]
                            )
                        ]
                        )
                      )
                    ]
                    )
              )
            )
          ]
          )
      );
  }
}

class Banking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var sizeScreen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(44, 43, 43, 1.0),
      body:Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                 image: DecorationImage(
                    image: AssetImage("images/background.jpg"),
                    fit: BoxFit.cover,
                    opacity: 1)),
            height: sizeScreen.height,
            width: sizeScreen.width,
            padding: const EdgeInsets.only(top: 0, bottom: 0, left: 10, right: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                    Center(
                    child: Image.asset('images/logo.png',
                      height:200,
                      width:200
                      )
                    ),
                    Center(child:Text("BANKING DETAILS",style:TextStyle(color:Color(0xFFb2874a),fontSize:25,fontWeight:FontWeight.w600))),
                    const SizedBox(
                                      height:50,
                                ),
                    Center(child:Column(
                      crossAxisAlignment:CrossAxisAlignment.center,
                      children:[
                      Text("Merit gold jewellery trading llc",style:TextStyle(color:Colors.white,fontSize:20)),
                      const SizedBox(height:20),
                      Text("A/C: 3708431394501",style:TextStyle(color:Colors.white,fontSize:20)),
                      const SizedBox(height:20),
                      Text("Emirates Islamic Bank",style:TextStyle(color:Colors.white,fontSize:20))
                      ]
                      ))
                    ]
                    )
              )
            )
          ]
          )
      );
  }
}
