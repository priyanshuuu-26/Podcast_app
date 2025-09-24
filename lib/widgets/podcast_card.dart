import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/model.dart';
import '../screens/home_tab/player_screen.dart';
import '../services/storage_service.dart';

class PodcastCard extends StatefulWidget {
  final Podcast podcast;
  // Callback to notify the parent when a favorite changes, used by the FavouritesScreen
  final VoidCallback? onFavoriteChanged;

  const PodcastCard({
    super.key,
    required this.podcast,
    this.onFavoriteChanged,
  });

  @override
  State<PodcastCard> createState() => _PodcastCardState();
}

class _PodcastCardState extends State<PodcastCard> {
  final StorageService _storageService = StorageService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // When the card is created check if it's already a favorite
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    bool isFav = await _storageService.isFavorite(widget.podcast.id.toString());
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  void _toggleFavorite() async {
    if (_isFavorite) {
      await _storageService.removeFavorite(widget.podcast.id.toString());
    } else {
      await _storageService.saveFavorite(widget.podcast);
    }
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    // Call the callback to notify the parent screen (if it was provided)
    widget.onFavoriteChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: widget.podcast.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
         // Show a loading spinner while the image downloads
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      // Show an error icon if the image fails to load
      errorWidget: (context, url, error) => const Icon(Icons.podcasts),
        ),
        title: Text(widget.podcast.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(widget.podcast.author),
        trailing: IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: _toggleFavorite,
        ),
        // Navigate to the player
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerScreen(podcast: widget.podcast),
            ),
          );
        },
      ),
    );
  }
}