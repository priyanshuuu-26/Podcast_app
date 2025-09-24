class Podcast {
  final int id;
  final String title;
  final String author;
  final String imageUrl;
  final String audioUrl;

  Podcast({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.audioUrl,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    // ... this part remains the same
    return Podcast(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      audioUrl: json['url'] ?? '',
      imageUrl: json['image'] ?? '',
      author: json['author'] ?? 'Unknown Author',
    );
  }

  // Converts a Podcast instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'image': imageUrl,
      'url': audioUrl,
    };
  }
}