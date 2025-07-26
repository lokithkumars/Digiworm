import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../services/api_service.dart'; // Import the correct ApiService

class DiseasePredictionScreen extends StatefulWidget {
  const DiseasePredictionScreen({super.key});

  @override
  State<DiseasePredictionScreen> createState() =>
      _DiseasePredictionScreenState();
}

class _DiseasePredictionScreenState extends State<DiseasePredictionScreen> {
  File? _selectedImage;
  Uint8List? _webImage; // For web platform
  XFile? _pickedFile; // Store the picked file
  String? _predictionResult;
  Map<String, dynamic>? _fullPredictionData;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // List of supported image formats
  final List<String> _supportedFormats = [
    '.jpg',
    '.jpeg',
    '.png',
    '.bmp',
    '.gif'
  ];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024, // Increased max width
        maxHeight: 1024, // Increased max height
        imageQuality: 90, // Increased quality
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile != null) {
        // Check file extension
        String fileExtension = path.extension(pickedFile.name).toLowerCase();

        if (!_supportedFormats.contains(fileExtension)) {
          _showErrorSnackBar(
              'Unsupported image format. Please use JPG, PNG, or other common image formats.');
          return;
        }

        setState(() {
          _pickedFile = pickedFile;
          _predictionResult = null;
          _fullPredictionData = null;
        });

        // Handle different platforms
        if (kIsWeb) {
          // For web platform
          final bytes = await pickedFile.readAsBytes();

          // Check file size (limit to 10MB)
          const maxSize = 10 * 1024 * 1024; // 10MB in bytes
          if (bytes.length > maxSize) {
            _showErrorSnackBar(
                'Image file is too large. Please use an image smaller than 10MB.');
            return;
          }

          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          // For mobile platforms
          final file = File(pickedFile.path);
          final fileSize = await file.length();
          const maxSize = 10 * 1024 * 1024; // 10MB in bytes

          if (fileSize > maxSize) {
            _showErrorSnackBar(
                'Image file is too large. Please use an image smaller than 10MB.');
            return;
          }

          setState(() {
            _selectedImage = file;
            _webImage = null;
          });
        }

        _showSuccessSnackBar('Image selected successfully!');
      }
    } catch (e) {
      _showErrorSnackBar('Error picking image: ${e.toString()}');
      print('Image picker error: $e'); // Debug print
    }
  }

  Future<void> _predictDisease() async {
    // Check if any image is available (web or mobile)
    if (_pickedFile == null) {
      _showErrorSnackBar('Please select an image first');
      return;
    }

    // For mobile platforms - verify file still exists (if it's a file-based image)
    if (!kIsWeb && _selectedImage != null && !await _selectedImage!.exists()) {
      _showErrorSnackBar(
          'Selected image file no longer exists. Please select a new image.');
      setState(() {
        _selectedImage = null;
        _pickedFile = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _predictionResult = null;
      _fullPredictionData = null;
    });

    try {
      // Use the XFile directly - this works for both web and mobile
      print('Sending image: ${_pickedFile!.name}'); // Debug print

      final result = await ApiService.predictDiseaseFromXFile(_pickedFile!);

      setState(() {
        _isLoading = false;
        if (result != null) {
          // Check if the result contains an error
          if (result.containsKey('error')) {
            _predictionResult = 'Error: ${result['error']}';
          } else {
            _fullPredictionData = result;
            _predictionResult = result['label'] ??
                result['prediction'] ??
                'No prediction available';
          }
          print('Prediction result: $result'); // Debug print
        } else {
          _predictionResult = 'Error: Unable to get prediction from server';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _predictionResult = 'Error: ${e.toString()}';
      });
      print('Prediction error: $e'); // Debug print
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Only show camera option on mobile platforms
              if (!kIsWeb) ...[
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text('Camera'),
                  subtitle: const Text('Take a new photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: Text(kIsWeb ? 'Upload Image' : 'Gallery'),
                subtitle: Text(
                    kIsWeb ? 'Choose from computer' : 'Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _resetPrediction() {
    setState(() {
      _selectedImage = null;
      _webImage = null;
      _pickedFile = null;
      _predictionResult = null;
      _fullPredictionData = null;
    });
    _showSuccessSnackBar('Reset completed');
  }

  // Check if any image is selected
  bool get _hasImage => _pickedFile != null;

  Widget _buildImagePreview() {
    if (_pickedFile == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No image selected',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Supported formats: JPG, PNG, BMP, GIF',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: kIsWeb && _webImage != null
              ? Image.memory(
                  _webImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.red.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading image',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
              : _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.red.shade100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red.shade600,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Error loading image',
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _webImage = null;
                  _pickedFile = null;
                  _predictionResult = null;
                  _fullPredictionData = null;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/agriculture_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Color(0x88000000), // Semi-transparent black overlay
            BlendMode.darken,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Plant Disease Detection'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (_pickedFile != null || _predictionResult != null)
              IconButton(
                onPressed: _resetPrediction,
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset',
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions Card
              Card(
                elevation: 4,
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        kIsWeb
                            ? 'Upload a clear photo of the plant leaf from your computer for disease detection'
                            : 'Take a clear photo of the plant leaf or upload from gallery for disease detection',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Supported formats: JPG, JPEG, PNG, BMP, GIF (Max: 10MB)',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Image Selection Card
              Card(
                elevation: 4,
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Select Plant Image',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildImagePreview(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showImageSourceDialog,
                              icon: Icon(kIsWeb
                                  ? Icons.upload_file
                                  : Icons.add_a_photo),
                              label: Text(_pickedFile != null
                                  ? 'Change Image'
                                  : (kIsWeb ? 'Upload Image' : 'Select Image')),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Predict Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _hasImage && !_isLoading ? _predictDisease : null,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.psychology),
                  label: Text(
                    _isLoading ? 'Analyzing...' : 'Predict Disease',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Result Card
              if (_predictionResult != null)
                Card(
                  elevation: 4,
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: _predictionResult!.startsWith('Error')
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Prediction Result',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _predictionResult!.startsWith('Error')
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _predictionResult!.startsWith('Error')
                                  ? Colors.red.shade200
                                  : Colors.green.shade200,
                            ),
                          ),
                          child: Text(
                            _predictionResult!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _predictionResult!.startsWith('Error')
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ),

                        // Show confidence score if available
                        if (_fullPredictionData != null &&
                            _fullPredictionData!['confidence'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.trending_up,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Confidence: ${(_fullPredictionData!['confidence'] * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

              // Tips Card
              if (_predictionResult != null &&
                  !_predictionResult!.startsWith('Error'))
                Card(
                  elevation: 4,
                  color: Colors.white.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recommendation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Consult with an agricultural expert for proper treatment recommendations based on this prediction.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
