import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:open_settings/open_settings.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacc_office/Home/home.dart';

class Login extends StatefulWidget {
   Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool hasinternet = false;
  late SharedPreferences prefs;
  late String unm, pwd;

  final _formKey = GlobalKey<FormState>();
  bool _obscuretext = true;

    @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    if (await isLoggedIn()) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ));
    }
  }

  Future<bool> isLoggedIn() async {
    prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }

  Future<void> saveResponseToSharedPreferences(String responseBody) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('data', responseBody);
  }

  Future<http.Response> login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var url = Uri.parse(
          'http://cloud.spaccsoftware.com/hanan_api/test/alogin.php?unm=$unm&pwd=$pwd');
      final response = await http.get(url);
      return response;
    } else {
      return Future.value(null);
    }
  }

    void _toggle() {
    setState(() {
      _obscuretext = !_obscuretext;
    });
  }

void _saveForm(http.Response response) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', unm);
      await prefs.setString('password', pwd);
      var jsonData = jsonDecode(response.body);
      if (jsonData["response_code"] == 27) {
        var fid = jsonData["data"]["firm_id"];
        await prefs.setString('firm_id', fid);
        var fullname = jsonData["data"]["fullname"];
        await prefs.setString('fullname', fullname);
      }
      await prefs.setBool('isLoggedIn', true);
    }
  }

    void _showdialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Lottie.asset('assets/45721-no-internet.json',
              width: MediaQuery.of(context).size.width*0.1, height: MediaQuery.of(context).size.height*0.1),
          content:
              const Text('Please check your internet connection and try again'),
          actions: [
            MaterialButton(
              onPressed: () {
                OpenSettings.openNetworkOperatorSetting();
              },
              child: const Text('Turn on mobile data'),
            ),
            MaterialButton(
              onPressed: () {
                OpenSettings.openWIFISetting();
              },
              child: const Text('Turn on wifi'),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var mediaquery = MediaQuery.of(context);  
    return Scaffold(

      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding( 
                padding:  EdgeInsets.only(top:mediaquery.size.height*0.1),
                child: Center(
                  child: SizedBox(
                    width: mediaquery.size.width*0.8,
                    child: Image.asset('assets/spacc_logo-1__2__page-0001-removebg-preview.png')),
                ),
              ),
               Padding(
                padding:  EdgeInsets.symmetric(horizontal:mediaquery.size.width*0.1),
                child:  TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter a username';
                    }
                    return null;
                  },
                  onSaved: (value) => unm = value!,
                  decoration: InputDecoration(
                    label: const Text('Username'),
                    border: OutlineInputBorder(
                       borderSide: BorderSide(
                                      color: const Color(0xff000080),
                                      width: mediaquery.size.width*0.01,
                                    ),
                      borderRadius: BorderRadius.circular(20)
                    )
                  ),
                ),
              ),
              SizedBox(height: mediaquery.size.height*0.06,),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: mediaquery.size.width * 0.1),
                child:TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  return null;
                                },
                                onSaved: (value) => pwd = value!,
                                obscureText: _obscuretext,
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscuretext
                                            ? Icons.remove_red_eye_outlined
                                            : Icons.visibility_off,
                                        color: const Color(0xff000080),
                                      ),
                                      onPressed: _toggle,
                                    ),
                                    labelText: 'Password',
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                     color: const Color(0xff000080),
                          width: mediaquery.size.width * 0.01,
                                    ),
                                    borderRadius: BorderRadius.circular(20)
                                    ))),
                          ),
              
              
              SizedBox(
                height: mediaquery.size.height * 0.06,
              ),
              
              SizedBox(width:mediaquery.size.width*0.3,
                child: ElevatedButton(onPressed: () async {
                                hasinternet = await InternetConnectionChecker()
                                    .hasConnection;
        
                                if (hasinternet == false) {
                                  _showdialog();
                                }
        
                                final response = await login();
        
                                if (response.statusCode == 200) {
                                  final responseBody = jsonDecode(response.body);
                                  if (responseBody['response_code'] == 27) {
                                    var fullname =
                                        responseBody["data"]["fullname"];
                                    await prefs.setString('fullname', fullname);
                                    _saveForm(response);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const HomePage(),
                                        ));
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content:
                                          Text(responseBody['response_desc']),
                                    ));
                                  }
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('Login Failed'),
                                  ));
                                }
                              }, child:const Text('Login')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

