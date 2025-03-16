// lib/screens/snowglobe_insertion_page.dart
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
import 'map_picker_page.dart';
import '../models/snowglobe.dart';

class SnowglobeInsertionPage extends StatefulWidget {
  @override
  _SnowglobeInsertionPageState createState() => _SnowglobeInsertionPageState();
}

class _SnowglobeInsertionPageState extends State<SnowglobeInsertionPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  // Controller per i campi del form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _shapeController = TextEditingController();
  DateTime? _selectedDate;

  // Informazioni sulla posizione
  double? _latitude;
  double? _longitude;
  String? _city;
  String? _country;

  final SnowglobeService _snowglobeService = SnowglobeService();

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
          toolbarTitle: 'Ritaglia immagine',
          toolbarColor: Colors.deepPurpleAccent,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: Colors.deepPurpleAccent,
          statusBarColor: Colors.black,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Ritaglia immagine',
          aspectRatioLockEnabled: true,
        ),
      ],
    );
    if (cropped != null) {
      File croppedFile = File(cropped.path);
      // Ridimensiona l'immagine a 2048x2048
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
      throw Exception("Errore nel decodificare l'immagine");
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
    // Naviga alla pagina della mappa e attendi il risultato
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPickerPage()),
    );
    if (result != null && result is Map) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];
      });
      // Simula il reverse geocoding
      Map<String, String> location = await _reverseGeocode(
        _latitude!,
        _longitude!,
      );
      setState(() {
        _city = location['city'];
        _country = location['country'];
      });
    }
  }

  // Funzione di reverse geocoding di esempio (in un'app reale sostituisci con una chiamata a un'API)
  Future<Map<String, String>> _reverseGeocode(double lat, double lng) async {
    return {'city': 'Dummy City', 'country': 'Dummy Country'};
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
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
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Completa tutti i campi e seleziona un\'immagine')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Snowglobe? snowglobe;

    try {
      // Inserisci il record nel database senza image_url
      snowglobe = await _snowglobeService.insertSnowglobe(
        name: _nameController.text,
        size: _sizeController.text,
        date: _selectedDate,
        code: _codeController.text,
        shape: _shapeController.text,
        country: _country,
        city: _city,
        latitude: _latitude,
        longitude: _longitude,
      );

      if (snowglobe == null) {
        throw Exception("Errore nell'inserimento del record");
      }

      // Carica l'immagine sul bucket Supabase
      await Supabase.instance.client.storage
          .from('snowglobe_images')
          .upload('snowglobe_${snowglobe.id}.png', _selectedImage!);

      // Ottieni l'URL pubblico dell'immagine
      final publicUrl = Supabase.instance.client.storage
          .from('snowglobe_images')
          .getPublicUrl('snowglobe_${snowglobe.id}.png');

      // Aggiorna il record con l'URL dell'immagine
      final updateResponse = await Supabase.instance.client
          .from('snowglobes')
          .update({'image_url': publicUrl})
          .eq('id', snowglobe.id)
          .select()
          .maybeSingle();

      if (updateResponse == null) {
        throw Exception('Errore nell\'aggiornamento dell\'immagine: ${updateResponse ?? updateResponse}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inserimento completato con successo')),
      );
      Navigator.pop(context);
    } catch (e) {
      // Se esiste già un record inserito, lo eliminiamo
      if (snowglobe != null) {
        final deleteResponse = await Supabase.instance.client
            .from('snowglobes')
            .delete()
            .eq('id', snowglobe.id);
        if (deleteResponse == null) {
          print("Errore nella cancellazione del record: $deleteResponse");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e. Il record inserito è stato eliminato.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _codeController.dispose();
    _shapeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inserisci Snowglobe')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Anteprima dell'immagine
              _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 100),
                    ),
              SizedBox(height: 8),
              // Bottoni per scegliere l'immagine
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt),
                    label: Text('Scatta foto'),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.photo),
                    label: Text('Galleria'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Campi del form
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.isEmpty ? 'Inserisci il nome' : null,
              ),
              TextFormField(
                controller: _sizeController,
                decoration: InputDecoration(labelText: 'Dimensione'),
                validator: (value) => value == null || value.isEmpty ? 'Inserisci la dimensione' : null,
              ),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(labelText: 'Codice'),
                validator: (value) => value == null || value.isEmpty ? 'Inserisci il codice' : null,
              ),
              TextFormField(
                controller: _shapeController,
                decoration: InputDecoration(labelText: 'Forma'),
                validator: (value) => value == null || value.isEmpty ? 'Inserisci la forma' : null,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _selectedDate != null
                        ? 'Data: ${_selectedDate!.toLocal().toString().split(' ')[0]}'
                        : 'Seleziona data',
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Visualizza la posizione selezionata (sopra i bottoni)
              Text(
                _city != null && _country != null
                    ? 'Posizione selezionata: $_city, $_country'
                    : 'Nessuna posizione selezionata',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              // Bottoni per selezionare/cancellare la posizione
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _selectLocation,
                    icon: Icon(Icons.map),
                    label: Text('Seleziona luogo'),
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
                    label: Text('Cancella luogo'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: _submit, child: Text('Salva')),
            ],
          ),
        ),
      ),
    );
  }
}
