import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:travelplan/mainapp.dart';

class NotesPage extends StatefulWidget {
  final String country;
  final String city;
  final String image;
  final String docId;
  final String days;
  final String price;
  final String content;
  const NotesPage({
    Key? key,
    required this.country,
    required this.city,
    required this.image,
    required this.docId,
    required this.days,
    required this.price,
    required this.content,
  }) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late QuillEditorController controller;
  @override
  void initState() {
    controller = QuillEditorController();
    controller.onEditorLoaded(() {
      controller.setText(widget.content);
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> saveNoteToFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final String content = await controller.getText();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(widget.docId)
        .set({
      'country': widget.country,
      'city': widget.city,
      'image': widget.image,
      'days': widget.days,
      'content': content
      'price': widget.price,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 30,
          ),
        ),
        title: Center(
          child: Text(
            "Travel Notes",
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w300,
              fontSize: 30,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                saveNoteToFirestore()
                    .then(
                      (value) => Get.snackbar('Success', 'Notes Saved'),
                    )
                    .then(
                      (value) => Get.offAll(const MainApp()),
                    );
              },
              child: const Icon(
                Icons.check_circle_rounded,
                size: 30,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(
                left: 28,
                right: 20,
                top: 0,
                bottom: 20,
              ),
              child: ToolBar(
                controller: controller,
                toolBarConfig: const [
                  ToolBarStyle.bold,
                  ToolBarStyle.italic,
                  ToolBarStyle.underline,
                  ToolBarStyle.color,
                ],
              ),
            ),
            Container(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              height: MediaQuery.of(context).size.height * 1,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                border: Border.all(
                  width: 1.0,
                  color: Colors.grey[900]!,
                ),
                //shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 7,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: QuillHtmlEditor(
                    backgroundColor: Colors.white,
                    controller: controller,
                    hintText: 'Type something...',
                    minHeight: 300,
                    textStyle: GoogleFonts.playfairDisplay(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
