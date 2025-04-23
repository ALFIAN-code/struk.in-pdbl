import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:strukin/controller/splitpage_controller.dart';

class ParticipantItem extends StatefulWidget {
  const ParticipantItem({
    super.key,
    required this.imgPath,
    required this.name,
    this.onClose,
    this.onNameChanged,
    required this.isLast,
    required this.isSelected,
    required this.onSelected,
  });
  final bool isSelected;
  final bool isLast;
  final String imgPath;
  final String name;
  final void Function()? onClose;
  final void Function(String)? onNameChanged;
  final void Function()? onSelected;

  @override
  _ParticipantItemState createState() => _ParticipantItemState();
}

class _ParticipantItemState extends State<ParticipantItem> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool isEditing = false;

  var splitController = Get.find<SplitpageController>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.name);
    _focusNode = FocusNode();

    // Listener untuk mendeteksi ketika kehilangan fokus
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _saveAndCloseEditing();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveAndCloseEditing() {
    setState(() {
      isEditing = false;
    });
    if (_controller.text.isNotEmpty) {
      widget.onNameChanged?.call(_controller.text);
    } else {
      widget.onNameChanged?.call(widget.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('participant item di rebuild');
    return Column(
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  widget.onSelected?.call();
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          widget.isSelected
                              ? Colors.lightGreen
                              : Colors.transparent,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    child: ClipOval(
                      child: Image.asset(
                        widget.imgPath,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    print(widget.isLast);
                    widget.isLast ? null : widget.onClose!.call();
                  });
                },
                child: Container(
                  height: 22,
                  width: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(190),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isEditing = true;
            });
            _focusNode.requestFocus(); // Fokus ke TextField saat diklik
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isEditing
                  ? ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 60,
                      maxHeight: 50,
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      maxLines: 2,
                      maxLength: 20,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      onTapOutside: (event) {
                        _saveAndCloseEditing();
                        isEditing = false;
                      },
                      onSubmitted: (value) => _saveAndCloseEditing(),
                    ),
                  )
                  : ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 50,
                      maxHeight: 50,
                    ),
                    child: Text(
                      widget.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
              SizedBox(width: 5),
              Icon(Icons.border_color, size: 15, color: Colors.black45),
            ],
          ),
        ),
      ],
    );
  }
}
