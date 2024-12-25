import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_projects/product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_product_page.dart'; //

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> _products = [];
  List<Map<String, String>> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? productData = prefs.getStringList('products');
    if (productData != null) {
      setState(() {
        print("productData $productData");
        _products =  productData.map((e) => Map<String, String>.from(jsonDecode(e))).toList()
            ;
        _filteredProducts = List.from(_products);
      });
    }
  }

  Future<void> _saveProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> productData = _products.map((e) => e.toString()).toList();
    await prefs.setStringList('products', productData);
  }

  void _filterProducts(String query) {
    setState(() {
      _filteredProducts = _products
          .where((product) => product['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _deleteProduct(int index) async {
    setState(() {
      _products.removeAt(index);
      _filteredProducts = List.from(_products);
    });
    await _saveProducts();
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to Login Page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Products',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(child: Text('No Product Found'))
                : ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ListTile(
                  leading: product['image'] != null
                      ? Image.file(
                    File(product['image']!) ,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.image, size: 50),
                  title: Text(product['name'] ?? ''),
                  subtitle: Text('Price: \$${product['price']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.blue[900]),
                    onPressed: () => _deleteProduct(index),
                  ),
                );
              },
            ),
          ),
          // FloatingActionButton(onPressed: ()=>setState(() {_loadProducts();}), child: Icon(Icons.refresh))
        ],
      ),
        floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () => setState(() {
                  _loadProducts();
                }),
                child: Icon(Icons.refresh,color: Colors.white),
                backgroundColor: Colors.blue[900],
              ),
    SizedBox(width: 10,),
    FloatingActionButton(
      child: Icon(Icons.add,color: Colors.white,),
      onPressed: () async {
        bool? isAdded = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddProductScreen()),
        );
        if (isAdded == true) {
          _loadProducts();
        }
      },
      backgroundColor: Colors.blue[900],

    ),
            ]
        )

    );
  }
}
