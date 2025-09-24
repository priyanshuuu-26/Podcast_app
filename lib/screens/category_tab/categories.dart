import 'package:flutter/material.dart';
import 'package:podcast_app/models/category_model.dart';
import 'package:podcast_app/screens/category_tab/category_podcast.dart';
import 'package:podcast_app/services/api_service.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with AutomaticKeepAliveClientMixin<CategoriesPage> {
  final ApiService _apiService = ApiService();
  List<Category>? _categories;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (_categories == null) {
      _fetchCategories();
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_categories == null && _errorMessage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }

    return ListView.builder(
      itemCount: _categories!.length,
      itemBuilder: (context, index) {
        final category = _categories![index];
        return ListTile(
          title: Text(category.name),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryPodcastsScreen(category: category),
              ),
            );
          },
        );
      },
    );
  }
}