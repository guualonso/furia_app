import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cepController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _cpfController = TextEditingController();

  bool _isLoading = false;
  bool _termsAccepted = false;

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você deve aceitar os termos.')),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        final user = userCredential.user;
        if (user != null) {
          await user.updateDisplayName(_nameController.text.trim());

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'cpf': _cpfController.text.trim(),
            'cep': _cepController.text.trim(),
            'address': _addressController.text.trim(),
            'number': _numberController.text.trim(),
            'complement': _complementController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conta criada com sucesso!')),
          );
          context.go('/home');
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.message}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }


  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login com Google realizado!')),
      );
      context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no login com Google: $e')),
      );
    }
  }

  void _onCepChanged(String cep) async {
    final cleanedCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedCep.length == 8) {
      final url = Uri.parse('https://viacep.com.br/ws/$cleanedCep/json/');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!data.containsKey('erro')) {
          setState(() {
            _addressController.text =
                '${data['logradouro']}, ${data['bairro']}, ${data['localidade']} - ${data['uf']}';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CEP não encontrado')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar o CEP')),
        );
      }
    }
  }

  bool _isValidCPF(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11 || RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

    int calcDigit(List<int> digits, int multiplier) {
      var sum = 0;
      for (var i = 0; i < digits.length; i++) {
        sum += digits[i] * (multiplier - i);
      }
      var mod = (sum * 10) % 11;
      return mod == 10 ? 0 : mod;
    }

    final digits = cpf.split('').map(int.parse).toList();
    final d1 = calcDigit(digits.sublist(0, 9), 10);
    final d2 = calcDigit(digits.sublist(0, 10), 11);

    return d1 == digits[9] && d2 == digits[10];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 60),
          child: Center(
            child: SizedBox(
              width: 400,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SvgPicture.asset('assets/images/logo-furia.svg', height: 59),
                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        'Crie sua Conta',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Preencha seus dados para se inscrever',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(_nameController, 'Nome completo'),
                    const SizedBox(height: 16),

                    _buildTextField(_emailController, 'email@dominio.com',
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),

                    _buildTextField(_passwordController, 'Senha', obscureText: true),
                    const SizedBox(height: 16),

                    _buildTextField(_cpfController, 'CPF',
                        keyboardType: TextInputType.number,
                        inputFormatters: [CpfFormatter()],
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Campo obrigatório';
                          if (!_isValidCPF(value)) return 'CPF inválido';
                          return null;
                        }),
                    const SizedBox(height: 16),

                    _buildTextField(_cepController, 'CEP',
                        keyboardType: TextInputType.number,
                        inputFormatters: [CepFormatter()],
                        onChanged: _onCepChanged),
                    const SizedBox(height: 16),

                    _buildTextField(_addressController, 'Endereço', enabled: false),
                    const SizedBox(height: 16),

                    _buildTextField(_numberController, 'Número',
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 16),

                    _buildTextField(_complementController, 'Complemento (opcional)',
                        required: false),
                    const SizedBox(height: 16),

                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: _termsAccepted,
                      onChanged: (value) => setState(() => _termsAccepted = value ?? false),
                      title: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(text: 'Ao continuar com o cadastro, você confirma que leu e aceita os '),
                            TextSpan(
                              text: 'termos de uso e política de privacidade',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Inscreva-se'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 40,
                      child: OutlinedButton.icon(
                        icon: Image.asset('assets/images/logo-google.png', height: 18),
                        label: const Text('Fazer login com o Google'),
                        onPressed: _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool required = true,
    bool enabled = true,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: enabled,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        decoration: _inputDecoration(hintText),
        validator: validator ??
            (required
                ? (value) {
                    if (value == null || value.isEmpty) return 'Campo obrigatório';
                    if (hintText == 'email@dominio.com' &&
                        !value.contains('@')) return 'E-mail inválido';
                    if (hintText == 'Senha' && value.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  }
                : null),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF828282)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDFDFDF)),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}

class CpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 11) {
      digits = digits.substring(0, 11);
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digits[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class CepFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 5) buffer.write('-');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
