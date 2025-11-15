import 'package:flutter/material.dart';

import '../api.dart';
import '../widgets/searchable_list.dart';
import 'grade_screen.dart';

class CardSelectScreen extends StatefulWidget {
  final String deviceId;
  final String setId;
  final String setName;

  const CardSelectScreen({
    super.key,
    required this.deviceId,
    required this.setId,
    required this.setName,
  });

  @override
  State<CardSelectScreen> createState() => _CardSelectScreenState();
}

class _CardSelectScreenState extends State<CardSelectScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> cards = [];
  Map<String, dynamic>? selectedCard;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => loading = true);

    final j =
        await getJson(Uri.parse("$baseUrl/cards?setId=${widget.setId}"));

    if (j['error'] != null) {
      setState(() {
        error = j['error'];
        loading = false;
      });
      return;
    }

    final data = (j['data'] as List).cast<Map<String, dynamic>>();
    data.sort((a, b) =>
        (a['number'].toString()).compareTo(b['number'].toString()));

    setState(() {
      cards = data;
      loading = false;
    });
  }

  String? _extractImageUrl(Map<String, dynamic> card) {
    final direct = card['image'] ??
        card['imageUrl'] ??
        card['image_url'] ??
        card['imageURL'];
    if (direct != null && direct.toString().isNotEmpty) {
      return direct.toString();
    }
    final images = card['images'];
    if (images is Map) {
      if (images['small'] != null) return images['small'].toString();
      if (images['large'] != null) return images['large'].toString();
    }
    return null;
  }

  void _next() {
    if (selectedCard == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GradeScreen(
          deviceId: widget.deviceId,
          card: selectedCard!,
          setName: widget.setName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final img = selectedCard == null ? null : _extractImageUrl(selectedCard!);

    return Scaffold(
      appBar: AppBar(title: Text(widget.setName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Card", style: TextStyle(fontSize: 22)),
            const SizedBox(height: 16),

            if (loading) const LinearProgressIndicator(),
            if (!loading && error != null)
              Text("Error: $error", style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 12),

            Expanded(
              child: loading
                  ? const SizedBox()
                  : SearchableList<Map<String, dynamic>>(
                      items: cards,
                      searchHint: 'Search cards (name or number)',
                      emptyText: 'No cards found',
                      labelBuilder: (c) =>
                          "${c['number']} — ${c['name']}",
                      filter: (c, text) {
                        final name =
                            (c['name'] ?? '').toString().toLowerCase();
                        final num =
                            (c['number'] ?? '').toString().toLowerCase();
                        return name.contains(text) || num.contains(text);
                      },
                      onSelected: (c) {
                        setState(() {
                          selectedCard = c;
                        });
                      },
                    ),
            ),

            if (img != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      img,
                      height: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            FilledButton(
              onPressed: selectedCard == null ? null : _next,
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
