import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _addProduct() {
    if (_formKey.currentState?.validate() != true || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image.')),
      );
      return;
    }

    final product = {
      'name': _nameController.text,
      'price': _priceController.text,
      'imagePath': _selectedImage!.path,
    };

    // Save product to SharedPreferences (update your HomeScreen accordingly)
    // Navigate back after adding product
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                value?.isEmpty == true ? 'Product name is required' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value?.isEmpty == true ? 'Price is required' : null,
              ),
              SizedBox(height: 20),
              _selectedImage == null
                  ? Text('No image selected.')
                  : Image.file(
                _selectedImage!,
                height: 100,
                width: 100,
              ),
              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text('Select Image'),
                onPressed: _pickImage,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
