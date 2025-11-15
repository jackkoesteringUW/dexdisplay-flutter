import 'package:flutter/material.dart';
import 'set_select_screen.dart';
import 'device_wifi_setup_screen.dart';

/// Device model stored in the app
class SavedDevice {
  final String id;    // deviceId used by backend & ESP
  final String name;  // human-friendly name

  const SavedDevice({required this.id, required this.name});
}

/// Root Shell: always shows a bottom navigation bar
/// Tabs:
///   0 = Devices
///   1 = Card Selection
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 1; // Default to "Card Selection"

  final List<SavedDevice> _devices = [];
  SavedDevice? _activeDevice;

  void _addDevice(SavedDevice d) {
    setState(() {
      _devices.add(d);
      _activeDevice ??= d; // first added device becomes active
    });
  }

  void _setActive(SavedDevice d) {
    setState(() => _activeDevice = d);
  }

  void _goToDevicesTab() {
    setState(() => _index = 0);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DevicesTab(
        devices: _devices,
        activeDevice: _activeDevice,
        onAddDevice: _addDevice,
        onSelectActive: _setActive,
      ),
      CardFlowRoot(
        devices: _devices,
        activeDevice: _activeDevice,
        onRequestSelectDevice: _goToDevicesTab,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int newIndex) {
          setState(() {
            _index = newIndex;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.devices_outlined),
            selectedIcon: Icon(Icons.devices),
            label: 'Devices',
          ),
          NavigationDestination(
            icon: Icon(Icons.style_outlined),
            selectedIcon: Icon(Icons.style),
           label: 'Card selection',
          ),
        ],
      ),
    );
  }
}

/// Tab 1: Devices list + ability to add + configure Wi-Fi + mark active
class DevicesTab extends StatelessWidget {
  final List<SavedDevice> devices;
  final SavedDevice? activeDevice;
  final void Function(SavedDevice) onAddDevice;
  final void Function(SavedDevice) onSelectActive;

  const DevicesTab({
    super.key,
    required this.devices,
    required this.activeDevice,
    required this.onAddDevice,
    required this.onSelectActive,
  });

  void _showAddDialog(BuildContext context) {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name (e.g. Desk Display)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: idCtrl,
                decoration: const InputDecoration(
                  labelText: 'Device ID',
                  helperText: 'ID configured on your ESP32',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final id = idCtrl.text.trim();
                final name = nameCtrl.text.trim();
                if (id.isEmpty || name.isEmpty) return;

                onAddDevice(
                  SavedDevice(id: id, name: name),
                );
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context),
      ),
      body: devices.isEmpty
          ? const Center(
              child: Text(
                'No devices yet.\nTap + to add one.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final d = devices[index];
                final isActive = activeDevice?.id == d.id;

                return ListTile(
                  leading: Icon(
                    isActive
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(d.name),
                  subtitle: Text('ID: ${d.id}'),
                  onTap: () => onSelectActive(d),

                  // Wi-Fi configuration button
                  trailing: IconButton(
                    icon: const Icon(Icons.wifi),
                    tooltip: 'Configure Wi-Fi',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DeviceWifiSetupScreen(device: d),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

/// Tab 2: Card-selection flow.
/// If no active device exists, show a helper screen.
/// If active device exists, enter SetSelectScreen like usual.
class CardFlowRoot extends StatelessWidget {
  final List<SavedDevice> devices;
  final SavedDevice? activeDevice;
  final VoidCallback onRequestSelectDevice;

  const CardFlowRoot({
    super.key,
    required this.devices,
    required this.activeDevice,
    required this.onRequestSelectDevice,
  });

  @override
  Widget build(BuildContext context) {
    // No device selected? Guide the user.
    if (activeDevice == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Card selection'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'No active device selected.\n\n'
                  'Go to the Devices tab, add your DexDisplay, and choose it as active.\n'
                  'Then return here to pick a card.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onRequestSelectDevice,
                  child: const Text('Go to Devices'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// If a device is active, go straight into your existing set-selection flow.
    return SetSelectScreen(deviceId: activeDevice!.id);
  }
}
