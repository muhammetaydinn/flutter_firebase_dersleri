import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class FireStoreIslemleri extends StatefulWidget {
  FireStoreIslemleri({Key? key}) : super(key: key);

  @override
  State<FireStoreIslemleri> createState() => _FireStoreIslemleriState();
}

class _FireStoreIslemleriState extends State<FireStoreIslemleri> {
  StreamSubscription? _userSubs;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    //IDler
    debugPrint(_firestore.collection("users").id);
    debugPrint(_firestore.collection("users").doc().id);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  veriEklemeAdd();
                },
                child: Text("veri ekleme add"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.pink,
                )),
            ElevatedButton(
                onPressed: () {
                  veriEklemeSet();
                },
                child: Text("veri ekleme set"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green,
                )),
            ElevatedButton(
                onPressed: () {
                  veriGuncelleme();
                },
                child: Text("veri guncelleme"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                )),
            ElevatedButton(
                onPressed: () {
                  veriSil();
                },
                child: Text("veri silme"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.yellow,
                )),
            ElevatedButton(
                onPressed: () {
                  verileriOkuOneTime();
                },
                child: Text("verileri oku one time"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                )),
            ElevatedButton(
                onPressed: () {
                  verileriOkuRealTime();
                },
                child: Text("verileri oku real time"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.greenAccent,
                )),
            ElevatedButton(
                onPressed: () {
                  streamDurdur();
                },
                child: Text("stream durdur"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.grey,
                )),
            ElevatedButton(
                onPressed: () {
                  batchKavrami();
                },
                child: Text("Batch go prr"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.brown,
                )),
            ElevatedButton(
                onPressed: () {
                  transactionKavrami();
                },
                child: Text("transaction Kavrami"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                )),
            ElevatedButton(
                onPressed: () {
                  queringData();
                },
                child: Text("queringData"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.cyanAccent,
                )),
            ElevatedButton(
                onPressed: () {
                  kameraGaleriImageUpload();
                },
                child: Text("kameraGaleriImageUpload"),
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple,
                )),
          ],
        ),
      ),
    );
  }

  //ID VATSA SET

  void veriEklemeSet() async {
    //yeni veri ekler yeni kullanıcı
    var _yeniDocID = _firestore.collection("users").doc().id;
    await _firestore.collection("users").doc().id;
    await _firestore
        .doc("users/$_yeniDocID")
        .set({"isim": "haydar", "userID": _yeniDocID});

    // belli kulllanıcının bazı bilgilerini ekler ya da günceller
    await _firestore.doc("users/WOz1gRAdvEvofsdE32Mj").set(
        {"okul": "ege universitesi", "yas": FieldValue.increment(1)},
        SetOptions(merge: true));
  }

  //ID YOKSA ADD
  void veriEklemeAdd() async {
    Map<String, dynamic> _eklenecekUser = <String, dynamic>{};
    _eklenecekUser["isim"] = "emre";
    _eklenecekUser["yas"] = 19;
    _eklenecekUser["ogrenciMi"] = true;
    _eklenecekUser["adres"] = {"il": "ankara", "ilce": "yenimahalle"};
    _eklenecekUser["renkler"] = FieldValue.arrayUnion(["mavi", "yesil"]);
    _eklenecekUser["createdAt"] = FieldValue.serverTimestamp();

    await _firestore.collection("users").add(_eklenecekUser);
  }

  void veriGuncelleme() async {
    //.update de veri yoksa ekler updatete mutlaka documan olmalı olmayan
    //IDler hata verir setta documan yoksa da o idli olustulur
    //"adres.ilce" adresşn dizinin ilce  indexi

    await _firestore.doc("users/WOz1gRAdvEvofsdE32Mj").update({
      "isim": "muhammet",
      "ogrenciMi": false,
      "nereli": "mardin",
      "adres.ilce": "esenler"
    });
  }

  Future<void> veriSil() async {
    /*  //o useri sile
    await _firestore.doc("users/WOz1gRAdvEvofsdE32Mj").delete(); */
    // sadece bir ozelliginisiler
    await _firestore
        .doc("users/WOz1gRAdvEvofsdE32Mj")
        .update({"okul": FieldValue.delete()});
  }

  //BAZEN IDYI VERITABANNINA DA EKLERIZ

  verileriOkuOneTime() async {
    //butun verileri ceker kullanmak sankıncalı
    var _usersDocuments = await _firestore
        .collection("users")
        .get(); //burada okuma yapılır ve  atama yapılır gerisi local olduğundan okuma sayılmasz
    debugPrint(_usersDocuments.size.toString());
    for (var eleman in _usersDocuments.docs) {
      debugPrint("Dokuman id ${eleman.id}");
      Map userMap = eleman.data();
      debugPrint(userMap["isim"]);
    }

    var _emreDoc = await _firestore.doc("users/WOz1gRAdvEvofsdE32Mj").get();
    debugPrint(_emreDoc.data()!["adres"]["ilce"].toString());
  }

  verileriOkuRealTime() async {
    //abonelik olusturuyoz degisen olur olmasz onu iceren tum mapi getirir
    var _userStream = await _firestore.collection("users").snapshots();
    // _userSubs = _userStream.listen((event) {
    //   //bu degisenin degisenin colectionu getirir
    //   event.docChanges.forEach((element) {
    //     debugPrint(element.doc.data().toString());
    //   });
    //   debugPrint("------------------------------------------");

    //   // _userStream.listen((event) {

    //   //docs tum degisenin bulundugu arkadaslarını da geitirir
    //   event.docs.forEach((element) {
    //     debugPrint(element.data().toString());
    //   });

    //   //   });
    //   // });
    // }
    //sadece degisenin bulundugu useri alan kod

    var _userDocStream =
        await _firestore.doc("users/WOz1gRAdvEvofsdE32Mj").snapshots();
    _userSubs = _userDocStream.listen((event) {
      debugPrint(event.data().toString());
    });
  }

  streamDurdur() async {
    await _userSubs?.cancel();
  }

  //toptan ya hep ya hç
  batchKavrami() async {
    WriteBatch _batch = _firestore.batch();
    CollectionReference _counterColRef = _firestore.collection("counter");
    //set ile veri eklenir

    //BIRINCI TUR SIFIRDAN LISTE YAPMA

    /* for (int i = 0; i < 100; i++) {
      var _yeniDoc = _counterColRef.doc();
      _batch.set(_yeniDoc, {"sayac": ++i, "id": _yeniDoc.id});
    }
*/

    // IKINCI TUR VERILERE BIRER OZELIK EKLEME
    /* var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.update(
          element.reference, {"createdAt": FieldValue.serverTimestamp()});
    }); */

    //tum listedekileri siler
    var _counterDocs = await _counterColRef.get();
    _counterDocs.docs.forEach((element) {
      _batch.delete(
        element.reference,
      );
    });
    await _batch.commit();
  }

  //gonderim
  transactionKavrami() {
    _firestore.runTransaction((transaction) async {
      //1.bakiye ogren
      //1 den bakiye dus
      //dustugun bakiyeyi 2.ye ekle
      DocumentReference<Map<String, dynamic>> birinci =
          _firestore.doc("users/TAJDPJr5FUP98K5XgMWS"); //1
      DocumentReference<Map<String, dynamic>> ikinci =
          _firestore.doc("users/c5iOz3LsIWpEGmuVifwg"); //2
      var _birinciSnapshot = (await transaction.get(birinci));
      var _birinciBakiye = _birinciSnapshot.data()!["para"];
      //ussteki ()[]arasında hata obje olarak gormesinden tam tanımı birinici iknciye yapınca geçti
      if (_birinciBakiye > 100) {
        var _birinciYeniBakiye = _birinciSnapshot.data()!["para"] - 100;
        transaction.update(birinci, {"para": _birinciYeniBakiye});
        transaction.update(ikinci, {"para": FieldValue.increment(100)});
      }
    });
  }

  //sorgular
  queringData() async {
    var _userRef = _firestore
        .collection("users")
        .limit(5); //istekleri sağlayan ilk 5 useri alır sadece
    var _sonuc = await _userRef
        .where(
          "yas",
          isLessThanOrEqualTo: 30, /*whereIn:[30:40]*/
        )
        .get();

    //bir dizi icinden arama

    /* var _sonuc = await _userRef
        .where(
          "renkler",
          arrayContains: "kırmızı",
        )
        .get();
        */
    for (var user in _sonuc.docs) {
      debugPrint(user.data().toString());
    }

    //sıralar

    //var _sirala = await _userRef.orderBy("yas", descending: true).get();
    /* for (var user in _sirala.docs) {
      debugPrint(user.data().toString());
    } */

    //metniin "" ile baslayanlarını alır
    /*  var _stringSearch = await _userRef
        .orderBy("email")
        .startAt(["muhammet"]).endAt(["muhammet" + "\uf8ff"]).get();
    for (var user in _stringSearch.docs) {
      debugPrint(user.data().toString());
    } */
  }

  kameraGaleriImageUpload() async {
    final ImagePicker _picker = ImagePicker();
    XFile? _file = await _picker.pickImage(source: ImageSource.gallery);
    var _profileRef = FirebaseStorage.instance.ref("users/profil_resimleri");
    var _task = _profileRef.putFile(File(_file!.path));

    _task.whenComplete(() async {
      var _url = await _profileRef.getDownloadURL();
      _firestore.doc("users/TAJDPJr5FUP98K5XgMWS").set({
        "profile_pic": _url.toString(),
      }, SetOptions(merge: true));
      debugPrint(_url);
    });
  }
}
