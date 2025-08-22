import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class GetStoreData extends GetxController {
  static final getStore = GetStorage();

  // Rx variables for automatic UI updates
  static final RxString id = ''.obs;
  static final RxString mbid = ''.obs;
  static final RxString firstName = ''.obs;
  static final RxString lastName = ''.obs;
  static final RxString email = ''.obs;
  static final RxString phone = ''.obs;
  static final RxString authToken = ''.obs;
  static final RxString picture = ''.obs;

  // Load stored data and listen for changes
  static void loadUserData() {
    id.value = getStore.read('id') ?? '';
    mbid.value = getStore.read('mbid') ?? '';
    firstName.value = getStore.read('firstName') ?? '';
    lastName.value = getStore.read('lastName') ?? '';
    email.value = getStore.read('email') ?? '';
    phone.value = getStore.read('phone') ?? '';
    authToken.value = getStore.read('access_token') ?? '';
    picture.value = getStore.read('picture') ?? '';

    // Auto-update UI when GetStorage changes
    getStore.listen(() {
      id.value = getStore.read('id') ?? '';
      mbid.value = getStore.read('mbid') ?? '';
      firstName.value = getStore.read('firstName') ?? '';
      lastName.value = getStore.read('lastName') ?? '';
      email.value = getStore.read('email') ?? '';
      phone.value = getStore.read('phone') ?? '';
      authToken.value = getStore.read('access_token') ?? '';
      picture.value = getStore.read('picture') ?? '';
    });
  }

  // Update user data globally
  static void updateUserData({
    String? id,
    String? mbid,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? authToken,
    String? picture,
  }) {
    if (id != null) {
      getStore.write('id', id);
      GetStoreData.id.value = id;
    }
    if (mbid != null) {
      getStore.write('mbid', mbid);
      GetStoreData.mbid.value = mbid;
    }
    if (firstName != null) {
      getStore.write('firstName', firstName);
      GetStoreData.firstName.value = firstName;
    }
    if (lastName != null) {
      getStore.write('lastName', lastName);
      GetStoreData.lastName.value = lastName;
    }
    if (email != null) {
      getStore.write('email', email);
      GetStoreData.email.value = email;
    }
    if (phone != null) {
      getStore.write('phone', phone);
      GetStoreData.phone.value = phone;
    }
    if (authToken != null) {
      getStore.write('access_token', authToken);
      GetStoreData.authToken.value = authToken;
    }
    if (picture != null) {
      getStore.write('picture', picture);
      GetStoreData.picture.value = picture;
    }
  }
}
