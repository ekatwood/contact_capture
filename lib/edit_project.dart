// edit_project.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cc_appbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProject extends StatefulWidget {
  final String projectId;
  const EditProject({super.key, required this.projectId});

  @override
  _EditProjectState createState() => _EditProjectState();
}

class _EditProjectState extends State<EditProject> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  bool emailActive = false;
  bool mobileActive = false;
  bool walletActive = false;
  bool isModified = false;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    DocumentSnapshot projectDoc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.projectId)
        .get();

    if (projectDoc.exists) {
      setState(() {
        _nameController.text = projectDoc['name'];
        _descriptionController.text = projectDoc['description'] ?? '';
        emailActive = projectDoc['email_active'] ?? false;
        mobileActive = projectDoc['mobile_active'] ?? false;
        walletActive = projectDoc['wallet_active'] ?? false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        isModified = true;
      });
    }
  }

  Future<void> _updateProject() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('projects').doc(widget.projectId).update({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'email_active': emailActive,
        'mobile_active': mobileActive,
        'wallet_active': walletActive,
      });
      Navigator.pop(context);
    }
  }

  Future<void> _deleteProject() async {
    await FirebaseFirestore.instance.collection('projects').doc(widget.projectId).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CCAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: () => setState(() => isModified = true),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: 250,
                decoration: const InputDecoration(labelText: 'Project Name'),
                validator: (value) => value!.isEmpty ? 'Name required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                maxLength: 2000,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              _image != null
                  ? Image.file(_image!, height: 200)
                  : ElevatedButton(onPressed: _pickImage, child: const Text('Upload Image')),
              SwitchListTile(
                title: const Text('Email Collection'),
                value: emailActive,
                onChanged: (val) => setState(() {
                  emailActive = val;
                  isModified = true;
                }),
              ),
              SwitchListTile(
                title: const Text('Mobile Phone Collection'),
                value: mobileActive,
                onChanged: (val) => setState(() {
                  mobileActive = val;
                  isModified = true;
                }),
              ),
              SwitchListTile(
                title: const Text('Public Blockchain Wallet Collection'),
                value: walletActive,
                onChanged: (val) => setState(() {
                  walletActive = val;
                  isModified = true;
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isModified ? _updateProject : null,
                child: const Text('Publish'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _deleteProject,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
