import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:provider/provider.dart';

import '../helper/ad_helper.dart';
import '../helper/global.dart';
import '../helper/pref.dart';
import '../model/home_type.dart';
import '../widget/home_card.dart';
import '../provider/image_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final _isDarkMode = Pref.isDarkMode.obs;
  final _isDarkMode = Get.isDarkMode.obs; //bug fix

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Pref.showOnboarding = false;
  }

  @override
  Widget build(BuildContext context) {
    //initializing device size
    mq = MediaQuery.sizeOf(context);

    //sample api call
    // APIs.getAnswer('hii');

    return Scaffold(
      //app bar
      appBar: AppBar(
        title: const Text(appName),

        //
        actions: [
          IconButton(
              padding: const EdgeInsets.only(right: 10),
              onPressed: () {
                Get.changeThemeMode(
                    _isDarkMode.value ? ThemeMode.light : ThemeMode.dark);

                _isDarkMode.value = !_isDarkMode.value;
                Pref.isDarkMode = _isDarkMode.value;
              },
              icon: Obx(() => Icon(
                  _isDarkMode.value
                      ? Icons.brightness_2_rounded
                      : Icons.brightness_5_rounded,
                  size: 26)))
        ],
      ),

      //ad
      bottomNavigationBar: AdHelper.nativeBannerAd(),

      //body
      body: Consumer<ImageBlendProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Upload Section
                Expanded(
                  child: Row(
                    children: [
                      // Artwork Upload
                      Expanded(
                        child: _ImageUploadCard(
                          title: 'Upload Artwork',
                          image: provider.artworkImage,
                          onUpload: () => _pickImage(context, true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Face Upload
                      Expanded(
                        child: _ImageUploadCard(
                          title: 'Upload Face',
                          image: provider.faceImage,
                          onUpload: () => _pickImage(context, false),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Blend Button
                ElevatedButton(
                  onPressed: provider.isLoading ? null : () => provider.blendImages(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Blend Images'),
                ),
                const SizedBox(height: 16),
                // Blended Image Display
                if (provider.blendedImage != null)
                  Expanded(
                    child: Card(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Blended Result',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Image.memory(
                              provider.blendedImage!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (provider.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, bool isArtwork) async {
    try {
      final image = await ImagePickerWeb.getImageAsBytes();
      if (image != null) {
        final provider = context.read<ImageBlendProvider>();
        if (isArtwork) {
          provider.setArtworkImage(image);
        } else {
          provider.setFaceImage(image);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
}

class _ImageUploadCard extends StatelessWidget {
  final String title;
  final Uint8List? image;
  final VoidCallback onUpload;

  const _ImageUploadCard({
    required this.title,
    required this.image,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: image != null
                ? Image.memory(
                    image!,
                    fit: BoxFit.contain,
                  )
                : Center(
                    child: ElevatedButton(
                      onPressed: onUpload,
                      child: const Text('Upload Image'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
