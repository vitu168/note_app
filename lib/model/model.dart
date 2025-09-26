class Model {
  int? id;
  String? title;
  String? description;
  String? content;
  String? date;
  bool isFavorite;

  Model({
    this.id,
    this.description,
    this.isFavorite= false,
    required this.title,
    required this.date,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'description': description,
      'isFavourite': isFavorite
    };
  }

  factory Model.fromMap(Map<String, dynamic> map) {
    return Model(
      id: map['id'],
      date: map['date'],
      title: map['title'],
      content: map['content'],
      description: map['description'],
      isFavorite: map['isFavourite'] ?? false,
    );
  }
}
