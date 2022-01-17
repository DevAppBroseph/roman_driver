import 'package:flutter/material.dart';
import 'package:ridbrain_project/services/objects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPrefsHandler {
  AdminPrefsHandler(this._preferences);

  final SharedPreferences _preferences;

  final String _adminToken = "adminToken";
  final String _adminId = "adminId";
  final String _adminName = "adminName";
  final String _adminEmail = "adminEmail";
  final String _adminStatus = "adminStatus";
  final String _adminRole = "adminRole";

  static Future<AdminPrefsHandler> getInstance() async {
    var shared = await SharedPreferences.getInstance();
    return AdminPrefsHandler(shared);
  }

  String getAdminToken() {
    return _preferences.getString(_adminToken) ?? "";
  }

  void setAdminToken(String value) {
    _preferences.setString(_adminToken, value);
  }

  int getAdminId() {
    return _preferences.getInt(_adminId) ?? 0;
  }

  void setAdminId(int value) {
    _preferences.setInt(_adminId, value);
  }

  String getAdminName() {
    return _preferences.getString(_adminName) ?? "";
  }

  void setAdminName(String value) {
    _preferences.setString(_adminName, value);
  }

  String getAdminEmail() {
    return _preferences.getString(_adminEmail) ?? "";
  }

  void setAdminEmail(String value) {
    _preferences.setString(_adminEmail, value);
  }

  int getAdminStatus() {
    return _preferences.getInt(_adminStatus) ?? 0;
  }

  void setAdminStatus(int value) {
    _preferences.setInt(_adminStatus, value);
  }

  int getAdminRole() {
    return _preferences.getInt(_adminRole) ?? 0;
  }

  void setAdminRole(int value) {
    _preferences.setInt(_adminRole, value);
  }

  void setEmptyAdmin() {
    _preferences.setString(_adminToken, '');
  }
}

class DriverPrefsHandler {
  DriverPrefsHandler(this._preferences);

  final SharedPreferences _preferences;

  final String _driverId = "driverId";
  final String _driverName = "driverName";
  final String _driverEmail = "driverEmail";
  final String _driverPass = "driverPass";
  final String _driverStatus = "driverStatus";
  final String _driverPhone = "driverPhone";
  final String _driverRecordCount = "driverRecordCount";
  final String _driverToken = "driverToken";

  static Future<DriverPrefsHandler> getInstance() async {
    var shared = await SharedPreferences.getInstance();
    return DriverPrefsHandler(shared);
  }

  int getDriverId() {
    return _preferences.getInt(_driverId) ?? 0;
  }

  void setDriverUid(int value) {
    _preferences.setInt(_driverId, value);
  }

  String getDriverName() {
    return _preferences.getString(_driverName) ?? "";
  }

  void setDriverName(String value) {
    _preferences.setString(_driverName, value);
  }

  String getDriverEmail() {
    return _preferences.getString(_driverEmail) ?? "";
  }

  void setDriverEmail(String value) {
    _preferences.setString(_driverEmail, value);
  }

  String getDriverPass() {
    return _preferences.getString(_driverPass) ?? "";
  }

  void setDriverPass(String value) {
    _preferences.setString(_driverPass, value);
  }

  String getDriverPhone() {
    return _preferences.getString(_driverPhone) ?? "";
  }

  void setDriverPhone(String value) {
    _preferences.setString(_driverPhone, value);
  }

  int getDriverStatus() {
    return _preferences.getInt(_driverStatus) ?? 0;
  }

  void setDriverStatus(int value) {
    _preferences.setInt(_driverStatus, value);
  }

  int getDriverRecordCount() {
    return _preferences.getInt(_driverRecordCount) ?? 0;
  }

  void setDriverRecordCount(int value) {
    _preferences.setInt(_driverRecordCount, value);
  }

  String getDriverToken() {
    return _preferences.getString(_driverToken) ?? "";
  }

  void setDriverToken(String value) {
    _preferences.setString(_driverToken, value);
  }

  void setEmptyDriver() {
    _preferences.setInt(_driverId, 0);
    _preferences.setString(_driverName, '');
    _preferences.setString(_driverEmail, '');
    _preferences.setString(_driverPass, '');
    _preferences.setString(_driverPhone, '');
    _preferences.setInt(_driverStatus, 0);
    _preferences.setInt(_driverRecordCount, 0);
    _preferences.setString(_driverToken, '');
  }
}

enum User { driver, admin, none }

class UserPrefsHandler {
  UserPrefsHandler(this._preferences);

  final SharedPreferences _preferences;

  final String _thisUser = "thisUser";

  static Future<UserPrefsHandler> getInstance() async {
    var shared = await SharedPreferences.getInstance();
    return UserPrefsHandler(shared);
  }

  User getUser() {
    var user = _preferences.getString(_thisUser) ?? '';
    for (var item in User.values) {
      if (item.name == user) {
        return item;
      }
    }
    return User.none;
  }

  void setUser(User value) {
    _preferences.setString(_thisUser, value.name);
  }
}

class DataProvider extends ChangeNotifier {
  DataProvider(
    this._driver,
    this._admin,
    this._user,
  );

  Driver _driver;
  Admin _admin;
  User _user;

  Driver get driver => _driver;
  Admin get admin => _admin;
  User get user => _user;

  bool get hasDriver => _driver.driverToken.isNotEmpty;
  bool get hasAdmin => _admin.token?.isNotEmpty ?? false;

  static Future<DataProvider> getInstance() async {
    var driverPrefs = await DriverPrefsHandler.getInstance();
    var adminPrefs = await AdminPrefsHandler.getInstance();
    var userPrefs = await UserPrefsHandler.getInstance();

    return DataProvider(
      Driver(
        driverName: driverPrefs.getDriverName(),
        driverPhone: driverPrefs.getDriverPhone(),
        driverEmail: driverPrefs.getDriverEmail(),
        driverToken: driverPrefs.getDriverToken(),
        driverId: driverPrefs.getDriverId(),
        driverRecordCount: driverPrefs.getDriverRecordCount(),
        driverStatus: driverPrefs.getDriverStatus(),
      ),
      Admin(
        token: adminPrefs.getAdminToken(),
        userId: adminPrefs.getAdminId(),
        userName: adminPrefs.getAdminName(),
        userEmail: adminPrefs.getAdminEmail(),
        userStatus: adminPrefs.getAdminStatus(),
        userRole: adminPrefs.getAdminRole(),
      ),
      userPrefs.getUser(),
    );
  }

  void setDriver(Driver driver) {
    _driver = driver;
    notifyListeners();
    DriverPrefsHandler.getInstance().then((value) {
      value.setDriverToken(driver.driverToken);
      value.setDriverName(driver.driverName);
      value.setDriverUid(driver.driverId);
      value.setDriverPhone(driver.driverPhone);
      value.setDriverEmail(driver.driverEmail);
      value.setDriverStatus(driver.driverStatus);
      value.setDriverRecordCount(driver.driverRecordCount);
    });
    changeUser(User.driver);
  }

  void setDriverToken(String newToken) {
    _driver.driverToken = newToken;
    notifyListeners();
    DriverPrefsHandler.getInstance().then(
      (value) => value.setDriverToken(newToken),
    );
  }

  void setDriverName(String newName) {
    _driver.driverName = newName;
    notifyListeners();
    DriverPrefsHandler.getInstance().then(
      (value) => value.setDriverName(newName),
    );
  }

  void setDriverPhone(String newPhone) {
    _driver.driverPhone = newPhone;
    notifyListeners();
    DriverPrefsHandler.getInstance().then(
      (value) => value.setDriverPhone(newPhone),
    );
  }

  void setDriverEmail(String emailPhone) {
    _driver.driverPhone = emailPhone;
    notifyListeners();
    DriverPrefsHandler.getInstance().then(
      (value) => value.setDriverEmail(emailPhone),
    );
  }

  void signOutDriver() {
    _driver = Driver(
        driverToken: '',
        driverName: '',
        driverPhone: '',
        driverEmail: '',
        driverId: 0,
        driverStatus: 0,
        driverRecordCount: 0);
    notifyListeners();

    DriverPrefsHandler.getInstance().then((value) => value.setEmptyDriver());

    if (hasAdmin) {
      changeUser(User.admin);
    } else {
      changeUser(User.none);
    }
  }

  void setAdmin(Admin admin) {
    _admin = admin;
    notifyListeners();
    AdminPrefsHandler.getInstance().then(
      (value) {
        value.setAdminToken(admin.token!);
        value.setAdminName(admin.userName);
        value.setAdminId(admin.userId);
        value.setAdminEmail(admin.userEmail);
        value.setAdminStatus(admin.userStatus);
        value.setAdminRole(admin.userRole);
      },
    );

    changeUser(User.admin);
  }

  void setAdminToken(String newToken) {
    _admin.token = newToken;
    notifyListeners();
    AdminPrefsHandler.getInstance().then(
      (value) => value.setAdminToken(newToken),
    );
  }

  void setAdminName(String newName) {
    _admin.userName = newName;
    notifyListeners();
    AdminPrefsHandler.getInstance().then(
      (value) => value.setAdminName(newName),
    );
  }

  void setAdminEmail(String newEmail) {
    _admin.userEmail = newEmail;
    notifyListeners();
    AdminPrefsHandler.getInstance().then(
      (value) => value.setAdminEmail(newEmail),
    );
  }

  void signOutAdmin() {
    _admin = Admin(
        token: '',
        userId: 0,
        userName: '',
        userEmail: '',
        userStatus: 0,
        userRole: 0);
    notifyListeners();

    AdminPrefsHandler.getInstance().then((value) => value.setEmptyAdmin());

    if (hasDriver) {
      changeUser(User.driver);
    } else {
      changeUser(User.none);
    }
  }

  void changeUser(User user) {
    _user = user;
    notifyListeners();
    UserPrefsHandler.getInstance().then((value) {
      value.setUser(user);
    });
  }
}
