import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? icon;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 16,
            color: Color(0xFF828282),
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          prefixIcon: icon != null ? Icon(icon) : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDFDFDF)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) return 'Campo obrigatório';
          if (hintText.contains('email') && !value.contains('@')) return 'E-mail inválido';
          if (hintText.contains('Senha') && value.length < 6) return 'Mínimo 6 caracteres';
          if (hintText.contains('CPF') && value.length < 14) return 'CPF incompleto';
          return null;
        },
      ),
    );
  }
}