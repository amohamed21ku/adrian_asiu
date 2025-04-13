import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageBlendProvider with ChangeNotifier {
  Uint8List? _artworkImage;
  Uint8List? _faceImage;
  Uint8List? _blendedImage;
  bool _isLoading = false;
  String? _error;

  Uint8List? get artworkImage => _artworkImage;
  Uint8List? get faceImage => _faceImage;
  Uint8List? get blendedImage => _blendedImage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setArtworkImage(Uint8List image) {
    _artworkImage = image;
    notifyListeners();
  }

  void setFaceImage(Uint8List image) {
    _faceImage = image;
    notifyListeners();
  }

  Future<void> blendImages() async {
    if (_artworkImage == null || _faceImage == null) {
      _error = 'Please upload both artwork and face images';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) {
        throw Exception('API key not found');
      }

      final model = GenerativeModel(model: 'gemini-pro-vision', apiKey: apiKey);

      // Create the prompt for blending
      final prompt = '''
      Blend these two images together:
      1. The first image is an artwork
      2. The second image is a face
      
      Create a new image that combines the artistic style of the first image with the facial features of the second image.
      Maintain the artistic quality while preserving the recognizable facial features.
      The output should be a single image that shows the face in the style of the artwork.
      ''';

      // Create content with both images
      final content = [
        Content.multi([
          // Artwork image
          DataPart('image/jpeg', _artworkImage!),
          // Face image
          DataPart('image/jpeg', _faceImage!),
        ]),
        TextPart(prompt),
      ];

      // Generate the response
      final response = await model.generateContent(
        content as Iterable<Content>,
      );

      if (response.text != null) {
        // For now, we'll use a placeholder image since Gemini doesn't directly return images
        // In a real implementation, you would use an API that returns images
        _blendedImage =
            _artworkImage; // Placeholder - replace with actual blended image
      } else {
        throw Exception('Failed to generate blended image');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error blending images: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearImages() {
    _artworkImage = null;
    _faceImage = null;
    _blendedImage = null;
    _error = null;
    notifyListeners();
  }
}
