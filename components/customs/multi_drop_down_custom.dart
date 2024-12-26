import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prestige_prenew_frontend/components/customs/custom_selection_dialog.dart';
import 'package:prestige_prenew_frontend/components/customs/text_widget.dart';
import 'package:prestige_prenew_frontend/components/extensions/extensions.dart';
import 'package:prestige_prenew_frontend/config/dev/dev_helper.dart';
import 'package:prestige_prenew_frontend/view/no_data_found_screen.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../style/theme_const.dart';
import 'custom_button.dart';
import 'custom_text_form_field.dart';

class MultiDropDownSearchCustom extends StatefulWidget {
  final List<Map<String, dynamic>?> items;
  final Function(List) onChanged;
  final String hintText;
  final String? staticText;
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
  final List<Map<String, dynamic>> selectedItems;
  final String field;
  final bool? readOnly;
  final double? width;
  final Color? hintColor;
  final Color? filledColor;
  final Color? fontColor;
  final Color? borderColor;
  final Color? optionFocusHighlightColor;
  final Color? selectedOptionColor;
  final Widget? prefixWidget;

  const MultiDropDownSearchCustom({
    super.key,
    required this.items,
    required this.onChanged,
    required this.hintText,
    required this.dropValidator,
    this.initValue,
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
    this.fontWeight = FontWeight.w500,
    required this.selectedItems,
    required this.field,
    this.readOnly = false,
    this.width,
    this.hintColor,
    this.filledColor,
    this.fontColor,
    this.borderColor,
    this.optionFocusHighlightColor,
    this.selectedOptionColor,
    this.staticText,
    this.prefixWidget,
  });

  @override
  State<MultiDropDownSearchCustom> createState() => _MultiDropDownSearchCustomState();
}

class _MultiDropDownSearchCustomState extends State<MultiDropDownSearchCustom> {
  List selectedIds = [];
  List<Map<String, dynamic>?> selectedmultiIds = [];
  List selectedLabels = [];
  bool searching = false;
  AutoScrollController scrollController = AutoScrollController();
  TextEditingController textController = TextEditingController();
  List extraOptions = [];
  int? highlightedIndex;
  bool scrollList = true;
  FocusNode localFocus = FocusNode();
  double scrollOffset = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final size = MediaQuery.of(context).size;
      final textFieldRenderBox = key1.currentContext!.findRenderObject() as RenderBox;
      final textFieldSize = textFieldRenderBox.size;
      final offset = textFieldRenderBox.localToGlobal(Offset.zero);
      final isSpaceAvailable = size.height > offset.dy + textFieldSize.height + 300;
      if (isSpaceAvailable) {
        direction = OptionsViewOpenDirection.down;
      } else {
        direction = OptionsViewOpenDirection.up;
      }
      setState(() {});
    });
    super.initState();
  }

  OptionsViewOpenDirection direction = OptionsViewOpenDirection.down;
  var key1 = GlobalKey();

  bool showMenu = false;

  @override
  Widget build(BuildContext context) {
    (widget.focusNode ?? localFocus).addListener(() {
      if (!(widget.focusNode ?? localFocus).hasFocus) {
        searching = false;
      }
    });

    (widget.focusNode ?? localFocus).onKey = (node, event) {
      if (event.isKeyPressed(LogicalKeyboardKey.delete)) {
        if (!(widget.readOnly ?? false) && (widget.isCleanable ?? false)) {
          selectedLabels.clear();
          selectedIds.clear();
          textController.clear();
          widget.clickOnCleanBtn!();
          setState(() {});
        }
        return KeyEventResult.handled;
      }
      if (!showMenu && event.logicalKey == LogicalKeyboardKey.enter) {
        showMenu = true;
        setState(() {});
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
    (widget.focusNode ?? localFocus).addListener(() {
      if (!(widget.focusNode ?? localFocus).hasFocus) {
        showMenu = false;
        setState(() {});
      } else {}
    });

    (widget.focusNode ?? localFocus).skipTraversal = widget.readOnly ?? false;
    widget.selectedItems.retainWhere((items) {
      return widget.items.indexWhere((element) => element?['value'] == items["${widget.field}id"]) != -1;
    });
    selectedIds = widget.selectedItems.map((e) => e["${widget.field}id"] ?? '').toList();
    selectedLabels = widget.selectedItems.map((e) => e[widget.field] ?? '').toList();
    textController = TextEditingController(text: widget.staticText ?? selectedLabels.join(', '));
    return ResponsiveBuilder(builder: (context, responsive) {
      return LayoutBuilder(
        builder: (context, constraints) => RawAutocomplete(
          key: key1,
          textEditingController: textController,
          focusNode: widget.focusNode ?? localFocus,
          optionsViewOpenDirection: direction,
          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
            return CustomTextFormField(
              mouseCursor: SystemMouseCursors.click,
              width: widget.width,
              validator: (value) {
                if (widget.dropValidator != null) {
                  return widget.dropValidator!(widget.initValue);
                }
                return null;
              },
              showSuffixDivider: false,
              disableFocusShift: true,
              readOnly: true,
              fontColor: widget.fontColor,
              borderColor: widget.borderColor,
              fillColor: widget.filledColor,
              controller: textEditingController,
              focusNode: focusNode,
              textFieldLabel: widget.textFieldLabel,
              isRequire: widget.isRequire,
              onChanged: (p0) {
                searching = true;
                showMenu = true;
                setState(() {});
              },
              onTap: !responsive.isMobile
                  ? () {
                      showMenu = !showMenu;
                      setState(() {});
                    }
                  : () {
                      selectedmultiIds = [];
                      for (int i = 0; i < widget.items.length; i++) {
                        for (int j = 0; j < selectedIds.length; j++) {
                          if (widget.items[i]?['value'] == selectedIds[j]) {
                            selectedmultiIds.add(widget.items[i]);
                          }
                        }
                      }
                      SelectDialog.showModal<Map<String, dynamic>?>(
                        context,
                        label: widget.hintText,
                        searchBoxMaxLines: 1,
                        alwaysShowScrollBar: false,
                        onMultipleItemsChange: (p0) {
                          selectedmultiIds = p0;
                          setState(() {});
                          selectedIds.clear();
                          for (var i = 0; i < selectedmultiIds.length; i++) {
                            if (!selectedIds.contains(selectedmultiIds[i]!['value'])) {
                              selectedIds.add(selectedmultiIds[i]!['value']);
                            }
                          }
                          widget.onChanged(selectedIds);
                        },
                        items: List.generate(widget.items.length, (index) => widget.items[index]),
                        multipleSelectedValues: selectedmultiIds,
                        titleStyle: Theme.of(context).textTheme.bodyLarge,
                        emptyBuilder: (context) => const NoDataFoundScreen(height: 100, width: 100),
                        itemBuilder: (context, item, isSelected) => Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: const BoxDecoration(border: BorderDirectional(bottom: BorderSide(color: ColorTheme.kBackGroundGrey))),
                          child: Row(
                            children: [
                              Icon(isSelected == true ? Icons.check_box_rounded : Icons.crop_square_rounded, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextWidget(
                                  text: item?['label'] ?? '',
                                  fontSize: 14,
                                  fontWeight: FontTheme.notoMedium,
                                  color: isSelected == true ? ColorTheme.kPrimaryColor : ColorTheme.kPrimaryColor.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        okButtonBuilder: (context, onPressed) {
                          return Align(
                            alignment: Alignment.centerRight,
                            child: CustomButton(
                              onTap: onPressed,
                              title: "Done",
                              margin: const EdgeInsets.all(5),
                              borderRadius: 5,
                            ),
                          );
                        },
                      );
                    },
              prefixWidget: widget.prefixWidget,
              showSuffixIcon: widget.prefixWidget != null,
              showPrefixDivider: false,
              suffixWidget: Visibility(
                visible: (widget.isCleanable ?? false) && widget.selectedItems.isNotNullOrEmpty,
                replacement: InkWell(
                  onTap: !responsive.isMobile
                      ? () {
                          showMenu = !showMenu;
                          focusNode.requestFocus();
                          setState(() {});
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Material(
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
                      color: widget.fontColor ?? ColorTheme.kHintTextColor.withOpacity(0.6),
                      size: 18,
                    ),
                  ),
                  onPressed: !widget.readOnly!
                      ? () {
                          selectedLabels.clear();
                          selectedIds.clear();
                          textController.clear();
                          widget.clickOnCleanBtn!();
                        }
                      : () {},
                ),
              ),
              hintText: widget.hintText,
              hintColor: widget.hintColor,
              onFieldSubmitted: (String value) async {
                (widget.focusNode ?? localFocus).requestFocus();
                var options = extraOptions;
                int index = highlightedIndex!;
                var option = options.toList()[index];
                bool selected = selectedIds.contains(option['value']);
                if (selected) {
                  selectedIds.remove(option['value']);
                  selectedLabels.remove(option['label']);
                } else {
                  selectedIds.add(option['value']);
                  selectedLabels.add(option['label']);
                }
                textController = TextEditingController(text: selectedLabels.join(', '));
                await widget.onChanged(selectedIds);

                setState(() {});
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            // optionsList.sort((a, b) {
            //   if (selectedIds.contains(a['value']) && !selectedIds.contains(b['value'])) {
            //     return -1; // a comes before b
            //   } else if (!selectedIds.contains(a['value']) && selectedIds.contains(b['value'])) {
            //     return 1; // b comes before a
            //   } else {
            //     return 0; // order remains unchanged
            //   }
            // });
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              scrollController.jumpTo(scrollOffset);
            });
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
                child: Container(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                  height: min(300, 48.0 * options.length),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2.0)]),
                  child: Column(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            return ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: options.length,
                              controller: scrollController,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                final bool highlight = AutocompleteHighlightedOption.of(context) == index;
                                if (highlight) {
                                  highlightedIndex = index;
                                  if (scrollList) {
                                    scrollController.scrollToIndex(index, duration: const Duration(milliseconds: 1));
                                  }
                                  scrollList = true;
                                }
                                var option = options.toList()[index];
                                bool selected = selectedIds.contains(option['value']);
                                return AutoScrollTag(
                                  key: ValueKey(index),
                                  controller: scrollController,
                                  index: index,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: highlight ? widget.optionFocusHighlightColor ?? ColorTheme.kHintTextColor.withOpacity(0.1) : null,
                                    ),
                                    child: ListTile(
                                      onTap: () async {
                                        if (selected) {
                                          selectedIds.remove(option['value']);
                                          selectedLabels.remove(option['label']);
                                        } else {
                                          selectedIds.add(option['value']);
                                          selectedLabels.add(option['label']);
                                        }
                                        textController = TextEditingController(text: selectedLabels.join(', '));
                                        scrollOffset = scrollController.offset;
                                        await widget.onChanged(selectedIds);
                                        (widget.focusNode ?? localFocus).requestFocus();
                                        scrollList = false;
                                      },
                                      leading: Icon(
                                        selected ? Icons.check_box : Icons.check_box_outline_blank,
                                        color: selected ? widget.selectedOptionColor ?? ColorTheme.kPrimaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                      title: Text(
                                        '${options.toList()[index]['label']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: selected ? widget.selectedOptionColor ?? ColorTheme.kPrimaryColor : Theme.of(context).textTheme.bodyMedium?.color,
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
                      Visibility(
                        visible: widget.showAddButton ?? false,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CustomButton(
                            borderRadius: 8,
                            height: 35,
                            fontColor: ColorTheme.kWhite,
                            onTap: widget.clickOnAddBtn,
                            title: '+ Add ${widget.textFieldLabel}',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (responsive.isMobile || (widget.readOnly ?? false)) {
              extraOptions = List<Map<String, dynamic>>.empty();
              return const Iterable<Map<String, dynamic>>.empty();
            }

            List<Map<String, dynamic>> matches = <Map<String, dynamic>>[];
            matches.addAll(List<Map<String, dynamic>>.from(widget.items));
            if (searching) {
              matches.retainWhere((s) {
                extraOptions = s['label'].toLowerCase().contains(textEditingValue.text.toLowerCase());
                return s['label'].toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            }

            extraOptions = matches;
            matches.sort((a, b) {
              if (selectedIds.contains(a['value']) && !selectedIds.contains(b['value'])) {
                return -1; // a comes before b
              } else if (!selectedIds.contains(a['value']) && selectedIds.contains(b['value'])) {
                return 1; // b comes before a
              } else {
                return 0; // order remains unchanged
              }
            });
            devPrint(matches);
            return matches;
          },
          onSelected: (option) async {},
        ),
      );
    });
  }

  OutlineInputBorder popupTextFieldProps() {
    return OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 1),
      borderRadius: BorderRadius.circular(5.0),
    );
  }
}
