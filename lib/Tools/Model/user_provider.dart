import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tugaskelompok/Tools/Model/user.dart'; // Import your user model

class UserProvider extends ChangeNotifier {
  List<User> _users = [];

  List<User> get users => _users;

  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }

  void deleteUser(int id) {
    _users.removeWhere((user) => user.id == id);
    notifyListeners();
  }

  // Implement other methods to update and fetch users
}
