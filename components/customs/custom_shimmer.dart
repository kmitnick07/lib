import 'package:flutter/material.dart';
import 'package:prestige_prenew_frontend/style/theme_const.dart';
import 'package:shimmer/shimmer.dart';

class CustomShimmer extends StatelessWidget {
  CustomShimmer({
    super.key,
    required this.child,
    this.isLoading = false,
  });

  bool isLoading = false;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: ColorTheme.kShimmerBaseColor,
        highlightColor: ColorTheme.kShimmerHighlightColor,
        child: child,
      );
    }
    return child;
  }
}
