import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

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

  void _addProduct() async{
    if (_formKey.currentState?.validate() != true || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select an image.')),
      );
      return;
    }


    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      List<String>? productData = prefs.getStringList('products');
      List products = productData != null
          ? productData.map((e) => jsonDecode(e)).toList()
          : [];


      String productName = _nameController.text.trim();
      if (products.any((product) => product['name'] == productName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product already exists")),
        );
        return;
      }


      final newProduct = {
        'name': productName,
        'price': _priceController.text.trim(),
        'imagePath': _selectedImage?.path ?? '',
      };
      products.add(newProduct);


      List<String> updatedProductData =
      products.map((product) => jsonEncode(product)).toList();


      await prefs.setStringList('products', updatedProductData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product added successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
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
