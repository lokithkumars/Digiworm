import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // Replace with your actual server IP address
  static const String baseUrl = 'https://f42921a5bfaa.ngrok-free.app';
  
  // Updated method to handle XFile for both web and mobile
  static Future<Map<String, dynamic>?> predictDiseaseFromXFile(XFile imageFile) async {
    try {
      print('Starting disease prediction API call...');
      print('Server URL: $baseUrl/predict');
      print('Image file path: ${imageFile.path}');
      print('Image file name: ${imageFile.name}');

      // Read file as bytes (works for both web and mobile)
      final bytes = await imageFile.readAsBytes();
      print('Image file size: ${bytes.length} bytes');

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );
      
      // Set headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });

      // Get file extension and mime type
      String fileExtension = path.extension(imageFile.name).toLowerCase();
      String mimeType;
      
      switch (fileExtension) {
        case '.jpg':
        case '.jpeg':
          mimeType = 'image/jpeg';
          break;
        case '.png':
          mimeType = 'image/png';
          break;
        case '.bmp':
          mimeType = 'image/bmp';
          break;
        case '.gif':
          mimeType = 'image/gif';
          break;
        default:
          mimeType = 'image/jpeg'; // Default fallback
      }

      print('File extension: $fileExtension');
      print('MIME type: $mimeType');
      
      // Add the image file with proper content type using bytes
      var multipartFile = http.MultipartFile.fromBytes(
        'image', // This should match what your Flask server expects
        bytes,
        filename: imageFile.name,
        contentType: MediaType.parse(mimeType),
      );
      
      request.files.add(multipartFile);
      print('Multipart file added successfully');
      
      // Send the request with timeout
      print('Sending request...');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout. Please check your internet connection and server status.');
        },
      );
      
      print('Response status code: ${streamedResponse.statusCode}');
      
      // Convert streamed response to regular response
      var response = await http.Response.fromStream(streamedResponse);
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body);
          print('Successfully parsed JSON response: $jsonResponse');
          return jsonResponse;
        } catch (e) {
          print('Error parsing JSON response: $e');
          return {
            'error': 'Invalid response format from server',
            'raw_response': response.body
          };
        }
      } else {
        print('Server error: ${response.statusCode}');
        print('Error response body: ${response.body}');
        
        // Try to parse error response
        try {
          final errorResponse = json.decode(response.body);
          return {
            'error': errorResponse['error'] ?? 'Server error: ${response.statusCode}',
            'status_code': response.statusCode
          };
        } catch (e) {
          return {
            'error': 'Server error: ${response.statusCode} - ${response.body}',
            'status_code': response.statusCode
          };
        }
      }
    } on SocketException catch (e) {
      print('Network error: $e');
      return {
        'error': 'Network error: Please check your internet connection and ensure the server is running.',
        'details': e.toString()
      };
    } on HttpException catch (e) {
      print('HTTP error: $e');
      return {
        'error': 'HTTP error: ${e.message}',
        'details': e.toString()
      };
    } on FormatException catch (e) {
      print('Format error: $e');
      return {
        'error': 'Invalid response format from server',
        'details': e.toString()
      };
    } catch (e) {
      print('Unexpected error: $e');
      return {
        'error': 'Unexpected error occurred: ${e.toString()}',
        'details': e.toString()
      };
    }
  }
  
  // Keep the old method for backward compatibility
  static Future<Map<String, dynamic>?> predictDisease(File imageFile) async {
    // Convert File to XFile and use the new method
    final xFile = XFile(imageFile.path);
    return await predictDiseaseFromXFile(xFile);
  }
}