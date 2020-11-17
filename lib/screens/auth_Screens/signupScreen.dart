import 'dart:io';

import 'package:energia_app/components/constants.dart';
import 'package:path/path.dart' as p;
import 'package:energia_app/components/fadeAnimation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'loginScreen.dart';
import 'verificationScreen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscureText = true;
  String fname, lname, phone, phoneAsEmail, email, password;
  bool fnameValid,
      lnameValid,
      phoneValid = true,
      emailValid = true,
      passwordValid = true;
  String imageUrl;
  File _image;
  DatabaseReference ref = FirebaseDatabase.instance.reference().child('users');

  void obscureFuncton() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  setUser() {
    ref.child(phone).set({
      'first_name': fname,
      'last_name': lname,
      'email': email,
      'password': password,
      'phone': phone,
      'image_url': imageUrl
    });
  }

  void pickImage(context, String n) async {
    try {
      final image = await ImagePicker().getImage(source: ImageSource.gallery);
      if (image == null) {
        return;
      }
      setState(() {
        if (image.path != null) {
          _image = File(image.path);
          print('path : ${image.path}');
        }
      });
    } catch (ex) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(ex.message),
        ),
      );
    }
    uploadImage(context, n);
  }

  void uploadImage(context, String n) async {
    try {
      FirebaseStorage storage =
          FirebaseStorage(storageBucket: 'gs://sphinx-a2784.appspot.com/');
      StorageReference ref = storage.ref().child(p.basename('$n.jpg'));
      StorageUploadTask storageUploadTask = ref.putFile(_image);

      StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;

      /*  Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('success'),
      )); */
      String url = await taskSnapshot.ref.getDownloadURL();
      print('url $url');
      setState(() {
        imageUrl = url;
      });

      Toast.show('photo selected', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
    } catch (ex) {
      Toast.show(ex.message, context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          color: kdarkBlue,
          child: ListView(
            children: [
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.language,
                        color: kWhiteColor,
                        size: 25,
                      ),
                      onPressed: () {},
                    ),
                    Text(
                      'العربية  ',
                      style: Theme.of(context)
                          .textTheme
                          .button
                          .copyWith(color: kWhiteColor),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeAnimation(
                    1,
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/logo.png'),
                      radius: 20,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Energia Powered'.toUpperCase(),
                      textAlign: TextAlign.start,
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: 18, color: kWhiteColor),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 30.0, bottom: 20, top: 15, left: 30),
                    child: Text(
                      'Create Account'.toUpperCase(),
                      style: Theme.of(context).textTheme.headline4.copyWith(
                          color: kWhiteColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        imageUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(imageUrl),
                                radius: 75,
                              )
                            : Icon(Icons.account_box,
                                size: 150, color: kgreybackground),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: IconButton(
                                icon: Icon(
                                  Icons.add_a_photo,
                                  color: const Color(0xFF03144c),
                                ),
                                onPressed: () {
                                  pickImage(context, phone);
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: size.width * 0.5,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: new BoxDecoration(
                            color: kgreybackground,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(30))),
                        child: TextField(
                          onChanged: (value) {
                            if (value.length < 2) {
                              setState(() {
                                fnameValid = false;
                                fname = null;
                              });
                            } else {
                              setState(() {
                                fnameValid = true;
                                fname = value;
                              });
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: 'First Name',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: kdarkBlue,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: kWhiteColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: size.width * 0.5,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: new BoxDecoration(
                            color: kgreybackground,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(30))),
                        child: TextField(
                          onChanged: (value) {
                            if (value.length < 2) {
                              setState(() {
                                lnameValid = false;
                                lname = null;
                              });
                            } else {
                              setState(() {
                                lnameValid = true;
                                lname = value;
                              });
                            }
                          },
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.start,
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(fontSize: 18),
                          decoration: InputDecoration(
                            hintText: 'Last Name',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: kdarkBlue,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: kWhiteColor),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              // Phone Number ////////////////////////////
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                decoration: new BoxDecoration(
                    color: kgreybackground,
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(30))),
                child: TextFormField(
                  onChanged: (value) {
                    if (value.length != 11) {
                      setState(() {
                        phoneValid = false;
                        phone = null;
                      });
                    } else {
                      setState(() {
                        phoneValid = true;
                        phone = value;
                        phoneAsEmail = '+2$value@energia.com';
                      });
                    }
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(11),
                  ],
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Mobile Number',
                    prefixIcon: Icon(
                      Icons.phone_android,
                      color: kdarkBlue,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: kWhiteColor),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                ),
              ),
              // Email ////////////////////////////////////
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                decoration: new BoxDecoration(
                    color: kgreybackground,
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(30))),
                child: TextField(
                  onChanged: (value) {
                    if (value.length < 2) {
                      setState(() {
                        emailValid = false;
                        email = null;
                      });
                    } else {
                      setState(() {
                        emailValid = true;
                        email = value;
                      });
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(
                      Icons.email,
                      color: kdarkBlue,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: kWhiteColor),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                ),
              ),
              // Password /////////////////////////////
              Container(
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                decoration: new BoxDecoration(
                    color: kgreybackground,
                    borderRadius:
                        new BorderRadius.all(new Radius.circular(30))),
                child: TextFormField(
                  onChanged: (value) {
                    if (value.length < 8) {
                      setState(() {
                        passwordValid = false;
                        password = null;
                      });
                    } else {
                      setState(() {
                        passwordValid = true;
                        password = value;
                      });
                    }
                  },
                  keyboardType: TextInputType.visiblePassword,
                  textAlign: TextAlign.start,
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: Icon(
                      Icons.vpn_key,
                      color: kdarkBlue,
                    ),
                    suffixIcon: IconButton(
                        icon: Icon(
                          Icons.remove_red_eye,
                          color: _obscureText == false ? kdarkBlue : kgrey,
                        ),
                        onPressed: () => obscureFuncton()),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: kWhiteColor),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                  ),
                  obscureText: _obscureText,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Container(
                  width: size.width * 0.55,
                  child: RaisedButton(
                    hoverColor: kgrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(29),
                        side: BorderSide(color: Colors.grey)),
                    color: kWhiteColor,
                    onPressed: () async {
                      /*  FocusScope.of(context).requestFocus(FocusNode());
                        print('phone:$phone , password:$password');
                        if (phone != null && password != null) {
          try {
            var result = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: phoneAsEmail, password: password);
            if (result != null) {
              setUser();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            } else {
              Toast.show("This number isn't exist", context,
                  duration: Toast.LENGTH_SHORT,
                  gravity: Toast.TOP);
            }
          } on FirebaseAuthException catch (e) {
            if (e.code == 'weak-password') {
              print('The password provided is too weak.');
            } else if (e.code == 'email-already-in-use') {
              print(
                  'The account already exists for that email.' +
                      '3333333333333333');
            }
          } catch (e) {
            print(e + 'dddddddddddddddddd');
          }
                        } else if (phone == null && password != null) {
          setState(() {
            phoneValid = false;
          });
                        } else if (phone != null && password == null) {
          setState(() {
            passwordValid = false;
          });
                        } else {
          setState(() {
            phoneValid = false;
            passwordValid = false;
          });
                        } */

                      FocusScope.of(context).requestFocus(FocusNode());
                      print('phone:$phone , password:$password');
                      if (phone != null && password != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VerificationScreen(
                              email: email,
                              fname: fname,
                              imageUrl: imageUrl,
                              lname: lname,
                              password: password,
                              phone: phone,
                            ),
                          ),
                        );
                      } else if (phone == null && password != null) {
                        setState(() {
                          phoneValid = false;
                        });
                      } else if (phone != null && password == null) {
                        setState(() {
                          passwordValid = false;
                        });
                      } else {
                        setState(() {
                          phoneValid = false;
                          passwordValid = false;
                        });
                      }
                    },
                    child: Text(
                      'Register',
                      style: Theme.of(context).textTheme.headline6.copyWith(
                          color: kdarkBlue, fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.all(20),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "You already have an account?",
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontSize: 18, color: kgrey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 5),
                          child: Text(
                            'Sign In',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: kWhiteColor),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}