import 'package:flutter/material.dart';
// JACKKKKK
/*
for the wifi set up, you need your phone to be connected to the wifi that you want the dex to connect to and then you connect to the dex dispalys wifi
"tap to save current wifi"
*/

import 'home_shell.dart'; // for SavedDevice

class DeviceWifiSetupScreen extends StatelessWidget {
  final SavedDevice device;

  const DeviceWifiSetupScreen({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    // This is a placeholder we can upgrade later
    return Scaffold(
      appBar: AppBar(
        title: Text('Wi-Fi Setup – ${device.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Step 1',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text(
              'Plug in your DexDisplay and wait until the screen or LED indicates it is in setup mode.',
            ),
            const SizedBox(height: 16),

            Text(
              'Step 2',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text(
              'On your phone, open Wi-Fi settings and connect to the network named:\n\n'
              '  DexDisplay-XXXX\n\n'
              'Then return to this screen.',
            ),
            const SizedBox(height: 16),

            Text(
              'Step 3',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter the Wi-Fi network that your DexDisplay should join:',
            ),
            const SizedBox(height: 12),

            const _WifiFormPlaceholder(),

            const SizedBox(height: 24),
            const Text(
              'Note: For now this screen is a placeholder. '
              'Later we will send the Wi-Fi credentials directly to the DexDisplay '
              'over its setup Wi-Fi network (192.168.4.1).',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _WifiFormPlaceholder extends StatefulWidget {
  const _WifiFormPlaceholder();

  @override
  State<_WifiFormPlaceholder> createState() => _WifiFormPlaceholderState();
}

class _WifiFormPlaceholderState extends State<_WifiFormPlaceholder> {
  final ssidController = TextEditingController();
  final passController = TextEditingController();
  bool sending = false;

  @override
  void dispose() {
    ssidController.dispose();
    passController.dispose();
    super.dispose();
  }

  void _fakeSend() async {
    setState(() => sending = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pretend we just sent these to the DexDisplay 🎯'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: ssidController,
          decoration: const InputDecoration(
            labelText: 'Home Wi-Fi name (SSID)',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: passController,
          decoration: const InputDecoration(
            labelText: 'Wi-Fi password',
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: sending ? null : _fakeSend,
            child: sending
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Continue (placeholder)'),
          ),
        ),
      ],
    );
  }
}
