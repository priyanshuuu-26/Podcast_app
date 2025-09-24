import 'package:flutter/material.dart';
import 'package:podcast_app/models/category_model.dart';
import 'package:podcast_app/models/model.dart';
import 'package:podcast_app/services/api_service.dart';
import 'package:podcast_app/widgets/podcast_card.dart';

class CategoryPodcastsScreen extends StatefulWidget {
  final Category category;
  const CategoryPodcastsScreen({super.key, required this.category});

  @override
  State<CategoryPodcastsScreen> createState() => _CategoryPodcastsScreenState();
}

class _CategoryPodcastsScreenState extends State<CategoryPodcastsScreen> {
  final ApiService _apiService = ApiService();
  List<Podcast>? _podcasts;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPodcasts();
  }

  Future<void> _fetchPodcasts() async {
    try {
      // We use the search endpoint to find podcasts by category name
      final podcasts = await _apiService.searchPodcasts(widget.category.name);
      if (mounted) {
        setState(() {
          _podcasts = podcasts;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: _buildPodcastList(),
    );
  }
  
  Widget _buildPodcastList() {
    if (_podcasts == null && _errorMessage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    if (_podcasts!.isEmpty) {
      return const Center(child: Text('No podcasts found in this category.'));
    }

    return ListView.builder(
      itemCount: _podcasts!.length,
      itemBuilder: (context, index) {
        return PodcastCard(podcast: _podcasts![index]);
      },
    );
  }
}