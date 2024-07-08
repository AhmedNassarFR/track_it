import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ProfileController extends GetxController {
  var userName = ''.obs;
  var userAge = ''.obs;
  var userWeight = ''.obs;
  var profileImage = Rx<File?>(null);

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userName.value = prefs.getString('name') ?? '';
    userAge.value = prefs.getString('age') ?? '';
    userWeight.value = prefs.getString('weight') ?? '';

    String? base64Image = prefs.getString('profile_image');
    if (base64Image != null) {
      final bytes = base64Decode(base64Image);
      final tempDir = await getTemporaryDirectory();
      final imageFile = File('${tempDir.path}/profile_image.png');
      await imageFile.writeAsBytes(bytes);
      profileImage.value = imageFile;
    }
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      profileImage.value = imageFile;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', base64Image);
    }
  }

  Future<void> saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', userName.value);
    await prefs.setString('age', userAge.value);
    await prefs.setString('weight', userWeight.value);
  }
}
