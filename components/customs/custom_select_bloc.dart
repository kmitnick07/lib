import 'package:flutter/cupertino.dart';
import 'package:select_dialog/rxdart.dart';

class SelectOneBlocCustom<T> {
  final _filter$ = BehaviorSubject.seeded("");
  final focusNode = FocusNode();
  final scrollController = ScrollController();
  late TextEditingController findController;
  late BehaviorSubject<List<T>?> _list$;

  late Stream<List<T>?> filteredListOut;
  late Stream<List<T>?> _filteredListOnlineOut;
  late Stream<List<T>?> _filteredListOfflineOut;
  String get filterValue => _filter$.value ?? "";

  SelectOneBlocCustom(List<T>? items, Future<List<T>?> Function(String text)? onFind, TextEditingController? findController) {
    this.findController = findController ?? TextEditingController();
    _list$ = BehaviorSubject.seeded(items);

    _filteredListOfflineOut = CombineLatestStream.combine2(_list$, _filter$, filter);
    _filteredListOnlineOut =
        _filter$.where((_) => onFind != null).distinct().debounceTime(const Duration(milliseconds: 500)).switchMap((val) => Stream.fromFuture(onFind!(val)).startWith(null));
    filteredListOut = MergeStream([_filteredListOfflineOut, _filteredListOnlineOut]);

    this.findController.addListener(() => onTextChanged(this.findController.text));
    onTextChanged(this.findController.text);
  }

  void onTextChanged(String filter) {
    _filter$.add(filter.toLowerCase());
  }

  List<T>? filter(List<T>? list, String filter) {
    return list?.where((item) => _filter$.value == null || item.toString().toLowerCase().contains(filterValue) || filterValue.isEmpty).toList();
  }

  void dispose() {
    _filter$.close();
    _list$.close();
    focusNode.dispose();
    scrollController.dispose();
  }
}

class MultipleItemsBloc<T> {
  final void Function(List<T>)? onMultipleItemsChange;
  MultipleItemsBloc(
    List<T>? initialSelectedItems,
    this.onMultipleItemsChange,
  ) {
    selectedItems = initialSelectedItems ?? <T>[];
  }

  late List<T> selectedItems;

  void selectItem(T item) {
    if (!selectedItems.contains(item)) selectedItems.add(item);
  }

  void unselectItem(T item) {
    if (selectedItems.contains(item)) selectedItems.remove(item);
  }

  void onSelectButtonPressed() {
    onMultipleItemsChange?.call(selectedItems);
  }
}
