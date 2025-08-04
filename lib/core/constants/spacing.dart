import 'package:flutter/material.dart';

/// Material Design 3 spacing constants following the 8dp grid system
class AppSpacing {
  // Base spacing values
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;
  static const double space64 = 64.0;
  
  // Screen margins
  static const double screenMarginHorizontal = 16.0;
  static const double screenMarginVertical = 16.0;
  
  // Section spacing
  static const double betweenSectionsSmall = 16.0;
  static const double betweenSectionsMedium = 24.0;
  static const double betweenSectionsLarge = 32.0;
  
  // Component spacing
  static const double betweenCards = 12.0;
  static const double betweenListItems = 8.0;
  static const double betweenChips = 8.0;
  
  // Common EdgeInsets
  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);
  static const EdgeInsets screenPaddingHorizontal = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
  
  // Section padding
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets sectionTitlePadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  
  // SizedBox helpers
  static const SizedBox verticalSpace4 = SizedBox(height: 4.0);
  static const SizedBox verticalSpace8 = SizedBox(height: 8.0);
  static const SizedBox verticalSpace12 = SizedBox(height: 12.0);
  static const SizedBox verticalSpace16 = SizedBox(height: 16.0);
  static const SizedBox verticalSpace24 = SizedBox(height: 24.0);
  static const SizedBox verticalSpace32 = SizedBox(height: 32.0);
  
  static const SizedBox horizontalSpace4 = SizedBox(width: 4.0);
  static const SizedBox horizontalSpace8 = SizedBox(width: 8.0);
  static const SizedBox horizontalSpace12 = SizedBox(width: 12.0);
  static const SizedBox horizontalSpace16 = SizedBox(width: 16.0);
  static const SizedBox horizontalSpace24 = SizedBox(width: 24.0);
}