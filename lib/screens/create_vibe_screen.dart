// lib/screens/create_vibe_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:vibe_together_app/services/image_upload_service.dart';

class CreateVibeScreen extends StatefulWidget {
  const CreateVibeScreen({super.key});
  @override
  State<CreateVibeScreen> createState() => _CreateVibeScreenState();
}

class _CreateVibeScreenState extends State<CreateVibeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUploadService = ImageUploadService();
  XFile? _selectedImage;
  DateTime? _selectedDate;
  int _maxAttendees = 2;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final image = await _imageUploadService.pickImage();
    if (image != null) setState(() { _selectedImage = image; });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null && picked != _selectedDate) setState(() { _selectedDate = picked; });
  }

  Future<void> _submitVibe() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and select a date.')));
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() { _isLoading = true; });

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _imageUploadService.uploadImage(_selectedImage!);
    }

    try {
      await FirebaseFirestore.instance.collection('vibes').add({
        'title': _titleController.text,
        'location': _locationController.text,
        'eventDate': Timestamp.fromDate(_selectedDate!),
        'maxAttendees': _maxAttendees,
        'creatorId': user.uid,
        'creatorName': user.displayName,
        'creatorPhotoUrl': user.photoURL,
        'attendees': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
        'commentCount': 0, // <-- INITIALIZE COMMENT COUNT
      });
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      print("Error creating vibe: $e");
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a Vibe"),
        actions: [TextButton(onPressed: _isLoading ? null : _submitVibe, child: _isLoading ? const CircularProgressIndicator() : const Text('CREATE'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 150, width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                    child: _selectedImage != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover))
                        : const Center(child: Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Vibe Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              ListTile(title: Text(_selectedDate == null ? 'Select Vibe Date' : 'Date: ${DateFormat.yMMMd().format(_selectedDate!)}'), trailing: const Icon(Icons.calendar_today), onTap: () => _selectDate(context)),
              const SizedBox(height: 16),
              const Text("Max Attendees:"),
              DropdownButton<int>(
                value: _maxAttendees,
                items: List.generate(10, (i) => i + 1).map((n) => DropdownMenuItem(value: n, child: Text('$n'))).toList(),
                onChanged: (v) => setState(() => _maxAttendees = v!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}