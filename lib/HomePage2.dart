import 'dart:async';
import 'dart:convert';
import 'package:email_launcher/email_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
    debugPrint(response.body);
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
        debugPrint('price:$ask1 , p2:$percentage2');
        gm1 = ((double.parse(price) / 31.1035) * 0.999 * 1).toString();
        debugPrint('gm1:$gm1');
        gm1 = calculator(double.parse(gm1), percentage3);
        debugPrint('gm1:$gm1 , p3:$percentage3');
        gm995 = ((double.parse(price) / 31.1035) * 0.995 * 1000).toString();
        debugPrint('gm995:$gm995 , p4:$percentage4');
        gm995 = calculator(double.parse(gm995), percentage4);
        debugPrint('gm995:$gm995 , p4:$percentage4');
        gm9999 = ((double.parse(price) / 31.1035) * 0.9999 * 1000).toString();
        debugPrint('gm9999:$gm9999 , p5:$percentage5');
        gm9999 = calculator(double.parse(gm9999), percentage5);
        debugPrint('gm9999:$gm9999 , p5:$percentage5');
        gmtola = ((double.parse(price) / 31.1035) * 0.999 * 116.64).toString();
        debugPrint('gmtola:$gmtola , p6:$gmtola');
        gmtola = calculator(double.parse(gmtola), percentage6);
        debugPrint('gmtola:$gmtola , p6:$gmtola');
      });
    }
    if (silverResponse.statusCode == 200) {
      setState(() {
        double percentage = rate7 / 100;
        String ask1 =calculator(double.parse(silverData['ask'].toString()), percentage);
        silverAsk = ask1;
        debugPrint('silverPrice:$ask1 , p2:$percentage');
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
        debugPrint('ask:$ask , p2:$percentage2');
        bid = calculator(double.parse(data['bid'].toString()), percentage1);
        debugPrint('bid:$bid , p1:$percentage1');
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

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    const Color address = Colors.white;
    const Color main = Color.fromRGBO(255, 215, 0, 1.0);
    const Color sec = Color.fromRGBO(249, 224, 168, 1.0);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(44, 43, 43, 1.0),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                 image: DecorationImage(
                    image: AssetImage("images/background.jpg"),
                    fit: BoxFit.cover,
                    opacity: 1)),
            height: size.height,
            width: size.width,
            padding: const EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      "MERIT GOLD JEWELLERY TRADING LLC",
                      style: TextStyle(
                          shadows: [
                            Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 4,
                                color: Color.fromRGBO(224, 196, 131, 1.0))
                          ],
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: main),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      ("Office 206, 20th street, Habsi Real Estate Building, Al Daghaya, Gold Souq, Deira, Dubai - UAE")
                          .toUpperCase(),
                      style: const TextStyle(
                          shadows: [
                            Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 4,
                                color: Colors.black12)
                          ],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: address),
                      textAlign: TextAlign.center,
                    ),
                  ),
                   Center(
                    child: Text(
                  ("Al Daghaya, Gold Souq, Deira, Dubai - UAE").toUpperCase(),
                      style: const TextStyle(
                          shadows: [
                            Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 4,
                                color: Colors.black12)
                          ],
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: address),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white),
                        gradient: const LinearGradient(
                            colors: [
                              main,
                              sec,
                            ],
                            tileMode: TileMode.decal,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Bid Price :",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                "$bid USD",
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.white,
                          height: 3,
                          thickness: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Ask Price :",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                "$ask USD",
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white),
                        gradient: const LinearGradient(
                            colors: [
                              main,
                              sec,
                            ],
                            tileMode: TileMode.decal,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "GOLD 1 GM",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                "$gm1 $cur",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.white,
                          height: 3,
                          thickness: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "GOLD 995",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                "$gm995 $cur",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.white,
                          height: 3,
                          thickness: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "GOLD 9999",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                "$gm9999 $cur",
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.white,
                          height: 3,
                          thickness: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "GOLD 10 Tola bar :",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                "$gmtola $cur",
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          color: Colors.white,
                          height: 3,
                          thickness: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "SILVER 1KG :",
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                "$silver1 $cur",
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Contact Us :",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _makePhoneCall("+971555168965");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white),
                                gradient: const LinearGradient(
                                    colors: [
                                      main,
                                      sec,
                                    ],
                                    tileMode: TileMode.decal,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight)),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: const [
                                Icon(Icons.phone),
                                SizedBox(
                                  height: 4,
                                ),
                                Text("Phone")
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 11,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _launchEmail("MERITGOLDJEWELLERYDUBAI@gmail.com");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white),
                                gradient: const LinearGradient(
                                    colors: [
                                      main,
                                      sec,
                                    ],
                                    tileMode: TileMode.decal,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight)),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: const [
                                Icon(Icons.email),
                                SizedBox(
                                  height: 4,
                                ),
                                Text("Email")
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
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
