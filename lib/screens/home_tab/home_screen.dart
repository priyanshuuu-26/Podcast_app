import 'package:flutter/material.dart';
import '../../models/model.dart';
import '../../services/api_service.dart';
import '../../widgets/podcast_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  late Future<List<Podcast>> _podcastsFuture;
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPodcasts();
  }

  void _fetchPodcasts({String? query}) {
    setState(() {
      if (query != null && query.isNotEmpty) {
        _podcastsFuture = _apiService.searchPodcasts(query);
      } else {
        _podcastsFuture = _apiService.getTrendingPodcasts();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for podcasts...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onSubmitted: (value) {
              _fetchPodcasts(query: value);
            },
          ),
        ),
        // Podcast list
        Expanded(
          child: FutureBuilder<List<Podcast>>(
            future: _podcastsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else if (snapshot.hasData) {
                final podcasts = snapshot.data!;
                if (podcasts.isEmpty) {
                  return const Center(child: Text('No podcasts found.'));
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      _fetchPodcasts(query: _searchController.text),
                  child: ListView.builder(
                    itemCount: podcasts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: Text(
                              "Trending Podcasts",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }
                      return PodcastCard(podcast: podcasts[index - 1]);
                    },
                  ),
                );
              }
              return const Center(child: Text('Something went wrong.'));
            },
          ),
        ),
      ],
    );
  }
}
