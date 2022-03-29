class SubjectModel{

  final String mobile;
  final String name;
  String contact='';

  SubjectModel(this.mobile,this.name);

}

SubjectModel createSubjectModel(Map<dynamic,dynamic> map){

  return SubjectModel(map['mobile'].toString(), map['name']);

}