// new_project.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cc_appbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewProject extends StatefulWidget {
  const NewProject({super.key});

  @override
  _NewProjectState createState() => _NewProjectState();
}

class _NewProjectState extends State<NewProject> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final List<String> _activeFields = [];

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _toggleField(String field) {
    setState(() {
      if (_activeFields.contains(field)) {
        _activeFields.remove(field);
      } else {
        _activeFields.add(field);
      }
    });
  }

  Future<void> _saveProject() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('projects').add({
      'ownerId': user.uid,
      'name': _nameController.text,
      'description': _descriptionController.text,
      'activeFields': _activeFields,
      'createdAt': Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CCAppBar(isLoggedIn: FirebaseAuth.instance.currentUser != null),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              maxLength: 250,
              decoration: const InputDecoration(labelText: 'Project Name'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Upload Project Image'),
            ),
            if (_image != null) Image.file(_image!, height: 100),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLength: 2000,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Description (Optional)'),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: ['Email', 'Mobile Phone Number for texts', 'Public Solana Blockchain Wallet Addresses']
                  .map((field) => ElevatedButton(
                onPressed: () => _toggleField(field),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _activeFields.contains(field)
                      ? const Color(0xFFD11990)
                      : const Color(0xFFE4E3E1),
                ),
                child: Text(field, style: TextStyle(color: _activeFields.contains(field) ? Colors.white : Colors.black)),
              ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveProject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDB6242),
                ),
                child: const Text('Create Project', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
