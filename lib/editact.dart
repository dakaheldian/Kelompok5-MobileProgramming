import 'dart:io';

import 'package:flutter/material.dart';
import 'package:klp5_mp/API/connect.dart';
import 'package:klp5_mp/board.dart';
import 'package:klp5_mp/main.dart';
import 'package:klp5_mp/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class EditActPage extends StatefulWidget {
  const EditActPage({
    Key? key,
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  }) : super(key: key);

  final String id;
  final String title;
  final String description;
  final String image;
  @override
  _EditActPageState createState() => _EditActPageState();
}

class _EditActPageState extends State<EditActPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? image;
  // ignore: non_constant_identifier_names

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Edit",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              editNotes();
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              deleteData(widget.id);
            },
          ),
        ],
      ),
      drawer: SideBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.blue[200]),
              child: TextField(
                controller: titleController..text = widget.title,
                decoration: InputDecoration(border: InputBorder.none),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.blue[200]),
                child: TextField(
                  controller: descriptionController..text = widget.description,
                  maxLines: 4,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 190,
              decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(
                      image ??
                          File(ApiConnect.hostConnect +
                              "/assets" +
                              widget.image.toString()),
                    ),
                  )),
            ),
            ElevatedButton(
              onPressed: () {
                _potoBottomSheet();
              },
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue)),
              child: Text(
                'Tambah Foto',
                style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addAct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');
    // String date = DateTime.now().toString();
    print("$userId Ini Session");
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConnect.addact),
      );

      request.fields.addAll({
        "user_id": userId.toString(),
        "title": titleController.text,
        "description": descriptionController.text,
      });

      if (image != null) {
        // Menambahkan gambar ke dalam permintaan multipart
        request.files.add(http.MultipartFile(
          'image',
          http.ByteStream(image!.openRead().cast()),
          await image!.length(),
          filename: titleController.text + '_board_image.jpg',
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print(responseBody);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BoardsPage()),
        );
      } else {
        // Handle response status code other than 200
        print("HTTP request failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("Error during registration: $e");
    }
  }

  Future<void> getImageGalerry() async {
    var galleryPermission = Permission.storage;

    if (galleryPermission.status == PermissionStatus.denied) {
      galleryPermission.request();
      if (galleryPermission.status == PermissionStatus.permanentlyDenied) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(""))
          ]),
        );
      }
    }

    final ImagePicker picker = ImagePicker();
    final imagePicked = await picker.pickImage(source: ImageSource.gallery);
    image = File(imagePicked?.path ?? "");
    setState(() {});
  }

  Future getImageCamera() async {
    final ImagePicker picker = ImagePicker();
    final imagePicked = await picker.pickImage(source: ImageSource.camera);
    image = File(imagePicked!.path);
    setState(() {});
  }

  Future _potoBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    height: 5,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    onTap: () async {
                      await getImageGalerry();
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.image,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text("Upload dari Galeri",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF454444),
                        )),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
                        size: 15,
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () async {
                      await getImageCamera();
                    },
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                      ),
                    ),
                    title: Text("Upload dari Kamera",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF454444),
                        )),
                    trailing: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.grey.shade200,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> editNotes() async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse(ApiConnect.editact));

      // Add text fields
      request.fields['id'] = widget.id;
      request.fields['title'] =
          titleController.text.isNotEmpty ? titleController.text : widget.title;
      request.fields['description'] = descriptionController.text.isNotEmpty
          ? descriptionController.text
          : widget.description;

      // Add image file
      if (image != null) {
        // Menambahkan gambar ke dalam permintaan multipart
        request.files.add(http.MultipartFile(
          'image',
          http.ByteStream(image!.openRead().cast()),
          await image!.length(),
          filename: titleController.text + '_new_board_image.jpg',
        ));
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print(responseBody);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BoardsPage()),
        );
      } else {
        // Handle response status code other than 200
        print("HTTP request failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("Error during registration: $e");
    }
  }

  Future<void> deleteData(String? id) async {
    try {
      var response = await http.post(
        Uri.parse(ApiConnect.delete),
        body: {
          "id": id,
        },
      );

      if (response.statusCode == 200) {
        // Navigate to the main screen after successful deletion.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BoardsPage()),
        );
        print("Success");
      } else {
        throw Exception("Failed to delete data from the server");
      }
    } catch (e) {
      print("Error: $e");
      throw e;
    }
  }
}
