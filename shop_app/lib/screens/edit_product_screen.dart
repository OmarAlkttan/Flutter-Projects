import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static final routeName = '/edit_product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();

  final _descriptionFocusNode = FocusNode();

  final _imageUrlFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  var _editingProduct =
      Product(id: null, title: '', description: '', price: 0, imageUrl: '');

  var _intialValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  bool _isLoading = false;

  bool _isInit = true;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      if (productId != null) {
        _editingProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _intialValues = {
          'title': _editingProduct.title!,
          'price': _editingProduct.price.toString(),
          'description': _editingProduct.description!,
          'imageUrl': ''
        };
        _imageUrlController.text = _editingProduct.imageUrl!;
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('png') &&
              !_imageUrlController.text.endsWith('jpg') &&
              !_imageUrlController.text.endsWith('jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _formkey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formkey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editingProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editingProduct.id!, _editingProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editingProduct);
      } catch (e) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred!'),
                  content: Text('Something went wrong'),
                  actions: [
                    FlatButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Okay!')),
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _editingProduct.id == null
            ? Text('Add Product')
            : Text('Edit Product'),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(15),
              child: Form(
                key: _formkey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _editingProduct.title,
                      decoration: InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ('please enter a title');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editingProduct = Product(
                          id: _editingProduct.id,
                          title: val,
                          description: _editingProduct.description,
                          price: _editingProduct.price,
                          imageUrl: _editingProduct.imageUrl,
                        );
                      },
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                    ),
                    TextFormField(
                      initialValue: _editingProduct.price.toString(),
                      decoration: InputDecoration(labelText: 'Price'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ('please enter a price');
                        }
                        if (double.tryParse(value) == null) {
                          return ('please enter a valid number');
                        }
                        if (double.parse(value) <= 0) {
                          return ('please enter a number greater than zero');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editingProduct = Product(
                          id: _editingProduct.id,
                          title: _editingProduct.title,
                          description: _editingProduct.description,
                          price: double.parse(val!),
                          imageUrl: _editingProduct.imageUrl,
                        );
                      },
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                    ),
                    TextFormField(
                      initialValue: _editingProduct.description,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ('please enter a description');
                        }
                        if (value.length <= 10) {
                          return ('please enter more than 10 characters');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        _editingProduct = Product(
                          id: _editingProduct.id,
                          title: _editingProduct.title,
                          description: val,
                          price: _editingProduct.price,
                          imageUrl: _editingProduct.imageUrl,
                        );
                      },
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(top: 10, right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.grey),
                          ),
                          child: _imageUrlController.text == null
                              ? Text('Please enter an image URL')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _imageUrlController,
                            decoration:
                                InputDecoration(labelText: 'Image URL'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return ('please enter an image URL');
                              }
                              if (!value.startsWith('http') && !value.startsWith('https')) {
                                return ('please enter a valid URL');
                              }
                              if (!value.endsWith('png') && !value.endsWith('jpg') && !value.endsWith('jpeg')) {
                                return ('please enter a valid image');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _editingProduct = Product(
                                id: _editingProduct.id,
                                title: _editingProduct.title,
                                description: _editingProduct.description,
                                price: _editingProduct.price,
                                imageUrl: val,
                              );
                            },
                            keyboardType: TextInputType.url,
                            focusNode: _imageUrlFocusNode,
                            maxLines: 3,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
