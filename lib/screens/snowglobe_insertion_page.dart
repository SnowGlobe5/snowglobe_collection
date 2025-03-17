import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import '../services/snowglobe_service.dart';
import '../services/image_service.dart';
import 'map_picker_page.dart';
import '../models/snowglobe.dart';
import '../colors.dart';

class SnowGlobeInsertionPage extends StatefulWidget {
  final SnowGlobe? snowglobe; // If provided, we're editing.
  SnowGlobeInsertionPage({Key? key, this.snowglobe}) : super(key: key);

  @override
  _SnowGlobeInsertionPageState createState() => _SnowGlobeInsertionPageState();
}

class _SnowGlobeInsertionPageState extends State<SnowGlobeInsertionPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  // Controllers for text fields.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  DateTime? _selectedDate;

  // Location information provided by the picker.
  double? _latitude;
  double? _longitude;
  String? _city;
  String? _country;

  // Dropdown selections with default values.
  String _selectedSize = "S"; // Options: XS, S, M, L, XL.
  String _selectedShape =
      "Classic"; // Options: Classic, Heart, Half Pyramid, Other.

  final SnowGlobeService _snowglobeService = SnowGlobeService();
  final ImageService _imageService = ImageService();

  @override
  void initState() {
    super.initState();
    if (widget.snowglobe != null) {
      // Populate fields for editing.
      _nameController.text = widget.snowglobe!.name;
      _codeController.text = widget.snowglobe!.code;
      _selectedDate = widget.snowglobe!.date;
      _selectedSize = widget.snowglobe!.size;
      _selectedShape = widget.snowglobe!.shape;
      _city = widget.snowglobe!.city;
      _country = widget.snowglobe!.country;
      _latitude = widget.snowglobe!.latitude;
      _longitude = widget.snowglobe!.longitude;
      // Note: If you want to update the image, _selectedImage remains null until a new image is chosen.
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _cropImage(imageFile);
    }
  }

  Future<void> _cropImage(File imageFile) async {
    CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: AppColors.foreground,
          backgroundColor: AppColors.scaffoldBackground,
          activeControlsWidgetColor: AppColors.primary,
          statusBarColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
      ],
    );
    if (cropped != null) {
      File croppedFile = File(cropped.path);
      // Resize the image to 2048x2048.
      File resizedFile = await _resizeImage(croppedFile, 2048, 2048);
      setState(() {
        _selectedImage = resizedFile;
      });
    }
  }

  Future<File> _resizeImage(File imageFile, int width, int height) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Error decoding image");
    }
    img.Image resized = img.copyResize(
      originalImage,
      width: width,
      height: height,
    );
    final tempDir = await getTemporaryDirectory();
    String filePath = path.join(
      tempDir.path,
      'resized_${path.basename(imageFile.path)}',
    );
    File resizedFile = File(filePath)..writeAsBytesSync(img.encodePng(resized));
    return resizedFile;
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPickerPage()),
    );
    if (result != null && result is Map) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
        _city = result['city'];
        _country = result['country'];
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 50),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        (_selectedImage == null && widget.snowglobe == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all fields and select an image'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.snowglobe == null) {
        // Insert new record.
        SnowGlobe? snowglobe = await _snowglobeService.insertSnowGlobe(
          name: _nameController.text,
          size: _selectedSize,
          date: _selectedDate,
          code: _codeController.text,
          shape: _selectedShape,
          country: _country,
          city: _city,
          latitude: _latitude,
          longitude: _longitude,
        );

        if (snowglobe == null) {
          throw Exception("Error inserting record");
        }

        // Upload the image.
        final imagePath = 'snowglobe_${snowglobe.id}.png';
        final rawUrl = await _imageService.uploadImage(
          _selectedImage!,
          imagePath,
        );
        // Append a timestamp to force a fresh URL.
        final publicUrl =
            rawUrl + '?v=${DateTime.now().millisecondsSinceEpoch}';

        // Update the record with the image URL.
        final updateResponse =
            await Supabase.instance.client
                .from('snowglobes')
                .update({'image_url': publicUrl})
                .eq('id', snowglobe.id)
                .select()
                .maybeSingle();

        if (updateResponse == null) {
          throw Exception('Error updating image: $updateResponse');
        }
      } else {
        // Update existing record.
        bool updated = await _snowglobeService.updateSnowGlobe(
          id: widget.snowglobe!.id,
          name: _nameController.text,
          size: _selectedSize,
          date: _selectedDate,
          code: _codeController.text,
          shape: _selectedShape,
          country: _country,
          city: _city,
          latitude: _latitude,
          longitude: _longitude,
        );
        if (!updated) {
          throw Exception("Error updating record");
        }

        // If a new image was selected, delete the old one and upload the new one.
        if (_selectedImage != null) {
          String imagePath = 'snowglobe_${widget.snowglobe!.id}.png';
          await _imageService.deleteImage(imagePath);
          final rawUrl = await _imageService.uploadImage(
            _selectedImage!,
            imagePath,
          );
          final publicUrl =
              rawUrl + '?v=${DateTime.now().millisecondsSinceEpoch}';
          await Supabase.instance.client
              .from('snowglobes')
              .update({'image_url': publicUrl})
              .eq('id', widget.snowglobe!.id)
              .select()
              .maybeSingle();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.snowglobe == null
                ? 'Insert completed successfully'
                : 'Update completed successfully',
          ),
        ),
      );
      Navigator.pop(context, true); // Return true to indicate success.
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.snowglobe == null ? 'Insert SnowGlobe' : 'Edit SnowGlobe',
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image preview.
              _selectedImage != null
                  ? Image.file(
                    _selectedImage!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                  : widget.snowglobe != null &&
                      widget.snowglobe!.imageUrl != null &&
                      widget.snowglobe!.imageUrl!.isNotEmpty
                  ? Image.network(
                    widget.snowglobe!.imageUrl!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  )
                  : Container(
                    height: 200,
                    width: 200,
                    color: AppColors.scaffoldBackground,
                    child: Icon(Icons.image, size: 100),
                  ),
              SizedBox(height: 8),
              // Buttons to choose image.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text('Take Photo'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo),
                    label: Text('Gallery'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Form fields.
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter name' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedSize,
                items:
                    <String>[
                      "XS",
                      "S",
                      "M",
                      "L",
                      "XL",
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                decoration: InputDecoration(labelText: 'Size'),
                onChanged: (newValue) {
                  setState(() {
                    _selectedSize = newValue!;
                  });
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please select a size'
                            : null,
              ),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Code'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Enter code' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedShape,
                items:
                    <String>[
                      "Classic",
                      "Heart",
                      "Half Pyramid",
                      "Other",
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                decoration: InputDecoration(labelText: 'Shape'),
                onChanged: (newValue) {
                  setState(() {
                    _selectedShape = newValue!;
                  });
                },
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Please select a shape'
                            : null,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _selectedDate != null
                        ? 'Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}'
                        : 'Select Date',
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Display the selected location provided by the picker.
              Text(
                _city != null &&
                        _country != null &&
                        _city!.isNotEmpty &&
                        _country!.isNotEmpty
                    ? 'Selected location: $_city, $_country'
                    : 'No location selected',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              // Buttons for selecting/clearing the location.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectLocation,
                    icon: Icon(Icons.map),
                    label: Text('Select Location'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _latitude = null;
                        _longitude = null;
                        _city = null;
                        _country = null;
                      });
                    },
                    icon: Icon(Icons.delete),
                    label: Text('Clear Location'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.snowglobe == null ? 'Save' : 'Update'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
