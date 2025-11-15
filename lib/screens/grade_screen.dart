import 'package:flutter/material.dart';

import '../api.dart';

class GradeScreen extends StatefulWidget {
  final String deviceId;
  final Map<String, dynamic> card;
  final String setName;

  const GradeScreen({
    super.key,
    required this.deviceId,
    required this.card,
    required this.setName,
  });

  @override
  State<GradeScreen> createState() => _GradeScreenState();
}

class _GradeScreenState extends State<GradeScreen> {
  String mode = "raw";
  String? price;
  bool loadingPrice = false;
  bool sending = false;

  Future<void> _fetchPrice() async {
    setState(() => loadingPrice = true);

    final id = Uri.encodeQueryComponent(widget.card['id'].toString());
    final j = await getJson(
      Uri.parse("$baseUrl/card_price?id=$id&mode=$mode"),
    );

    // 🔒 Make sure the widget is still in the tree
    if (!mounted) return;

    setState(() {
      price = j['price']?.toString();
      loadingPrice = false;
    });
  }

  Future<void> _sendToDevice() async {
    setState(() => sending = true);

    final body = {
      "deviceId": widget.deviceId,
      "name": widget.card['name'],
      "set": widget.setName,
      "mode": mode,
      "price": price ?? "N/A",
    };

    final j = await postJson(Uri.parse("$baseUrl/device/text"), body);

    // 🔒 Widget might have been popped while we were waiting
    if (!mounted) return;

    setState(() => sending = false);

    final messenger = ScaffoldMessenger.of(context);
    if (j['error'] == null) {
      messenger.showSnackBar(
        SnackBar(content: Text("Sent to ${widget.deviceId}!")),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text("Error: ${j['error']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.card['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.setName, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              // ✅ use initialValue instead of value (fixes deprecation)
              initialValue: mode,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: "raw", child: Text("Raw")),
                DropdownMenuItem(value: "psa10", child: Text("PSA 10")),
                DropdownMenuItem(value: "psa9", child: Text("PSA 9")),
                DropdownMenuItem(value: "psa8", child: Text("PSA 8")),
              ],
              onChanged: (v) => setState(() => mode = v ?? "raw"),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: loadingPrice ? null : _fetchPrice,
              icon: loadingPrice
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.attach_money),
              label: Text(loadingPrice ? "Loading..." : "Preview Price"),
            ),

            if (price != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  "Price: $price",
                  style: const TextStyle(fontSize: 20),
                ),
              ),

            const Spacer(),

            FilledButton(
              onPressed: (price == null || sending) ? null : _sendToDevice,
              child: Text(sending ? "Sending..." : "Send"),
            )
          ],
        ),
      ),
    );
  }
}
