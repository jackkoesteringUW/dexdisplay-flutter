import 'package:flutter/material.dart';

import '../api.dart';
import '../widgets/searchable_list.dart';
import 'card_select_screen.dart';

class SetSelectScreen extends StatefulWidget {
  final String deviceId;
  const SetSelectScreen({super.key, required this.deviceId});

  @override
  State<SetSelectScreen> createState() => _SetSelectScreenState();
}

class _SetSelectScreenState extends State<SetSelectScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> sets = [];
  String? selectedSetId;

  @override
  void initState() {
    super.initState();
    _loadSets();
  }

  Future<void> _loadSets() async {
    setState(() => loading = true);

    final j = await getJson(Uri.parse("$baseUrl/sets"));
    if (j['error'] != null) {
      setState(() {
        error = j['error'];
        loading = false;
      });
      return;
    }

    final data = (j['data'] as List).cast<Map<String, dynamic>>();
    setState(() {
      sets = data;
      loading = false;
    });
  }

  void _next() {
    if (selectedSetId == null) return;

    final selected = sets.firstWhere(
      (s) => s['id'].toString() == selectedSetId,
      orElse: () => {},
    );
    final setName = (selected['name'] ?? '').toString();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardSelectScreen(
          deviceId: widget.deviceId,
          setId: selectedSetId!,
          setName: setName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Set", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 16),

            if (loading) const LinearProgressIndicator(),
            if (!loading && error != null)
              Text("Error: $error", style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 12),

            // 🔍 Our reusable widget
            Expanded(
              child: loading
                  ? const SizedBox()
                  : SearchableList<Map<String, dynamic>>(
                      items: sets,
                      searchHint: 'Search sets',
                      emptyText: 'No sets found',
                      labelBuilder: (s) => s['name'].toString(),
                      subtitleBuilder: (s) => s['id'].toString(),
                      filter: (s, text) {
                        final name =
                            (s['name'] ?? '').toString().toLowerCase();
                        final id = s['id'].toString().toLowerCase();
                        return name.contains(text) || id.contains(text);
                      },
                      onSelected: (s) {
                        setState(() {
                          selectedSetId = s['id'].toString();
                        });
                      },
                    ),
            ),

            const SizedBox(height: 12),

            FilledButton(
              onPressed: selectedSetId == null ? null : _next,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Next"),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
