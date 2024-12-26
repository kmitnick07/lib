import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

Widget commonRefreshIndicator({Future<void> Function()? onRefresh, required Widget child, required SizingInformation sizingInformation}) {
  return sizingInformation.isDesktop || onRefresh == null
      ? child
      : LayoutBuilder(builder: (context, constraints) {
          return RefreshIndicator(
              onRefresh: onRefresh,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: child,
              ));
        });
}
