import 'package:flutter/material.dart';
import 'package:flutter_projects/product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> products = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? productsJson = prefs.getString('products');
    if (productsJson != null) {
      setState(() {
        products = List<Map<String, String>>.from(json.decode(productsJson));
      });
    }
  }

  Future<void> _saveProduct(List<Map<String, String>> productsList) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('products', json.encode(productsList));
  }

  void _deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
    _saveProduct(products);
  }

  void _addProduct(Map<String, String> product) {
    setState(() {
      products.add(product);
    });
    _saveProduct(products);
  }

  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductScreen()),
    );
  }

  void _searchProducts(String query) {
    setState(() {
      products = products.where((product) {
        return product['name']!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = products.where((product) {
      return product['name']!.toLowerCase().contains(searchController.text.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: _searchProducts,
            decoration: InputDecoration(
              labelText: "Search Products",
              labelStyle: TextStyle(fontSize: 14,color: Colors.blueGrey),
              icon: Icon(Icons.search),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey,width: 1), // Normal border color
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0), // Focused border color
              ),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : filteredProducts.isEmpty
              ? Center(child: Text('No Product Found'))
              : Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  title: Text(product['name']!),
                  subtitle: Text(product['price']!),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteProduct(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        child: Icon(Icons.add),
      ),
    );
  }
}
