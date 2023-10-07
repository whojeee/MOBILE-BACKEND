class User {
  int? id;
  String? nama;
  String? username;
  String? gmail;
  String? password;
  bool? premium;

  User(
      {this.id,
      this.nama,
      this.username,
      this.gmail,
      this.password,
      this.premium});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nama: json['nama'],
      username: json['username'],
      gmail: json['gmail'],
      password: json['password'],
      premium: json['premium'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'gmail': gmail,
      'password': password,
      'premium': premium,
    };
  }
}
