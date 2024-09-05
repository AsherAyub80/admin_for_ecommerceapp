import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceadmin/Widget/custom_drawer.dart';
import 'package:ecommerceadmin/auth/auth_provider.dart';
import 'package:ecommerceadmin/screens/dashboard_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _title, _description;
  double? _price;
  File? _imageFile;
  String _selectedCategory = 'Electronics'; // Default category
  List<Color> _selectedColors = [];
  String? _storeName;

  final ImagePicker _picker = ImagePicker();
  final List<String> _categories = [
    'Electronics',
    'Shoes',
    'Men Fashion',
    'Women Fashion',
    'Jewelry',
    'Beauty'
  ];

  @override
  void initState() {
    super.initState();
    _fetchStoreName();
  }

  Future<void> _fetchStoreName() async {
    try {
      final authProviders = Provider.of<AuthProviders>(context, listen: false);
      await authProviders.fetchUserDetails();
      setState(() {
        _storeName = authProviders.storeName;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch store details: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef =
        FirebaseStorage.instance.ref().child('product_images/$fileName');

    try {
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _saveProductToFirestore(String imageUrl) async {
    CollectionReference products =
        FirebaseFirestore.instance.collection('products');

    List<String> colorHex = _selectedColors
        .map((color) => '#${color.value.toRadixString(16)}')
        .toList();
    final authProviders = Provider.of<AuthProviders>(context, listen: false);
    final storeId = authProviders.storeId;
    await products.add({
      'title': _title,
      'description': _description,
      'price': _price,
      'store': _storeName,
      'storeId': storeId,
      'category': _selectedCategory,
      'colors': colorHex,
      'image': imageUrl,
      'rate': 0.0,
      'reviews': [],
      'quantity': 1,
    });
  }

  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_imageFile != null && _selectedColors.isNotEmpty) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
              children: const [
                CircularProgressIndicator(),
                SizedBox(width: 10),
                Text('Uploading...')
              ],
            ),
            duration: Duration(days: 1),
          ));

          // Upload the image and get the URL
          String imageUrl = await _uploadImageToFirebase(_imageFile!);

          // Save the product with the image URL and selected colors
          await _saveProductToFirestore(imageUrl);

          // Hide the loading indicator and show success message
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product uploaded successfully')));

          // Clear form and image selection
          _formKey.currentState!.reset();
          setState(() {
            _imageFile = null;
            _selectedCategory = 'Electronics'; // Reset to default category
            _selectedColors = []; // Reset selected colors
          });
        } catch (e) {
          // Hide the loading indicator and show error message
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload product: $e')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_imageFile == null
                ? 'Please select an image'
                : 'Please select at least one color')));
      }
    }
  }

  void _selectColors() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Colors'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: Colors.blue,
              onColorChanged: (Color color) {
                setState(() {
                  if (!_selectedColors.contains(color)) {
                    _selectedColors.add(color);
                  }
                });
              },
              availableColors: [
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
                Colors.black,
                Colors.white,
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorPreview() {
    return _selectedColors.isEmpty
        ? const Text('No colors selected')
        : Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _selectedColors
                .map((color) => Container(
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(30)),
                      width: 40,
                      height: 40,
                    ))
                .toList(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Upload products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: FaIcon(FontAwesomeIcons.barsStaggered),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: _imageFile == null
                      ? Center(child: Text('No image selected'))
                      : Image.file(_imageFile!),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Select Image'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) => _title = value,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) => _description = value,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) => _price = double.tryParse(value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 10),
                _buildColorPreview(),
                ElevatedButton(
                  onPressed: _selectColors,
                  child: const Text('Select Colors'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _uploadProduct,
                  child: const Text('Upload Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
