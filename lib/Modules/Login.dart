import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Shared/Components.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isPasswordHide = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = Manager.get(context);
    const inputWidth = 350.0;

    return BlocConsumer<Manager, BlocStates>(
      listener: (context, state) {
        if (state is ErrorState) {
          Components.showSnackBar(context, state.error, color: Colors.red);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Constant.scaffoldColor,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('images/logo.png', height: 150),
                      const SizedBox(height: 15),
                      Components.reusableText(
                        content: 'ShapeUp',
                        fontColor: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                      const SizedBox(height: 10),
                      Components.reusableText(
                        content:
                            'Welcome onBoard Manager! Please Login to Continue',
                        maxLines: 2,
                        fontSize: 18,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: inputWidth,
                        child: Components.reusableTextFormField(
                          hint: 'Email',
                          prefixIcon: Icons.email,
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'email is required';
                            }
                            if (!RegExp(Constant.emailRegex).hasMatch(value)) {
                              return 'invalid email format';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: inputWidth,
                        child: Components.reusableTextFormField(
                          hint: 'Password',
                          prefixIcon: Icons.lock,
                          controller: _passwordController,
                          obscureText: _isPasswordHide,
                          suffixIcon: _isPasswordHide
                              ? Icons.visibility
                              : Icons.visibility_off,
                          suffixIconFunction: () {
                            setState(() {
                              _isPasswordHide = !_isPasswordHide;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'password is required';
                            }
                            if (value.length < 8) {
                              return 'must be at least 8 characters';
                            }
                            if (!RegExp(
                              Constant.passwordRegex,
                            ).hasMatch(value)) {
                              return 'Password must contain uppercase, lowercase, digit and special char';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      ConditionalBuilder(
                        condition: state is! LoadingState,
                        builder: (_) => Components.reusableTextButton(
                          text: 'Login',
                          height: 50,
                          width: inputWidth,
                          function: () {
                            if (_formKey.currentState!.validate() &&
                                state is! LoadingState) {
                              manager.login({
                                'email': _emailController.text.trim(),
                                'password': _passwordController.text,
                              });
                            }
                          },
                        ),
                        fallback: (_) => const CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
