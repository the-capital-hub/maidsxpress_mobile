// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:maidxpress/utils/appcolors/app_colors.dart';
import '../textwidget/text_widget.dart';

class DropDownWidget extends StatefulWidget {
  final String hintText;
  final String? value;
  final String? label; // Fixed typo: lable -> label
  final List<String> statusList;
  final Function(String?) onChanged;
  final double? circleVal;
  final double? height;
  final String? valText;
  final bool? isReadOnly;

  const DropDownWidget({
    Key? key,
    required this.hintText,
    required this.value,
    this.label,
    required this.statusList,
    required this.onChanged,
    this.circleVal,
    this.valText,
    this.isReadOnly,
    this.height,
  }) : super(key: key);

  @override
  _DropDownWidgetState createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          TextWidget(
            text: widget.label!,
            textSize: 12,
            maxLine: 2,
            fontWeight: FontWeight.w500,
          ),
        if (widget.label != null) const SizedBox(height: 8),
        Container(
          height: widget.height ?? 50,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.circleVal ?? 10),
                borderSide: BorderSide(color: AppColors.blackBorder, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.circleVal ?? 10),
                borderSide: BorderSide(color: AppColors.blackBorder, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.circleVal ?? 10),
                borderSide: BorderSide(color: AppColors.blackBorder, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.circleVal ?? 10),
                borderSide: BorderSide(color: AppColors.blackBorder, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(widget.circleVal ?? 10),
                borderSide: BorderSide(color: AppColors.blackBorder, width: 1),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
            hint: TextWidget(
              text: widget.hintText,
              textSize: 12,
              color: AppColors.black54,
            ),
            value: widget.value,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.black54,
            ),
            iconEnabledColor: AppColors.black,
            iconDisabledColor: AppColors.black,
            isDense: true,
            borderRadius: BorderRadius.circular(4),
            dropdownColor: Colors.grey.shade100,
            items: widget.statusList.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: TextWidget(
                  text: value,
                  color: AppColors.black,
                  textSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              );
            }).toList(),
            onChanged: widget.isReadOnly != null && widget.isReadOnly!
                ? null
                : widget.onChanged,
            validator: (value) {
              if ((value == null || value.isEmpty) && widget.valText != null) {
                return widget.valText;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
