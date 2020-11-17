class ArticleModel {
  final String id;
  final String title;
  final String body;
  final String department;
  int likesNumber;
  int commentsNumber;
  bool isPinned;

  final String imageUrl;

  ArticleModel(this.id, this.title, this.body, this.department, this.imageUrl,
      this.likesNumber, this.commentsNumber, this.isPinned);

//factory ArticleModel.fromJson(Map<String,dynamic> json){
//return ArticleModel(
//
//  id: json['id'],
//  title: json['title'],//
//  body: json['body'],//
//  department: json['department'],//
//  imageUrl: json['imageUrl'],//
//);
//}
}
