import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/States.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';

class Components {
  static Widget reusableText({
    required String content,
    double fontSize = 12.0,
    int maxLines = 1,
    FontWeight fontWeight = FontWeight.normal,
    Color fontColor = Colors.white,
    TextAlign textAlign = TextAlign.center,
  }) => Text(
    content,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      color: fontColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
    ),
  );

  static Widget reusableTextFormField({
    required String hint,
    required IconData prefixIcon,
    TextEditingController? controller,
    IconData? suffixIcon,
    void Function()? suffixIconFunction,
    bool obscureText = false,
    double radius = 10.0,
    Color fontColor = Colors.white,
    Color focusedColor = Colors.greenAccent,
    int maxLines = 1,
    Color hintColor = Colors.white30,
    TextInputType textInputType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    void Function(String)? onChanged,
    TextInputAction textInputAction = TextInputAction.next,
    void Function()? onTap,
    Color fillColor = Colors.black54,
    Widget Function(BuildContext context, EditableTextState editableTextState)?
    contextMenuBuilder,
  }) => TextFormField(
    controller: controller,
    obscureText: obscureText,
    cursorColor: Colors.white,
    keyboardType: textInputType,
    maxLines: maxLines,
    readOnly: readOnly,
    textInputAction: textInputAction,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    onTap: onTap,
    onChanged: onChanged,
    style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
    decoration: InputDecoration(
      filled: true,
      fillColor: fillColor,
      hintStyle: TextStyle(color: hintColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Colors.white54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: focusedColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Colors.red),
      ),
      errorMaxLines: 3,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: (suffixIcon != null)
          ? IconButton(onPressed: suffixIconFunction, icon: Icon(suffixIcon))
          : null,
      hintText: hint,
      prefixIconColor: Colors.teal,
      suffixIconColor: Colors.teal,
    ),
    contextMenuBuilder: contextMenuBuilder,
    validator: (validator == null)
        ? (value) {
            if (value!.isEmpty) {
              return 'must\'t be empty';
            }
            return null;
          }
        : validator,
  );

  static Widget reusableTextButton({
    required text,
    required Function() function,
    double height = 20.0,
    double width = 50.0,
    Color textColor = Colors.white,
    double fontSize = 20.0,
    FontWeight fontWeight = FontWeight.bold,
  }) => GestureDetector(
    onTap: function,
    child: Container(
      alignment: Alignment.center,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: fontWeight,
        ),
      ),
    ),
  );

  static void showSnackBar(
    BuildContext context,
    String message, {
    Color color = Colors.red,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 6),
        width: Constant.screenWidth / 3,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Widget reusablePagination({
    required int totalPages,
    required int currentPage,
    required Function(int pageIndex) onPageChanged,
  }) {
    final pages = List<int>.generate(totalPages, (i) => i);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          onPressed: currentPage > 0
              ? () => onPageChanged(currentPage - 1)
              : null,
          icon: const Icon(Icons.arrow_back),
        ),
        // Page numbers
        ...pages.map((pageIndex) {
          final isCurrent = pageIndex == currentPage;
          return GestureDetector(
            onTap: () => onPageChanged(pageIndex),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCurrent ? Colors.teal : Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${pageIndex + 1}',
                style: TextStyle(
                  color: isCurrent ? Colors.black : Colors.white,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
        // Next button
        IconButton(
          onPressed: currentPage + 1 < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }

  static Future<void> deleteDialog<T extends Cubit<BlocStates>>(
    BuildContext context,
    Future<void> Function() onDelete, {
    String? title,
    String? body,
  }) async {
    final bloc = BlocProvider.of<T>(context);
    await showDialog(
      context: context,
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: BlocListener<T, BlocStates>(
            listener: (context, state) {
              if (state is SuccessState) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            child: AlertDialog(
              backgroundColor: const Color(0xff2b2b2b),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Text(
                title ?? 'Please Confirm',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                body ?? 'Are you sure you want to delete this item?',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                BlocBuilder<T, BlocStates>(
                  builder: (context, state) {
                    if (state is LoadingState) {
                      return const CircularProgressIndicator();
                    }
                    return TextButton(
                      onPressed: () => onDelete(),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
