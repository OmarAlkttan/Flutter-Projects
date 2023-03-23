import 'dart:io';

import 'package:car_rental/bloc/auth_bloc.dart';
import 'package:car_rental/providers/auth.dart';
import 'package:car_rental/providers/profile.dart';
import 'package:car_rental/screens/car_overview_screen.dart';
import 'package:car_rental/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:firebase_storage/firebase_storage.dart';

class AddProfileScreen extends StatefulWidget {
  static final routeName = '/add_profile';

  @override
  _AddProfileScreenState createState() => _AddProfileScreenState();
}

class _AddProfileScreenState extends State<AddProfileScreen> {
  final _cityFocusNode = FocusNode();

  String? _pImageDownloadUrl = '';

  String? _pLicenseImageDownloadUrl = '';

  File? _pImage, _pLicenseImage;

  ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  var _editingProfile = ProfileItem(
      id: null, name: '', city: '', pImageUrl: '', pLicenseImageUrl: '');

  var _intialValues = {
    'name': '',
    'city': '',
    'pImageUrl': '',
    'pLicenseImageUrl': '',
  };

  bool _isLoading = false;

  bool _isInit = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final String? productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        _editingProfile = Provider.of<Profile>(context, listen: false).profile;
        _intialValues = {
          'name': _editingProfile.name!,
          'city': _editingProfile.city!,
          'pImageUrl': '',
          'pLicenseImageUrl': ''
        };
        _pImageDownloadUrl = _editingProfile.pImageUrl!;
        _pLicenseImageDownloadUrl = _editingProfile.pLicenseImageUrl!;
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _cityFocusNode.dispose();
    super.dispose();
  }

  /*void _updateImageUrl(
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
  }*/

  Future<void> getPImageUrl() async {
    final authBloc = BlocProvider.of<AuthBloc>(context).state;
    Reference? pImageRef;
    if(authBloc is Authenticated && authBloc.token != null){
      pImageRef = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child(authBloc.userId!);
    await pImageRef.putFile(_pImage!);
    }
    
    print(_pImage);

    _pImageDownloadUrl = await pImageRef!.getDownloadURL();

    _editingProfile = ProfileItem(
        id: _editingProfile.id,
        name: _editingProfile.name,
        city: _editingProfile.city,
        pLicenseImageUrl: _editingProfile.pLicenseImageUrl,
        pImageUrl: _pImageDownloadUrl);
    setState(() {});
  }

  Future<void> getPLicenseImageUrl() async {
    final authBloc = BlocProvider.of<AuthBloc>(context).state;
    Reference? pLicenseImagesRef;
    if(authBloc is Authenticated && authBloc.token != null){
      pLicenseImagesRef = FirebaseStorage.instance
        .ref()
        .child('licenses_pictures')
        .child(authBloc.userId!);
    await pLicenseImagesRef.putFile(_pLicenseImage!);
    }
    

    _pLicenseImageDownloadUrl = await pLicenseImagesRef!.getDownloadURL();

    _editingProfile = ProfileItem(
        id: _editingProfile.id,
        name: _editingProfile.name,
        city: _editingProfile.city,
        pLicenseImageUrl: _pLicenseImageDownloadUrl,
        pImageUrl: _editingProfile.pImageUrl);
    setState(() {});
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    if (_pImage == null) {
      print(_pImage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No profile image was selected'),
        ),
      );
      return;
    }
    if (_pLicenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No license card image was selected'),
        ),
      );
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editingProfile.id != null) {
      await Provider.of<Profile>(context, listen: false)
          .updateProfile(_editingProfile);
    } else {
      try {
        print('inside try add profile');
        print(_editingProfile);
        print(_editingProfile.name);
        print(_editingProfile.city);
        print(_editingProfile.pImageUrl);
        print(_editingProfile.pLicenseImageUrl);
        await Provider.of<Profile>(context, listen: false).addProfile(_editingProfile);
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
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }
    setState(() {
      _isLoading = false;
    });
    if (_editingProfile.id == null) {
      Navigator.of(context).pushReplacementNamed(CarsOverviewScreen.routeName);
    } else {
      Navigator.of(context).pop();
    }
  }

  void getpImage(ImageSource src) async {
    final pickedFile =
        await _picker.getImage(source: src);
    setState(() {
      if (pickedFile != null) {
        print(pickedFile.path);
        setState(() {
          _pImage = File(pickedFile.path);
        });
        getPImageUrl();
      } else {
        print('NO IMAGE SELECTED!');
      }
    });
  }

  void getpLicenseImage(ImageSource src) async {
    final pickedFile =
        await _picker.getImage(source: src);
    setState(() {
      if (pickedFile != null) {
        print(pickedFile.path);
        setState(() {
          _pLicenseImage = File(pickedFile.path);
        });
        getPLicenseImageUrl();
      } else {
        print('NO IMAGE SELECTED!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: _editingProfile.id == null
            ? Text(
                'Add Profile Data',
                textAlign: TextAlign.center,
              )
            : Text(
                'Edit Profile',
                textAlign: TextAlign.center,
              ),
        /*actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveForm),
        ],*/
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
            child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: deviceSize.height * 0.02),
                    constraints:
                        BoxConstraints(maxHeight: deviceSize.height * 0.7),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Form(
                        key: _formKey,
                        child: ListView(children: [
                          TextFormField(
                            initialValue: _editingProfile.name,
                            decoration: InputDecoration(labelText: 'Name'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return ('please enter your name');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _editingProfile = ProfileItem(
                                id: _editingProfile.id,
                                name: val,
                                city: _editingProfile.city,
                                pImageUrl: _editingProfile.pImageUrl,
                                pLicenseImageUrl:
                                    _editingProfile.pLicenseImageUrl,
                              );
                            },
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_cityFocusNode);
                            },
                          ),
                          TextFormField(
                            initialValue: _editingProfile.city,
                            decoration: InputDecoration(labelText: 'City'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return ('please enter your city');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              _editingProfile = ProfileItem(
                                id: _editingProfile.id,
                                name: _editingProfile.name,
                                pImageUrl: _editingProfile.pImageUrl,
                                city: val,
                                pLicenseImageUrl:
                                    _editingProfile.pLicenseImageUrl,
                              );
                            },
                            focusNode: _cityFocusNode,
                            textInputAction: TextInputAction.next,
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
                                child: _pLicenseImageDownloadUrl == null
                                    ? Text('Please enter an image URL')
                                    : FittedBox(
                                  child: _pLicenseImageDownloadUrl!.isEmpty
                                      ? Text('NO IMAGE LOADED')
                                      : Image.network(
                                    _pImageDownloadUrl!),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'Enter profile image',
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
                                              getpImage(
                                                  ImageSource.camera);
                                            }),
                                        IconButton(
                                            icon: Icon(
                                              Icons.photo,
                                              color:
                                              Theme.of(context).accentColor,
                                            ),
                                            onPressed: () {
                                              getpImage(
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
                                child: _pLicenseImageDownloadUrl == null
                                    ? Text('Please enter an image URL')
                                    : FittedBox(
                                        child: _pLicenseImageDownloadUrl!.isEmpty
                                            ? Text('NO IMAGE LOADED')
                                            : Image.file(
                                                File(_pLicenseImage!.path),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'Enter license card image',
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
                                              getpLicenseImage(
                                                  ImageSource.camera);
                                              print(_pLicenseImageDownloadUrl);
                                            }),
                                        IconButton(
                                            icon: Icon(
                                              Icons.photo,
                                              color:
                                                  Theme.of(context).accentColor,
                                            ),
                                            onPressed: () {
                                              getpLicenseImage(
                                                  ImageSource.gallery);
                                            }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    onPressed: _saveForm,
                    child:
                        _editingProfile.id == null ? Text('Next') : Text('Save'),
                  ),
                ],
              ),
          ),
    );
  }
}
