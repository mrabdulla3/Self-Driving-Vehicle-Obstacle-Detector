import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:obstacle_detector/home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Car cockpit background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.grey[900]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // HUD overlay (like car dashboard trims)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset("assets/dashboard.png", fit: BoxFit.cover),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                return Stack(
                  children: [
                    Column(
                      children: [
                        // Title styled like HUD
                        Text(
                          "Obstacle Detector",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 12, color: Colors.cyanAccent),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),

                        // Windshield (Preview Area)
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.cyanAccent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                              color: Colors.black,
                            ),
                            child: Center(
                              child: controller.outputFile.value != null
                                  ? _buildPreview(
                                      controller.outputFile.value!,
                                      controller.isVideo.value,
                                      controller.videoController,
                                    )
                                  : controller.selectedFile.value != null
                                  ? _buildPreview(
                                      controller.selectedFile.value!,
                                      controller.isVideo.value,
                                      controller.videoController,
                                    )
                                  : Text(
                                      "Upload an image or video\nIt may take some time to process pleass wait for few seconds after uploading",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // HUD style Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _hudButton(
                              Icons.image,
                              "Pick Image",
                              controller.pickImage,
                            ),
                            _hudButton(
                              Icons.video_library,
                              "Pick Video",
                              controller.pickVideo,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        _hudButton(
                          Icons.cloud_upload,
                          "Upload & Detect",
                          controller.selectedFile.value != null
                              ? controller.uploadFile
                              : null,
                          width: double.infinity,
                        ),

                        SizedBox(height: 10),
                      ],
                    ),

                    //  Loading overlay
                    if (controller.isLoading.value)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.7),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.cyanAccent,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  "Processing...\nPlease wait",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.cyanAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudButton(
    IconData icon,
    String label,
    VoidCallback? onPressed, {
    double width = 150,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyanAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.cyanAccent),
        label: Text(
          label,
          style: TextStyle(color: Colors.cyanAccent, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPreview(
    File file,
    bool isVideo,
    VideoPlayerController? videoController,
  ) {
    if (isVideo) {
      if (videoController != null && videoController.value.isInitialized) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: VideoPlayer(videoController),
        );
      } else {
        return Text(
          "Processing video...",
          style: TextStyle(color: Colors.cyanAccent),
        );
      }
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(file, fit: BoxFit.contain),
      );
    }
  }
}
