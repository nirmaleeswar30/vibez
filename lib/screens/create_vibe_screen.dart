// lib/screens/create_vibe_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateVibeScreen extends StatefulWidget {
  const CreateVibeScreen({super.key});

  @override
  State<CreateVibeScreen> createState() => _CreateVibeScreenState();
}

class _CreateVibeScreenState extends State<CreateVibeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  int _maxAttendees = 2;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitVibe() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a date.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() { _isLoading = true; });

    try {
      await FirebaseFirestore.instance.collection('vibes').add({
        'title': _titleController.text,
        'location': _locationController.text,
        'eventDate': Timestamp.fromDate(_selectedDate!),
        'maxAttendees': _maxAttendees,
        'creatorId': user.uid,
        'creatorName': user.displayName,
        'creatorPhotoUrl': user.photoURL,
        'attendees': [user.uid], // Creator automatically joins
        'createdAt': FieldValue.serverTimestamp(), // For sorting the feed
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
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitVibe,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('CREATE', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Vibe Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'Select Vibe Date'
                    : 'Date: ${DateFormat.yMMMd().format(_selectedDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              const Text("Max Attendees:"),
              DropdownButton<int>(
                value: _maxAttendees,
                items: List.generate(10, (index) => index + 1)
                    .map((num) => DropdownMenuItem(value: num, child: Text('$num')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _maxAttendees = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}