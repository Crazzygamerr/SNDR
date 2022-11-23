import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  late SharedPreferences pref;

  Future set() async {
    pref = await SharedPreferences.getInstance();
    // return pref;
  }

  Future setUuid(String key, String user) async {
      await pref.setString(key, user);
}

  Future<String?> getUuid(String key) async {
    return pref.getString(key);
  }





}