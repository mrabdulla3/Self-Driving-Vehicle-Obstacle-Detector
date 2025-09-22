import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class HomeController extends GetxController {
  final selectedFile = Rxn<File>();
  final outputFile = Rxn<File>();
  final isVideo = false.obs;
  final isLoading = false.obs;

  VideoPlayerController? videoController;
  final picker = ImagePicker();

  /// Pick image from gallery
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _resetState();
      selectedFile.value = File(pickedFile.path);
      isVideo.value = false;
    }
  }

  /// Pick video from gallery
  Future<void> pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      _resetState();
      selectedFile.value = File(pickedFile.path);
      isVideo.value = true;
      _initVideoController(selectedFile.value!);
    }
  }

  /// Upload file to backend and get processed result
  Future<void> uploadFile() async {
    if (selectedFile.value == null) return;

    isLoading.value = true;

    final uri = Uri.parse(
      isVideo.value
          ? "${dotenv.env['HUGGING_FACE_URL']}/detect/video/"
          : "${dotenv.env['HUGGING_FACE_URL']}/detect/image/",
    );
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', selectedFile.value!.path),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final dir = await getTemporaryDirectory();
        final outFile = File(
          path.join(
            dir.path,
            isVideo.value ? "processed_video.mp4" : "processed_image.jpg",
          ),
        );
        await outFile.writeAsBytes(bytes);
        outputFile.value = outFile;

        if (isVideo.value) {
          _initVideoController(outputFile.value!);
        }
      } else {
        Get.snackbar("Error", "Upload failed: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Upload failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Initialize video controller
  void _initVideoController(File file) {
    videoController?.dispose();
    videoController = VideoPlayerController.file(file)
      ..initialize().then((_) {
        videoController!.setLooping(true);
        videoController!.play();
      });
  }

  /// Reset previous state
  void _resetState() {
    outputFile.value = null;
    videoController?.dispose();
    videoController = null;
  }

  @override
  void onClose() {
    videoController?.dispose();
    super.onClose();
  }
}
