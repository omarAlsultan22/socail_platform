import 'package:flutter/material.dart';
import '../../../../../core/utils/validate_input.dart';
import 'package:social_app/core/data/models/message_result.dart';
import 'package:social_app/core/data/models/profile_info_model.dart';
import 'package:social_app/core/presentation/widgets/app_spaces.dart';
import 'package:social_app/core/presentation/widgets/build_input_field.dart';
import 'package:social_app/features/auth/presentation/mixins/auth_mixin.dart';


class UserInfoLayout extends StatefulWidget {
  final Function({
  required String userState,
  required String userWork,
  required String userLive,
  required String userFrom,
  required String userRelational
  }) onUpdate;
  final MessageResult messageResult;
  final ProfileInfoModel profileInfoModel;
  const UserInfoLayout({
    super.key,
    required this.onUpdate,
    required this.messageResult,
    required this.profileInfoModel
  });

  @override
  State<UserInfoLayout> createState() => _UserInfoLayoutState();
}

class _UserInfoLayoutState extends State<UserInfoLayout> with AuthMixin<UserInfoLayout> {
  bool _isLocked = false;

  final _formKey = GlobalKey<FormState>();
  final _stateController = TextEditingController();
  final _workController = TextEditingController();
  final _livesController = TextEditingController();
  final _fromController = TextEditingController();
  final _relationalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _workController.text = widget.profileInfoModel.userWork;
    _fromController.text = widget.profileInfoModel.userFrom;
    _livesController.text = widget.profileInfoModel.userLive;
    _stateController.text = widget.profileInfoModel.userState;
    _relationalController.text = widget.profileInfoModel.userRelational;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    handleMessageResult(
      messageResult: widget.messageResult,
    );
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

  void _updateLockButton(bool value) {
    setState(() => _isLocked = value);
  }

  Future<void> _submitForm() async {
    if (!validateForm(_formKey)) return;
    _updateLockButton(true);
    hideKeyboard(context);
    widget.onUpdate(
      userState: _stateController.text,
      userWork: _workController.text,
      userLive: _livesController.text,
      userFrom: _fromController.text,
      userRelational: _relationalController
          .text,
    ).whenComplete(() {
      if (mounted) {
        _updateLockButton(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    key: _formKey,
                    child: Column(
                        children: [
                          const SizedBox(height: 60.0),
                          BuildInputField.build(
                            controller: _stateController,
                            keyboardType: TextInputType.text,
                            validator: (String? value) {
                              return ValidateInput.validator(
                                  value: value, text: 'state');
                            },
                            label: 'state',
                            icon: Icons.mode_edit,
                          ),
                          AppSpaces.vertical_16,
                          BuildInputField.build(
                            controller: _workController,
                            keyboardType: TextInputType.text,
                            validator: (String? value) {
                              return ValidateInput.validator(
                                  value: value, text: 'Work');
                            },
                            label: 'Work',
                            icon: Icons.work,
                          ),
                          AppSpaces.vertical_16,
                          BuildInputField.build(
                            controller: _livesController,
                            keyboardType: TextInputType.text,
                            validator: (String? value) {
                              return ValidateInput.validator(
                                  value: value, text: 'Lives');
                            },
                            label: 'Lives',
                            icon: Icons.home_filled,
                          ),
                          AppSpaces.vertical_16,
                          BuildInputField.build(
                            controller: _fromController,
                            keyboardType: TextInputType.text,
                            validator: (String? value) {
                              return ValidateInput.validator(
                                  value: value, text: 'From');
                            },
                            label: 'From',
                            icon: Icons.location_on,
                          ),
                          AppSpaces.vertical_16,
                          BuildInputField.build(
                            controller: _relationalController,
                            keyboardType: TextInputType.text,
                            validator: (String? value) {
                              return ValidateInput.validator(
                                  value: value, text: 'Relational');
                            },
                            label: 'Relational',
                            icon: Icons.favorite,
                          ),
                          AppSpaces.vertical_24,
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  5.0),
                              color: Colors.amber[700],
                            ),
                            width: double.infinity,
                            height: 50.0,
                            child: ElevatedButton(
                                style: buttonStyle(),
                                onPressed: _isLocked ? null : _submitForm,
                                child: buildButtonContent(
                                    isLoading: widget.messageResult.isLoading,
                                    text: 'Save')
                            ),
                          ),
                        ]
                    ),
                  ),
                )
            )
        )
    );
  }
}


