import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../modules/sign_in/sign_in/sign_in.dart';
import '../../modules/menu_screen/cubit.dart';
import '../../shared/componentes/constants.dart';
import '../../shared/componentes/public_components.dart';
import '../../shared/cubit_states/cubit_states.dart';
import 'change_email_&_password.dart';

class UpdateAccount extends StatefulWidget {
  const UpdateAccount({super.key});

  @override
  State<UpdateAccount> createState() => _UpdateAccountState();
}

class _UpdateAccountState extends State<UpdateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppModelCubit.get(context).getAccount(UserDetails.uId);
  }

  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppModelCubit, CubitStates>(
      listener: (context, state)
    {
      if (state is SuccessState && state.stateKey == StatesKeys.updateAccount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated successfully'),
              backgroundColor: Colors.green[800]!),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignIn()),
          );
        });
      }
      if (state is ErrorState && state.stateKey == StatesKeys.updateAccount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${state.error}'),
              backgroundColor: Colors.red[800]!),
        );
      }
    },
      builder: (context, state) {
        final cubit = AppModelCubit.get(context);
        if (state is ErrorState && state.stateKey == StatesKeys.getAccount) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'An error occurred: ${state.error}',
                  style: TextStyle(color: Colors.red[400], fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => cubit.getAccount(UserDetails.uId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is ModelSuccessState && state.stateKey == StatesKeys.getAccount) {
           _firstNameController.text = state.model.firstName;
           _lastNameController.text = state.model.lastName;
           _phoneNumberController.text = state.model.userPhone!;

          return Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                scrolledUnderElevation: 0,
                elevation: 0,
                title: const Text(
                  'Update Account',
                  style: TextStyle(color: Colors.white),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                ),
              ),
              body: _buildFormContent(context, cubit),
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        );
      },
    );
  }

  Widget _buildFormContent(BuildContext context, AppModelCubit cubit) {
    return IgnorePointer(
      ignoring: _isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 32),
              _buildInputField(
                controller: _firstNameController,
                label: "User Name",
                hint: "User Name",
                icon: Icons.person,
                validator: (value) => _validateInput(value, 'User Name'),
              ),
              sizedBox(),
              _buildInputField(
                controller: _lastNameController,
                label: "Last Name",
                hint: "Last Name",
                icon: Icons.person,
                keyboardType: TextInputType.phone,
                validator: (value) => _validateInput(value, 'Last Name'),
              ),
              sizedBox(),
              _buildInputField(
                controller: _phoneNumberController,
                label: "Phone Number",
                hint: "Phone Number",
                icon: Icons.phone,
                validator: (value) => _validateInput(value, 'Phone Number'),
              ),
              const SizedBox(height: 24),
              _buildChangePasswordButton(),
              const SizedBox(height: 16),
              _buildUpdateButton(cubit),
              if (_isLoading) ...[
                const SizedBox(height: 24),
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.amber[400],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Update your personal information',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        buildInputField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(icon, color: Colors.amber[700]),
            filled: true,
            fillColor: Colors.grey[700]!.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.amber[700]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChangeEmailAndPassword(),
            ),
          );
        },
        child: Text(
          'Change email and password',
          style: TextStyle(
            fontSize: 18,
            color: Colors.amber[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(AppModelCubit cubit) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[700],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            setState(() => _isLoading = true);
            cubit.updateAccount(
              firstName: _firstNameController.text,
              lastName: _lastNameController.text,
              phone: _phoneNumberController.text,
            ).whenComplete(() {
              if (mounted) setState(() => _isLoading = false);
            });
          }
        },
        child: const Text(
          'Update',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String? _validateInput(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
}

