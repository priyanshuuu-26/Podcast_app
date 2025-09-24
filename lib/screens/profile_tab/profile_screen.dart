import 'package:flutter/material.dart';
import 'package:podcast_app/models/model.dart';
import 'package:podcast_app/screens/profile_tab/podcast_list.dart';
import 'package:podcast_app/services/storage_service.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final StorageService _storageService = StorageService();
  int _favoritesCount = 0;
  int _listenedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // Fetches the latest stats from local storage
  Future<void> _loadStats() async {
    final favCount = await _storageService.getFavoritesCount();
    final listenedCount = await _storageService.getListenedCount();
    if (mounted) {
      setState(() {
        _favoritesCount = favCount;
        _listenedCount = listenedCount;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // We don't use the AutomaticKeepAliveClientMixin here so that the stats
    // can refresh more easily when the user navigates back to this tab.
    
    // A simple button to manually refresh the stats
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _loadStats,
        child: const Icon(Icons.refresh),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- User Profile Header ---
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 50),
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Guest User', // Static user name
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 10),

                  // --- User Stats ---
                  const Text(
                    'Your Stats',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Stat Card for Favorites
                   Card(
                    child: InkWell( // Wrap ListTile in InkWell to make it tappable
                      onTap: () async {
                        final List<Podcast> podcasts = await _storageService.getFavorites();
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => PodcastListScreen(
                            title: 'Favorite Podcasts',
                            podcasts: podcasts,
                          ),
                        ));
                      },
                      child: ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: const Text('Favorite Podcasts'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_favoritesCount.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Stat Card for Listened
                  Card(
                    child: InkWell( // Wrap ListTile in InkWell to make it tappable
                      onTap: () async {
                        final List<Podcast> podcasts = await _storageService.getListenedPodcasts();
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => PodcastListScreen(
                            title: 'Listened Podcasts',
                            podcasts: podcasts,
                          ),
                        ));
                      },
                      child: ListTile(
                        leading: const Icon(Icons.headset, color: Colors.blue),
                        title: const Text('Podcasts Listened'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_listenedCount.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
              );
  }
}