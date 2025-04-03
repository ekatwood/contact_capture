import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cc_appbar.dart';

class ProjectPage extends StatefulWidget {
  final String projectId;

  const ProjectPage({super.key, required this.projectId});

  @override
  _ProjectPageState createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _walletController = TextEditingController();
  bool _hasSubmitted = false;
  Map<String, dynamic>? _projectData;

  @override
  void initState() {
    super.initState();
    _fetchProjectData();
    _checkSubmissionStatus();
  }

  Future<void> _fetchProjectData() async {
    final projectSnapshot =
    await FirebaseFirestore.instance.collection('projects').doc(widget.projectId).get();
    if (projectSnapshot.exists) {
      setState(() {
        _projectData = projectSnapshot.data();
      });
    }
  }

  Future<void> _checkSubmissionStatus() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final submissionSnapshot = await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.projectId)
        .collection('submissions')
        .doc(user.uid)
        .get();

    setState(() {
      _hasSubmitted = submissionSnapshot.exists;
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}").hasMatch(email);
  }

  bool _isValidPhoneNumber(String phone) {
    return RegExp(r"^\+?[0-9]{7,15}").hasMatch(phone);
  }

  bool _isValidSolanaAddress(String address) {
    return RegExp(r"^[1-9A-HJ-NP-Za-km-z]{32,44}").hasMatch(address);
  }

  Future<void> _submitForm() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.projectId)
        .collection('submissions')
        .doc(user.uid)
        .set({
      'email': _emailController.text,
      'phone': _phoneController.text,
      'wallet': _walletController.text,
      'submittedAt': Timestamp.now(),
    });

    setState(() {
      _hasSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CCAppBar(isLoggedIn: FirebaseAuth.instance.currentUser != null),
      body: _projectData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_projectData!['imageUrl'] != null)
              Image.network(_projectData!['imageUrl'], height: 500, fit: BoxFit.cover),
            const SizedBox(height: 10),
            Text(
              _projectData!['name'] ?? 'Unnamed Project',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _projectData!['description'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (!_hasSubmitted) ...[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Mobile Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _walletController,
                decoration: const InputDecoration(labelText: 'Public Solana Blockchain Wallet Address'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_isValidEmail(_emailController.text) &&
                      _isValidPhoneNumber(_phoneController.text) &&
                      _isValidSolanaAddress(_walletController.text)) {
                    _submitForm();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid information.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD11990),
                ),
                child: const Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ] else ...[
              const Text(
                'You have already submitted your information for this project.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
