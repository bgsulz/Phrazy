import 'package:flutter/material.dart';
import 'package:phrazy/utility/ext.dart';

class ScoreboardDisplay extends StatelessWidget {
  final Map<String, int>? data;

  const ScoreboardDisplay(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    if (data == null || data!.isEmpty) {
      return const Text('No scores yet!');
    }

    List<MapEntry<String, int>> sortedEntries = data!.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedEntries.length,
          itemBuilder: (context, index) {
            final entry = sortedEntries[index];
            return Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 1.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                  Text(
                    entry.value.toDisplayTime,
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
