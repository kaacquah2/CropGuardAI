/// Equivalent of CommunityPost.kt domain data class
class CommunityPost {
  final String id;
  final String title;
  final String body;
  final String author;
  final String tag;
  final String? imageUri;
  final String? expertResponse;
  final int timestamp;

  const CommunityPost({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    this.tag = 'General',
    this.imageUri,
    this.expertResponse,
    required this.timestamp,
  });

  factory CommunityPost.fromMap(Map<String, dynamic> map, String id) {
    return CommunityPost(
      id: id,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      author: map['author'] as String? ?? 'Anonymous',
      tag: map['tag'] as String? ?? 'General',
      imageUri: map['imageUri'] as String?,
      expertResponse: map['expertResponse'] as String?,
      timestamp: (map['timestamp'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'author': author,
      'tag': tag,
      if (imageUri != null) 'imageUri': imageUri,
      if (expertResponse != null) 'expertResponse': expertResponse,
      'timestamp': timestamp,
    };
  }
}
