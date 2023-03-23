import 'dart:io';

import 'package:car_rental/providers/auth.dart';
import 'package:car_rental/providers/cars.dart';
import 'package:car_rental/screens/car_overview_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

class EditCarScreen extends StatefulWidget {
  static final routeName = '/edit_car';

  @override
  _EditCarScreenState createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final _priceFocusNode = FocusNode();
  final _modelFocusNode = FocusNode();
  final _yearFocusNode = FocusNode();
  final _colorFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  String _carImageDownloadUrl = '';

  String _carLicenseImageDownloadUrl = '';

  File? _carImage, _carLicenseImage;

  final _formkey = GlobalKey<FormState>();

  final _picker = ImagePicker();

  var _uuid = Uuid();

  String _userId = '';

  var _editingCar =
  Car(id: null, name: '', model: '', price: 0, carImageUrl: '', licenseImageUrl: '', color: '', year: '', description: '', ownerId: '');

  var _intialValues = {
    'name': '',
    'description': '',
    'price': '',
    'carImageUrl': '',
    'model': '',
    'year': '',
    'licenseImageUrl': '',
    'color': '',
  };

  bool _isLoading = false;

  bool _isInit = true;

  @override
  void initState() {
    _userId = Provider.of<Auth>(context, listen: false).userId;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final String? carId = ModalRoute.of(context)!.settings.arguments as String;
      if (carId != null) {
        _editingCar =
            Provider.of<Cars>(context, listen: false).findById(carId);
        _intialValues = {
          'name': _editingCar.name!,
          'price': _editingCar.price.toString(),
          'description': _editingCar.description!,
          'model': _editingCar.model!,
          'year': _editingCar.year!,
          'color': _editingCar.color!,
          'carImageUrl': '',
          'licenseImageUrl': '',
        };
        _carImageDownloadUrl = _editingCar.carImageUrl!;
        _carLicenseImageDownloadUrl = _editingCar.licenseImageUrl!;
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _modelFocusNode.dispose();
    _yearFocusNode.dispose();
    _colorFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl(
      FocusNode imageUrlFocusNode, TextEditingController imageUrlController) {
    if (!imageUrlFocusNode.hasFocus) {
      if ((!imageUrlController.text.startsWith('http') &&
          !imageUrlController.text.startsWith('https')) ||
          (!imageUrlController.text.endsWith('png') &&
              !imageUrlController.text.endsWith('jpg') &&
              !imageUrlController.text.endsWith('jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> getCarImageUrl() async {
    final carImageRef = FirebaseStorage.instance
        .ref()
        .child('car_pictures')
        .child(_uuid.v4());
    await carImageRef.putFile(_carImage!);

    _carImageDownloadUrl = await carImageRef.getDownloadURL();

    _editingCar = Car(
      id: _editingCar.id,
      name: _editingCar.name,
      model: _editingCar.model,
      year: _editingCar.year,
      color: _editingCar.color,
      description: _editingCar.description,
      price: _editingCar.price,
      carImageUrl: _carImageDownloadUrl,
      licenseImageUrl: _editingCar.licenseImageUrl,
      ownerId: _editingCar.ownerId,
    );
    setState(() {});
  }

  Future<void> getCarLicenseImageUrl() async {
    final carLicenseImagesRef = FirebaseStorage.instance
        .ref()
        .child('licenses_pictures')
        .child(_uuid.v4());
    await carLicenseImagesRef.putFile(_carLicenseImage!);
    _carLicenseImageDownloadUrl = await carLicenseImagesRef.getDownloadURL();
    _editingCar =  Car(
      id: _editingCar.id,
      name: _editingCar.name,
      model: _editingCar.model,
      year: _editingCar.year,
      color: _editingCar.color,
      description: _editingCar.description,
      price: _editingCar.price,
      carImageUrl: _editingCar.carImageUrl,
      licenseImageUrl: _carLicenseImageDownloadUrl,
      ownerId: _editingCar.ownerId,
    );
    setState(() {});
  }

  Future<void> _saveForm() async {
    final isValid = _formkey.currentState!.validate();
    if (!isValid) {
      return;
    }
    if (_carImage == null) {
      print(_carImage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No car image was selected'),
        ),
      );
      return;
    }
    if (_carLicenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No license car image was selected'),
        ),
      );
      return;
    }
    _formkey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editingCar.id != null) {
      await Provider.of<Cars>(context, listen: false)
          .updateCar(_editingCar.id! ,_editingCar);
    } else {
      try {
        await Provider.of<Cars>(context, listen: false)
            .addCar(_editingCar);
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
    if (_editingCar.id == null) {
      Navigator.of(context).pushReplacementNamed(CarsOverviewScreen.routeName);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future getCarImage(ImageSource src) async {
    final pickedFile =
    await _picker.getImage(source: src);
    setState(() {
      if (pickedFile != null) {
        print(pickedFile.path);
        _carImage = File(pickedFile.path);
        getCarImageUrl();
      } else {
        print('NO IMAGE SELECTED!');
      }
    });
  }

  Future getCarLicenseImage(ImageSource src) async {
    final pickedFile =
    await _picker.getImage(source: src);
    setState(() {
      if (pickedFile != null) {
        print(pickedFile.path);
        _carLicenseImage = File(pickedFile.path);
        getCarLicenseImageUrl();
      } else {
        print('NO IMAGE SELECTED!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _editingCar.id == null
            ? Text('Add Car')
            : Text('Edit Car'),
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
                initialValue: _editingCar.name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return ('please enter a name');
                  }
                  return null;
                },
                onSaved: (val) {
                  _editingCar = Car(
                    id: _editingCar.id,
                    name: val,
                    model: _editingCar.model,
                    year: _editingCar.year,
                    color: _editingCar.color,
                    description: _editingCar.description,
                    price: _editingCar.price,
                    carImageUrl: _editingCar.carImageUrl,
                    licenseImageUrl: _editingCar.licenseImageUrl,
                    ownerId: _editingCar.ownerId,
                  );
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_modelFocusNode);
                },
              ),
              TextFormField(
                initialValue: _editingCar.model,
                decoration: InputDecoration(labelText: 'Model'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return ('please enter a model');
                  }
                  return null;
                },
                onSaved: (val) {
                  _editingCar = Car(
                    id: _editingCar.id,
                    name: _editingCar.name,
                    model: val,
                    year: _editingCar.year,
                    color: _editingCar.color,
                    description: _editingCar.description,
                    price: _editingCar.price,
                    carImageUrl: _editingCar.carImageUrl,
                    licenseImageUrl: _editingCar.licenseImageUrl,
                    ownerId: _editingCar.ownerId,
                  );
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_yearFocusNode);
                },
              ),
              TextFormField(
                initialValue: _editingCar.year,
                decoration: InputDecoration(labelText: 'Year'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return ('please enter a year');
                  }
                  return null;
                },
                onSaved: (val) {
                  _editingCar = Car(
                    id: _editingCar.id,
                    name: _editingCar.name,
                    model: _editingCar.model,
                    year: val,
                    color: _editingCar.color,
                    description: _editingCar.description,
                    price: _editingCar.price,
                    carImageUrl: _editingCar.carImageUrl,
                    licenseImageUrl: _editingCar.licenseImageUrl,
                    ownerId: _editingCar.ownerId,
                  );
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_colorFocusNode);
                },
              ),
              TextFormField(
                initialValue: _editingCar.name,
                decoration: InputDecoration(labelText: 'Color'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return ('please enter a color');
                  }
                  return null;
                },
                onSaved: (val) {
                  _editingCar = Car(
                    id: _editingCar.id,
                    name: _editingCar.name,
                    model: _editingCar.model,
                    year: _editingCar.year,
                    color: val,
                    description: _editingCar.description,
                    price: _editingCar.price,
                    carImageUrl: _editingCar.carImageUrl,
                    licenseImageUrl: _editingCar.licenseImageUrl,
                    ownerId: _editingCar.ownerId,
                  );
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
              ),
              TextFormField(
                initialValue: _editingCar.price.toString(),
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
                  _editingCar = Car(
                    id: _editingCar.id,
                    name: _editingCar.name,
                    model: _editingCar.model,
                    year: _editingCar.year,
                    color: _editingCar.color,
                    description: _editingCar.description,
                    price: double.parse(val!),
                    carImageUrl: _editingCar.carImageUrl,
                    licenseImageUrl: _editingCar.licenseImageUrl,
                    ownerId: _editingCar.ownerId,
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
                initialValue: _editingCar.description,
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
                  _editingCar = Car(
                    id: _editingCar.id,
                    name: _editingCar.name,
                    model: _editingCar.model,
                    year: _editingCar.year,
                    color: _editingCar.color,
                    description: val,
                    price: _editingCar.price,
                    carImageUrl: _editingCar.carImageUrl,
                    licenseImageUrl: _editingCar.licenseImageUrl,
                    ownerId: _editingCar.ownerId,
                  );
                },
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    margin: EdgeInsets.only(top: 10, right: 8),
                    decoration: BoxDecoration(
                      border:
                      Border.all(width: 2, color: Colors.grey),
                    ),
                    child: FittedBox(
                      child: _carImageDownloadUrl.isEmpty
                          ? Text('NO IMAGE LOADED')
                          : Image.network(
                        _carImageDownloadUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Car image',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.camera_alt_sharp,
                                  color:
                                  Theme.of(context).accentColor,
                                ),
                                onPressed: () {
                                  getCarImage(
                                      ImageSource.camera);

                                }),
                            IconButton(
                                icon: Icon(
                                  Icons.photo,
                                  color:
                                  Theme.of(context).accentColor,
                                ),
                                onPressed: () {
                                  getCarImage(
                                      ImageSource.gallery);

                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    margin: EdgeInsets.only(top: 10, right: 8),
                    decoration: BoxDecoration(
                      border:
                      Border.all(width: 2, color: Colors.grey),
                    ),
                    child: FittedBox(
                      child: _carLicenseImageDownloadUrl.isEmpty
                          ? Text('NO IMAGE LOADED')
                          : Image.network(
                        _carLicenseImageDownloadUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Car License image',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                                icon: Icon(
                                  Icons.camera_alt_sharp,
                                  color:
                                  Theme.of(context).accentColor,
                                ),
                                onPressed: () {
                                  getCarLicenseImage(
                                      ImageSource.camera);
                                }),
                            IconButton(
                                icon: Icon(
                                  Icons.photo,
                                  color:
                                  Theme.of(context).accentColor,
                                ),
                                onPressed: () {
                                  getCarLicenseImage(
                                      ImageSource.gallery);
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
