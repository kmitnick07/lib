library select_dialog;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_text_form_field.dart';
import 'package:prestige_prenew_frontend/style/assets_string.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';

import 'custom_select_bloc.dart';

typedef SelectOneItemBuilderType<T> = Widget Function(BuildContext context, T item, bool isSelected);

typedef ErrorBuilderType<T> = Widget Function(BuildContext context, dynamic exception);
typedef ButtonBuilderType = Widget Function(BuildContext context, VoidCallback onPressed);

class SelectDialog<T> extends StatefulWidget {
  final T? selectedValue;
  final List<T>? multipleSelectedValues;
  final List<T>? itemsList;

  final bool showSearchBox;
  final void Function(T)? onChange;
  final void Function(List<T>)? onMultipleItemsChange;
  final Future<List<T>> Function(String text)? onFind;
  final SelectOneItemBuilderType<T>? itemBuilder;
  final WidgetBuilder? emptyBuilder;
  final WidgetBuilder? loadingBuilder;

  final ButtonBuilderType? okButtonBuilder;
  final ErrorBuilderType? errorBuilder;
  final bool autofocus;
  final bool alwaysShowScrollBar;
  final int searchBoxMaxLines;
  final int searchBoxMinLines;

  final InputDecoration? searchBoxDecoration;
  @Deprecated("Use 'hintText' property from searchBoxDecoration")
  final String? searchHint;
  final String? label;

  final TextStyle? titleStyle;

  final BoxConstraints? constraints;
  final TextEditingController? findController;

  const SelectDialog({
    Key? key,
    this.itemsList,
    this.showSearchBox = true,
    this.onChange,
    this.onMultipleItemsChange,
    this.selectedValue,
    this.multipleSelectedValues,
    this.label,
    this.onFind,
    this.itemBuilder,
    this.searchBoxDecoration,
    this.searchHint,
    this.titleStyle,
    this.emptyBuilder,
    this.okButtonBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.constraints,
    this.autofocus = false,
    this.alwaysShowScrollBar = false,
    this.searchBoxMaxLines = 1,
    this.searchBoxMinLines = 1,
    this.findController,
  }) : super(key: key);

  static Future<T?> showModal<T>(
    BuildContext context, {
    List<T>? items,
    String? label,
    T? selectedValue,
    List<T>? multipleSelectedValues,
    bool showSearchBox = true,
    Future<List<T>> Function(String text)? onFind,
    SelectOneItemBuilderType<T>? itemBuilder,
    void Function(T)? onChange,
    void Function(List<T>)? onMultipleItemsChange,
    InputDecoration? searchBoxDecoration,
    @Deprecated("Use 'hintText' property from searchBoxDecoration") String? searchHint,
    Color? backgroundColor,
    TextStyle? titleStyle,
    WidgetBuilder? emptyBuilder,
    ButtonBuilderType? okButtonBuilder,
    WidgetBuilder? loadingBuilder,
    ErrorBuilderType? errorBuilder,
    BoxConstraints? constraints,
    bool autofocus = false,
    bool alwaysShowScrollBar = false,
    int searchBoxMaxLines = 1,
    int searchBoxMinLines = 1,
    TextEditingController? findController,
    bool useRootNavigator = false,
  }) {
    return showDialog<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder: (context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(vertical: 10),
          contentPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          titlePadding: EdgeInsets.zero,
          content: SelectDialog<T>(
            selectedValue: selectedValue,
            multipleSelectedValues: multipleSelectedValues,
            itemsList: items,
            onChange: onChange,
            onMultipleItemsChange: onMultipleItemsChange,
            onFind: onFind,
            label: label,
            showSearchBox: showSearchBox,
            itemBuilder: itemBuilder,
            searchBoxDecoration: searchBoxDecoration,
            searchHint: searchHint,
            titleStyle: titleStyle,
            emptyBuilder: emptyBuilder,
            okButtonBuilder: okButtonBuilder,
            loadingBuilder: loadingBuilder,
            errorBuilder: errorBuilder,
            constraints: constraints,
            autofocus: autofocus,
            alwaysShowScrollBar: alwaysShowScrollBar,
            searchBoxMaxLines: searchBoxMaxLines,
            searchBoxMinLines: searchBoxMinLines,
            findController: findController,
          ),
        );
      },
    );
  }

  @override
  _SelectDialogState<T> createState() => _SelectDialogState<T>(
        itemsList,
        onChange,
        onMultipleItemsChange,
        multipleSelectedValues?.toList(),
        onFind,
        findController,
      );
}

class _SelectDialogState<T> extends State<SelectDialog<T>> {
  late SelectOneBlocCustom<T> bloc;
  late MultipleItemsBloc<T> multipleItemsBloc;
  void Function(T)? onChange;

  _SelectDialogState(List<T>? itemsList, this.onChange, void Function(List<T>)? onMultipleItemsChange, List<T>? multipleSelectedValues,
      Future<List<T>> Function(String text)? onFind, TextEditingController? findController) {
    bloc = SelectOneBlocCustom(itemsList, onFind, findController);
    multipleItemsBloc = MultipleItemsBloc(multipleSelectedValues, onMultipleItemsChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.autofocus) {
      FocusScope.of(context).requestFocus(bloc.focusNode);
    }
  }

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  bool get isWeb => MediaQuery.of(context).size.width > MediaQuery.of(context).size.height;

  bool get isMultipleItems => widget.onMultipleItemsChange != null;

  BoxConstraints get webDefaultConstraints => const BoxConstraints(maxWidth: 250, maxHeight: 500);

  BoxConstraints get mobileDefaultConstraints => BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.9,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      );

  SelectOneItemBuilderType<T> get itemBuilder {
    return widget.itemBuilder ?? (context, item, isSelected) => ListTile(title: Text(item.toString()), selected: isSelected);
  }

  ButtonBuilderType get okButtonBuilder {
    return widget.okButtonBuilder ?? (context, onPressed) => ElevatedButton(onPressed: onPressed, child: const Text("Ok"));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: BoxConstraints(
        minWidth: Get.width * 0.90,
        maxWidth: Get.width * 0.95,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        minHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      decoration: BoxDecoration(
        color: ColorTheme.kWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      widget.label ?? "",
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: SvgPicture.asset(
                      AssetsString.kError,
                      height: 25,
                      width: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showSearchBox)
            CustomTextFormField(
              controller: bloc.findController,
              focusNode: bloc.focusNode,
              labelText: "Search",
            ).paddingSymmetric(horizontal: 10, vertical: 10),
          Expanded(
            child: StreamBuilder<List<T>?>(
              stream: bloc.filteredListOut,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return widget.errorBuilder?.call(context, snapshot.error) ?? Center(child: Text("Oops. \n${snapshot.error}"));
                } else if (!snapshot.hasData) {
                  return widget.loadingBuilder?.call(context) ?? const Center(child: CircularProgressIndicator());
                } else if (snapshot.data!.isEmpty) {
                  return widget.emptyBuilder?.call(context) ?? const Center(child: Text("No data found"));
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ListView.builder(
                    controller: bloc.scrollController,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data![index];
                      bool isSelected = multipleItemsBloc.selectedItems.contains(item);
                      isSelected = isSelected || item == widget.selectedValue;
                      return InkWell(
                        child: itemBuilder(context, item, isSelected),
                        onTap: () {
                          if (isMultipleItems) {
                            setState(() => (isSelected) ? multipleItemsBloc.unselectItem(item) : multipleItemsBloc.selectItem(item));
                          } else {
                            onChange?.call(item);
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (isMultipleItems)
            okButtonBuilder(context, () {
              multipleItemsBloc.onSelectButtonPressed();
              Navigator.pop(context);
            }),
        ],
      ),
    );
  }
}
