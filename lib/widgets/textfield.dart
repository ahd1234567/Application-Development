import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? hint;
  final void Function()? ontap;
  final bool? obscureText;
  final bool? readonly;
  final TextInputType? keyboard;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? preicon;
  final Widget? suficon;

  const CustomTextField({
    super.key,
    this.hint,
    this.obscureText,
    this.keyboard,
    this.controller,
    this.validator,
    this.preicon,
    this.suficon,
    this.ontap,
    this.readonly,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: TextFormField(
        readOnly: readonly ?? false,
        onTap: ontap,
        controller: controller,
        validator: validator,
        keyboardType: keyboard ?? TextInputType.text,
        obscureText: obscureText ?? false,
        cursorColor: const Color.fromARGB(255, 255, 94, 1),
        decoration: InputDecoration(
          prefixIcon: preicon,
          suffixIcon: suficon,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 255, 94, 1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 255, 94, 1),
            ),
          ),
        ),
      ),
    );
  }
}
