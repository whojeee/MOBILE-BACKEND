class User {
  int? id;
  String? nim, nama;

  User({this.id, this.nim, this.nama});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], nim: json['nim'], nama: json['nama']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nim': nim, 'nama': nama};
  }
}
