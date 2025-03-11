import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/view/style.dart';

class MyButton extends StatelessWidget {
  MyButton({
    super.key,
    required this.onTap,
    required this.text,
    this.isLeadingIcon = false,
    this.isTrailingIcon = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  void Function()? onTap;
  final String text;
  bool isLeadingIcon;
  bool isTrailingIcon;
  Icon? leadingIcon;
  Icon? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        // height: 70,
        padding: EdgeInsets.symmetric(vertical: 15),

        decoration: BoxDecoration(
          color: mainColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (isLeadingIcon)
                ? Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: leadingIcon,
                )
                : SizedBox(),
            Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            (isTrailingIcon)
                ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: trailingIcon,
                )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
