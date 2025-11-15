import 'package:flutter/material.dart';
import 'home_shell.dart';

class DevicesScreen extends StatelessWidget {
  final List<SavedDevice> devices;
  final SavedDevice? activeDevice;
  final void Function(SavedDevice) onAddDevice;
  final void Function(SavedDevice) onSelectActive;

  const DevicesScreen({
    super.key,
    required this.devices,
    required this.activeDevice,
    required this.onAddDevice,
    required this.onSelectActive,
  });

  void _add(BuildContext context) {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Device ID')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (idCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                onAddDevice(SavedDevice(id: idCtrl.text.trim(), name: nameCtrl.text.trim()));
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context),
        child: const Icon(Icons.add),
      ),
      body: devices.isEmpty
          ? const Center(child: Text('No devices yet. Tap + to add one.'))
          : ListView(
              children: [
                for (final d in devices)
                  ListTile(
                    title: Text(d.name),
                    subtitle: Text(d.id),
                    leading: Icon(
                      activeDevice?.id == d.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    onTap: () => onSelectActive(d),
                  )
              ],
            ),
    );
  }
}
