import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';

class DocumentUpload extends StatelessWidget {
  final String label;
  final File? file;
  final VoidCallback onPressed;

  const DocumentUpload({
    super.key,
    required this.label,
    required this.file,
    required this.onPressed, Uint8List? fileBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPressed,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDFDFDF)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: file == null
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 40, color: Color(0xFF828282)),
                        Text(
                          'Clique para fazer upload',
                          style: TextStyle(color: Color(0xFF828282)),
                        ),
                      ],
                    ),
                  )
                : Image.file(file!, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}