import 'package:flutter/material.dart';
import 'package:podcast_app/models/model.dart';
import 'package:podcast_app/widgets/podcast_card.dart';

class PodcastListScreen extends StatelessWidget {
  final String title;
  final List<Podcast> podcasts;

  const PodcastListScreen({
    super.key,
    required this.title,
    required this.podcasts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: podcasts.isEmpty
          ? const Center(
              child: Text('This list is empty.'),
            )
          : ListView.builder(
              itemCount: podcasts.length,
              itemBuilder: (context, index) {
                return PodcastCard(podcast: podcasts[index]);
              },
            ),
    );
  }
}