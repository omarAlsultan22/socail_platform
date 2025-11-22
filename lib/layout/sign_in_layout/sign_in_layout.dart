import 'package:flutter/material.dart';
import '../../modules/sign_in/cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../modules/sign_up/sign_up_screen.dart';
import '../../../shared/constants/user_details.dart';
import '../../../shared/componentes/public_components.dart';
import 'package:social_app/layout/main_layout/main_layout.dart';
import '../../../shared/networks/local/shared_preferences.dart';
import 'package:social_app/shared/cubit_states/cubit_states.dart';


class SignInLayout extends StatefulWidget {
  const SignInLayout({super.key});

  @override
  State<SignInLayout> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInLayout> {
  bool _isObscure = false;
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> checkLogIn() async {
    String? value = await CacheHelper.getStringValue(key: 'isLoggedIn');
    if (value != null && value.isNotEmpty) {
      UserDetails.uId = value;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogIn();
    emailController.text = 'omaralsultan22@yahoo.com';
    passwordController.text = '254086Aa';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInCubit, CubitStates>(
      listener: (context, state) {
        if (state is SuccessState) {
          checkLogIn();
        }
        if (state is ErrorState) {
          showToast(message: state.error.toString());
        }
      },
      builder: (context, state) {
        var cubit = SignInCubit.get(context);
        return Scaffold(
          backgroundColor: Colors.grey.shade900,
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Social',
                          style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.amber, // تغيير لون الخلفية إلى Amber
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 0.9,
                              horizontal: 4.0,
                            ),
                            child: Text(
                              'Platform',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Form Section
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // Email Field
                          buildInputField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (String? value) {
                              return validator(value, 'Email');
                            },
                            label: 'Email',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          buildInputField(
                            controller: passwordController,
                            keyboardType: TextInputType.text,
                            validator: (String? value) {
                              return validator(value, 'Password');
                            },
                            obscureText: _isObscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure ? Icons.visibility_off : Icons
                                    .visibility,
                                color: Colors.amber,
                              ),
                              onPressed: () =>
                                  setState(() => _isObscure = !_isObscure),
                            ),
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),
                          const SizedBox(height: 30),

                          // Sign In Button
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              // زيادة نصف القطر
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade700,
                                  Colors.amber.shade400,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            width: double.infinity,
                            height: 50.0,
                            child: MaterialButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  cubit.signInEmailAndPassword(
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
                                  );
                                }
                              },
                              child: state is LoadingState
                                  ? const CircularProgressIndicator(
                                  color: Colors.white)
                                  : const Text(
                                'Sign in',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Sign Up Button
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: 'Don\'t have an account? ',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (
                                      context) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


void showToast({
  required String message,
}) {
  Fluttertoast.showToast(
    msg: message,
  );
}

enum ToastStates { SUCCESS, ERROR, WARNING }

Color chooseToastColor(ToastStates state) {
  switch (state) {
    case ToastStates.SUCCESS:
      return Colors.green;
    case ToastStates.ERROR:
      return Colors.red;
    case ToastStates.WARNING:
      return Colors.amber;
    default:
      return Colors.black;
  }
}


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال رابط إعادة التعيين إلى ${_emailController.text
              .trim()}'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';
          break;
        case 'invalid-email':
          errorMessage = 'بريد إلكتروني غير صالح';
          break;
        default:
          errorMessage = 'حدث خطأ غير متوقع. حاول مرة أخرى لاحقاً';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعادة تعيين كلمة المرور'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال البريد الإلكتروني';
                  }
                  if (!value.contains('@')) {
                    return 'بريد إلكتروني غير صالح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  if (_formKey.currentState!.validate()) {
                    _resetPassword();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('إرسال رابط التعيين'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}