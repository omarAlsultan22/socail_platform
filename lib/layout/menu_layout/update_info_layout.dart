import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/shared/componentes/constants.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';
import '../../modules/profile_screen/cubit.dart';
import '../../shared/componentes/public_components.dart';

class UpdateInfo extends StatefulWidget {
  const UpdateInfo({super.key});

  @override
  State<UpdateInfo> createState() => _UpdateInfoState();
}

class _UpdateInfoState extends State<UpdateInfo> {
  final formKey = GlobalKey<FormState>();
  final _stateController = TextEditingController();
  final _workController = TextEditingController();
  final _livesController = TextEditingController();
  final _fromController = TextEditingController();
  final _relationalController = TextEditingController();
  late ProfileCubit _cubit;
  bool result = false;

  Future <void> getData() async {
    if (_cubit.profileInfoList == null) {
      await _cubit.getInfo(uid: UserDetails.uId);
    }
  }

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit.get(context, key: const ValueKey('myProfile'));
    getData();
  }

  @override
  void dispose() {
    super.dispose();
    _stateController.dispose();
    _workController.dispose();
    _livesController.dispose();
    _fromController.dispose();
    _relationalController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, CubitStates>(
      listener: (context, state) {
        if (state is SuccessState && state.stateKey == StatesKeys.updateInfo) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Updated successfully'),
                backgroundColor: Colors.green[800]!),
          );
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context);
          });
        }
      },
      builder: (context, state) {
        final info = _cubit.profileInfoList;
        _stateController.text = info?.userState ?? '';
        _workController.text = info?.userWork ?? '';
        _livesController.text = info?.userLive ?? '';
        _fromController.text = info?.userFrom ?? '';
        _relationalController.text = info?.userRelational ?? '';

        if (_cubit.profileInfoList == null) {
          return Center(
              child: CircularProgressIndicator(color: Colors.amber,));
        }

        return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              scrolledUnderElevation: 0,
              elevation: 0,
              title: const Text(
                'Update Info',
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
                child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                            children: [
                              const SizedBox(height: 60.0),
                              buildInputField(
                                controller: _stateController,
                                keyboardType: TextInputType.text,
                                validator: (String? value) {
                                  return validator(value, 'state');
                                },
                                label: 'state',
                                icon: Icons.mode_edit,
                              ),
                              sizedBox(),
                              buildInputField(
                                controller: _workController,
                                keyboardType: TextInputType.text,
                                validator: (String? value) {
                                  return validator(value, 'Work');
                                },
                                label: 'Work',
                                icon: Icons.work,
                              ),
                              sizedBox(),
                              buildInputField(
                                controller: _livesController,
                                keyboardType: TextInputType.text,
                                validator: (String? value) {
                                  return validator(value, 'Lives');
                                },
                                label: 'Lives',
                                icon: Icons.home_filled,
                              ),
                              sizedBox(),
                              buildInputField(
                                controller: _fromController,
                                keyboardType: TextInputType.text,
                                validator: (String? value) {
                                  return validator(value, 'From');
                                },
                                label: 'From',
                                icon: Icons.location_on,
                              ),
                              sizedBox(),
                              buildInputField(
                                controller: _relationalController,
                                keyboardType: TextInputType.text,
                                validator: (String? value) {
                                  return validator(value, 'Relational');
                                },
                                label: 'Relational',
                                icon: Icons.favorite,
                              ),
                              sizedBox(),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      5.0),
                                  color: Colors.amber[700],
                                ),
                                width: double.infinity,
                                height: 50.0,
                                child: MaterialButton(
                                  onPressed: () {
                                    if (formKey.currentState!
                                        .validate()) {
                                      setState(() {
                                        result = true;
                                      });
                                      _cubit.updateProfileInfo(
                                        userState: _stateController.text,
                                        userWork: _workController.text,
                                        userLive: _livesController.text,
                                        userFrom: _fromController.text,
                                        userRelational: _relationalController
                                            .text,
                                      ).whenComplete(() {
                                        if (mounted) {
                                          setState(() =>
                                          result = false);
                                        }
                                      });
                                    }
                                  },
                                  child: result ? const Center(
                                      child: CircularProgressIndicator()
                                  ) : const Center(
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]
                        ),
                      ),
                    )
                )
            )
        );
      },
    );
  }
}


