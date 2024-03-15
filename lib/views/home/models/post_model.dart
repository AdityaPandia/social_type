class PostModel {
  final String uid;
  final String postPhoto; 
  final List<String> likes;
  final String description;
  final List<Map<String,String>> comments;
  final String timeStampId;


  const PostModel( {required this.timeStampId,required this.uid, required this.postPhoto, required this.likes, required this.description, required this.comments});
}
