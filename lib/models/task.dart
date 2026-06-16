class Task {
  final String id;
  final String title;
  final String description;
  final int orderIndex;
  final int durationSeconds;
  final String? audioUrl; // Optional custom audio file URL/path
  final String? imageUrl; // Optional custom illustration/GIF path

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.durationSeconds,
    this.audioUrl,
    this.imageUrl,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    int? orderIndex,
    int? durationSeconds,
    String? audioUrl,
    String? imageUrl,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'orderIndex': orderIndex,
      'durationSeconds': durationSeconds,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      orderIndex: map['orderIndex'] ?? 0,
      durationSeconds: map['durationSeconds'] ?? 0,
      audioUrl: map['audioUrl'],
      imageUrl: map['imageUrl'],
    );
  }
}
