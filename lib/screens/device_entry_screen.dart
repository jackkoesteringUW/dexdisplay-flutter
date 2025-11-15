import 'package:flutter/material.dart';

import '../screens/set_select_screen.dart';

class DeviceEntryScreen extends StatefulWidget {
  const DeviceEntryScreen({super.key});

  @override
  State<DeviceEntryScreen> createState() => _DeviceEntryScreenState();
}

class _DeviceEntryScreenState extends State<DeviceEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdCtrl = TextEditingController();

  @override
  void dispose() {
    _deviceIdCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetSelectScreen(deviceId: _deviceIdCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DexDisplay')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Enter Device ID', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deviceIdCtrl,
                decoration: const InputDecoration(
                  label: Text("Device ID"),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? "Enter device ID" : null,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _next,
                child: const Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
