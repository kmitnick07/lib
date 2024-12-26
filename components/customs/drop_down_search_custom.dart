import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../../view/no_data_found_screen.dart';
import 'custom_selection_dialog.dart';
import 'custom_text_form_field.dart';

class DropDownSearchCustom extends StatefulWidget {
  final List<Map<String, dynamic>?> items;
  final Function(Map<String, dynamic>?) onChanged;
  final String hintText;
  final Map<String, dynamic>? initValue;
  final FormFieldValidator? validator;
  final bool? showAddButton;
  final String? buttonText;
  final Function()? clickOnAddBtn;
  final String? textFieldLabel;
  final String? Function(Map<String, dynamic>?)? dropValidator;
  final bool? isRequire;
  final bool? isSearchable;
  final bool? isCleanable;
  final Function()? clickOnCleanBtn;
  final FocusNode? focusNode;
  final bool? isIcon;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final int? width;
  final EdgeInsets? contentPadding;
  final Function()? onTapOutside;
  final bool? readOnly;
  final bool? canShiftFocus;
  final bool? showPrefixDivider;
  final Color? fillColor;
  final Color? hintColor;
  final Color? borderColor;
  final Color? fontColor;
  final Color? optionFocusHighlightColor;
  final Color? selectedOptionColor;
  final String? staticText;
  final bool? showToolTip;
  final String? toolTipText;

  final FormFieldSetter? onSaved;
  final BuildContext? ctx;
  final Widget? prefixWidget;
  final Widget? titleRowWidget;

  const DropDownSearchCustom({
    super.key,
    required this.items,
    required this.onChanged,
    required this.hintText,
    required this.dropValidator,
    this.initValue,
    this.showToolTip = false,
    this.toolTipText,
    this.validator,
    this.showAddButton = false,
    this.buttonText,
    this.clickOnAddBtn,
    this.textFieldLabel,
    this.isRequire = false,
    this.isSearchable = false,
    this.isCleanable = false,
    this.clickOnCleanBtn,
    this.focusNode,
    this.isIcon = false,
    this.fontSize = 14,
    this.fontWeight,
    this.borderRadius,
    this.contentPadding,
    this.onTapOutside,
    this.readOnly = false,
    this.fillColor,
    this.onSaved,
    this.ctx,
    this.width,
    this.prefixWidget,
    this.hintColor,
    this.borderColor,
    this.canShiftFocus,
    this.fontColor,
    this.optionFocusHighlightColor,
    this.selectedOptionColor,
    this.staticText,
    this.showPrefixDivider,
    this.titleRowWidget,
  });

  @override
  State<DropDownSearchCustom> createState() => _DropDownSearchCustomState();
}

class _DropDownSearchCustomState extends State<DropDownSearchCustom> {
  OptionsViewOpenDirection direction = OptionsViewOpenDirection.down;
  var key1 = GlobalKey();
  bool showMenu = false;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final size = MediaQuery.of(context).size;
      final textFieldRenderBox = key1.currentContext!.findRenderObject() as RenderBox;
      final textFieldSize = textFieldRenderBox.size;
      final offset = textFieldRenderBox.localToGlobal(Offset.zero);
      final isSpaceAvailable = size.height > offset.dy + textFieldSize.height + 300;
      if ( isSpaceAvailable) {
        direction = OptionsViewOpenDirection.down;
      } else {
        direction = OptionsViewOpenDirection.up;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconFocus = FocusNode();
    iconFocus.unfocus();
    bool searching = false;

    TextEditingController textEditingController = TextEditingController(text: widget.staticText ?? widget.initValue?['label'].toString() ?? '');
    List<Map<String, dynamic>> emptyOptions = [{}];

    FocusNode localFocus = FocusNode();

    (widget.focusNode ?? localFocus).addListener(() {
      if (!(widget.focusNode ?? localFocus).hasFocus) {
        textEditingController.text = widget.initValue?['label'] ?? '';
        searching = false;
        showMenu = false;
        setState(() {});
      } else {}
    });

    (widget.focusNode ?? localFocus).onKeyEvent = (node, event) {
      if (event.runtimeType == KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.delete) {
          if (!(widget.readOnly ?? false) && (widget.isCleanable ?? false)) {
            widget.clickOnCleanBtn!();
            textEditingController.text = widget.initValue?['label'] ?? '';
            searching = false;
          }
          return KeyEventResult.handled;
        }
        if (!showMenu && event.logicalKey == LogicalKeyboardKey.enter) {
          showMenu = true;
          setState(() {});
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    (widget.focusNode ?? localFocus).skipTraversal = widget.readOnly ?? false;
    return ResponsiveBuilder(builder: (context, responsive) {
      return LayoutBuilder(
        builder: (context, constraints) => RawAutocomplete(
          key: key1,
          textEditingController: textEditingController,
          focusNode: widget.focusNode ?? localFocus,
          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
            return CustomTextFormField(
              showToolTip: widget.showToolTip,
              toolTipText: widget.toolTipText,
              validator: (value) {
                if (widget.dropValidator != null) {
                  return widget.dropValidator!(widget.initValue);
                }
                return null;
              },
              showTitleRowWidget: widget.showAddButton ?? false,
              titleRowWidget: InkResponse(
                onTap: widget.clickOnAddBtn,
                child: const Icon(
                  Icons.add_circle_outline_rounded,
                  size: 16,
                  color: ColorTheme.kBlack,
                ),
              ),
              readOnly: !(widget.isSearchable ?? true),
              fontColor: widget.fontColor,
              borderColor: widget.borderColor,
              showSuffixDivider: false,
              disableFocusShift: true,
              prefixWidget: widget.prefixWidget,
              textInputType: TextInputType.none,
              disableField: (widget.readOnly ?? false),
              controller: textEditingController,
              focusNode: focusNode,
              textFieldLabel: widget.textFieldLabel,
              isRequire: widget.isRequire,
              onChanged: (p0) {
                showMenu = true;
                searching = true;
              },
              onTap: !responsive.isMobile || (widget.readOnly ?? false)
                  ? () {
                      showMenu = !showMenu;
                      setState(() {});
                    }
                  : () {
                      SelectDialog.showModal(
                        context,
                        label: widget.hintText,
                        searchBoxMaxLines: 1,
                        alwaysShowScrollBar: false,
                        items: List.generate(widget.items.length, (index) => widget.items[index]),
                        selectedValue: widget.initValue,
                        titleStyle: Theme.of(context).textTheme.bodyLarge,
                        emptyBuilder: (context) => const NoDataFoundScreen(height: 100, width: 100),
                        itemBuilder: (context, item, isSelected) => Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(border: BorderDirectional(bottom: BorderSide(color: ColorTheme.kBackGroundGrey))),
                          child: TextWidget(
                            text: item?['label'] ?? '',
                            fontSize: 14,
                            fontWeight: FontTheme.notoMedium,
                            color: isSelected == true ? ColorTheme.kPrimaryColor : ColorTheme.kPrimaryColor.withOpacity(0.5),
                          ),
                        ),
                        onChange: widget.onChanged,
                      );
                    },
              showPrefixDivider: widget.showPrefixDivider ?? true,
              suffixWidget: Visibility(
                visible: (widget.isCleanable ?? false) && widget.initValue != null,
                replacement: IconButton(
                  onPressed: !responsive.isMobile
                      ? () {
                          showMenu = !showMenu;
                          focusNode.requestFocus();
                          setState(() {});
                        }
                      : null,
                  focusNode: FocusNode(skipTraversal: true),
                  splashRadius: 15,
                  padding: EdgeInsets.fromLTRB(widget.contentPadding?.left ?? 5, 0, widget.contentPadding?.right ?? 5, 0),
                  constraints: const BoxConstraints(),
                  icon: Material(
                    color: Colors.transparent,
                    child: showMenu
                        ? Icon(
                            Icons.keyboard_arrow_up_rounded,
                            color: widget.fontColor ?? ColorTheme.kHintTextColor.withOpacity(0.6),
                            size: 18,
                          )
                        : Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: widget.fontColor ?? ColorTheme.kHintTextColor.withOpacity(0.6),
                            size: 18,
                          ),
                  ),
                ),
                child: IconButton(
                  splashRadius: 15,
                  constraints: const BoxConstraints(),
                  focusNode: FocusNode(skipTraversal: true),
                  padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                  icon: Material(
                    color: Colors.transparent,
                    child: Icon(
                      Icons.close_rounded,
                      color: widget.fontColor ?? ColorTheme.kIconColor.withOpacity(0.6),
                      size: 18,
                    ),
                  ),
                  onPressed: !widget.readOnly! ? widget.clickOnCleanBtn : () {},
                ),
              ),
              fillColor: widget.fillColor,
              hintColor: widget.hintColor,
              hintText: widget.hintText,
              onFieldSubmitted: (String value) {
                onFieldSubmitted();
              },
            );
          },
          optionsViewOpenDirection: direction,
          optionsViewBuilder: (context, onSelected, options) {
            if (!showMenu) {
              return const SizedBox.shrink();
            }
            return Align(
              alignment: direction == OptionsViewOpenDirection.up ? Alignment.bottomLeft : Alignment.topLeft,
              child: Material(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.0)),
                  ),
                  elevation: 5,
                  child: Container(
                    width: constraints.maxWidth,
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      maxHeight: 300,
                    ),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2.0)]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Builder(
                            builder: (context) {
                              AutoScrollController scrollController = AutoScrollController();
                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: options.length,
                                controller: scrollController,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  final bool highlight = AutocompleteHighlightedOption.of(context) == index;
                                  final selected = options.toList()[index]['value'] == widget.initValue?['value'];
                                  if (highlight) {
                                    scrollController.scrollToIndex(index, duration: const Duration(milliseconds: 1));
                                  }
                                  return AutoScrollTag(
                                    key: ValueKey(index),
                                    controller: scrollController,
                                    index: index,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: highlight ? widget.optionFocusHighlightColor ?? ColorTheme.kHintTextColor.withOpacity(0.1) : null,
                                      ),
                                      child: options.toList()[index].containsKey('value')
                                          ? ListTile(
                                              tileColor: highlight ? ColorTheme.kHintTextColor.withOpacity(0.1) : null,
                                              onTap: () {
                                                onSelected(options.toList()[index]);
                                              },
                                              title: SubstringHighlight(
                                                text: '${options.toList()[index]['label']}',
                                                textStyle: TextStyle(
                                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                                  fontSize: 14,
                                                  color: selected
                                                      ? widget.selectedOptionColor ?? ColorTheme.kPrimaryColor
                                                      : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                                                ),
                                                term: searching ? textEditingController.text : '',
                                                textStyleHighlight: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: selected ? widget.selectedOptionColor ?? ColorTheme.kPrimaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                                                ),
                                              ))
                                          : Container(
                                              constraints: BoxConstraints(maxWidth: double.parse((widget.width ?? 400).toString())),
                                              height: 80,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(5),
                                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2.0)],
                                              ),
                                              padding: const EdgeInsets.all(8),
                                              child: Center(
                                                child: TextWidget(
                                                  text: 'No ${widget.textFieldLabel.isNullOrEmpty ? 'Data' : widget.textFieldLabel} Found',
                                                  color: ColorTheme.kPrimaryColor,
                                                  fontSize: 16,
                                                  fontWeight: widget.fontWeight ?? FontTheme.notoMedium,
                                                ),
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        // Visibility(
                        //   visible: widget.showAddButton ?? false,
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: CustomButton(
                        //       borderRadius: 8,
                        //       height: 40,
                        //       fontColor: ColorTheme.kWhite,
                        //       onTap: widget.clickOnAddBtn,
                        //       title: '+ Add ${widget.textFieldLabel}',
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  )),
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if ((widget.readOnly ?? false) || responsive.isMobile) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            List<Map<String, dynamic>> matches = <Map<String, dynamic>>[];

            matches.addAll(List<Map<String, dynamic>>.from(widget.items));
            if (searching) {
              matches.retainWhere((s) {
                return s['label'].toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            }
            return matches.isEmpty ? emptyOptions : matches;
          },
          onSelected: (option) async {
            if (emptyOptions.contains(option)) {
              return;
            }
            textEditingController.text = option['label'].toString();
            await widget.onChanged(option);
            if (widget.canShiftFocus ?? true) {
              Future.delayed(const Duration(milliseconds: 100)).then((value) {
                (widget.focusNode ?? localFocus).requestFocus();
                (widget.focusNode ?? localFocus).nextFocus();
              });
            } else {
              (widget.focusNode ?? localFocus).unfocus();
            }
            showMenu = false;
            setState(() {});
          },
        ),
      );
    });
  }
}
