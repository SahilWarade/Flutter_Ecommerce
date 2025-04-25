import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  AddEditProductScreen({this.product});

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _price = 0.0;
  String _description = '';
  File? _imageFile;
  String? _imagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _title = widget.product!.title;
      _price = widget.product!.price;
      _description = widget.product!.description;
      if (widget.product!.imagePath != null) {
        _imageFile = File(widget.product!.imagePath!);
        _imagePath = widget.product!.imagePath;
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Save the image to app's storage
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');
      setState(() {
        _imageFile = savedImage;
        _imagePath = savedImage.path;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      _formKey.currentState!.save();
      final newProduct = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch,
        title: _title,
        price: _price,
        description: _description,
        imagePath: _imagePath,
      );
      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (widget.product == null) {
        provider.addProduct(newProduct);
      } else {
        provider.editProduct(widget.product!.id, newProduct);
      }
      Navigator.of(context).pop();
    } else if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter a price' : null,
                onSaved: (value) => _price = double.parse(value!),
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Enter a description' : null,
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 16),
              _imageFile != null
                  ? Image.file(_imageFile!, height: 100, fit: BoxFit.cover)
                  : Text('No image selected'),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image from Gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}