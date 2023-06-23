import 'package:flutter/material.dart';

class SampleListView extends StatelessWidget {
  const SampleListView({Key? key, required this.entries}) : super(key: key);

  final List<int> entries;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: entries
          .map(
            (int e) => ListTile(
          leading: const Icon(Icons.android),
          title: Text('List element ${e + 1}'),
        ),
      )
          .toList(),
    );
  }
}
