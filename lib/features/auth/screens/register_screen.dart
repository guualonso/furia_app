import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:furia_app/features/auth/controllers/auth_controller.dart';
import 'package:furia_app/features/auth/widgets/auth_text_field.dart';
import 'package:furia_app/features/auth/widgets/document_upload.dart';
import 'package:furia_app/features/auth/widgets/google_auth_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  File? _documentImage;
  File? _selfieImage;
  bool _isLoading = false;
  bool _termsAccepted = false;

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aceite os termos para continuar')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await _authController.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          cpf: _cpfController.text,
          address: _addressController.text,
          documentImage: _documentImage,
          selfieImage: _selfieImage,
        );

        if (!mounted) return;
        context.go('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: true,
          overscroll: false,
        ),
        child: SingleChildScrollView( 
          child: Center( 
            child: SizedBox(
              width: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40), // Ajuste este valor conforme necessário
                      child: SvgPicture.asset(
                        'assets/images/logo-furia.svg',
                        height: 59,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Crie sua Conta',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        letterSpacing: -0.24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Preencha seus dados para se inscrever',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthTextField(
                      controller: _nameController,
                      hintText: 'Nome completo',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _emailController,
                      hintText: 'email@dominio.com',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _passwordController,
                      hintText: 'Senha',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _cpfController,
                      hintText: 'CPF',
                      icon: Icons.badge,
                      keyboardType: TextInputType.number,
                      inputFormatters: [cpfMaskFormatter],
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _addressController,
                      hintText: 'Endereço completo',
                      icon: Icons.home,
                    ),
                    const SizedBox(height: 24),
                    DocumentUpload(
                      label: 'Documento de Identidade (RG/CNH)',
                      file: _documentImage,
                      onPressed: () async {
                        final image = await _authController.pickImage();
                        if (image != null) setState(() => _documentImage = image);
                      },
                    ),
                    const SizedBox(height: 16),
                    DocumentUpload(
                      label: 'Selfie para validação facial',
                      file: _selfieImage,
                      onPressed: () async {
                        final image = await _authController.pickImage();
                        if (image != null) setState(() => _selfieImage = image);
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Inscreva-se',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFE6E6E6))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'ou continue com',
                            style: TextStyle(color: Color(0xFF828282)),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFE6E6E6))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GoogleAuthButton(
                      onPressed: () async {
                        try {
                          final result = await _authController.signInWithGoogle();
                          if (result?.user != null && mounted) {
                            context.go('/home');
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erro no login com Google: $e')),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _termsAccepted,
                              onChanged: (bool? value) {
                                setState(() {
                                  _termsAccepted = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Eu concordo com os',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF828282),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8), // Espaço entre o checkbox e o texto
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20), // Padding abaixo dos termos
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF828282),
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(text: 'Termos de Serviço e '),
                                TextSpan(
                                  text: 'Política de Privacidade',
                                  style: const TextStyle(
                                    color: Color(0xFF3D3B3B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}