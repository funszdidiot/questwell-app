import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'questwell_hearth_material.dart';
import 'questwell_typography.dart';

/// The shared interface system. Scene artwork and game state remain separate.
abstract final class QuestwellAppStyle {
  static const background = Color(0xFF201813);
  static const surface = Color(0xFF1D2A32);
  static const ink = Color(0xFFF0E5CC);
  static const muted = Color(0xFFC7C0B0);
  static const brass = QuestwellHearthMaterial.brass;
  static const emerald = QuestwellHearthMaterial.evergreen;
  static const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(3)),
    borderSide: BorderSide(color: brass),
  );

  static ThemeData theme() {
    final base = ThemeData.dark(useMaterial3: false);
    final scheme = base.colorScheme.copyWith(
      primary: const Color(0xFFE4C586),
      onPrimary: background,
      secondary: const Color(0xFF9DBFA5),
      onSecondary: background,
      surface: surface,
      onSurface: ink,
      error: const Color(0xFFFFB4AB),
      outline: brass,
    );
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.robotoTextTheme(base.textTheme)
          .apply(bodyColor: ink, displayColor: ink),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: QuestwellHearthMaterial.serif(20),
        shape: const Border(bottom: BorderSide(color: brass)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: primaryButton()),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButton()),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: QuestwellHearthMaterial.secondaryButton().copyWith(
              minimumSize: const WidgetStatePropertyAll(Size(48, 48)))),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE4C586),
              minimumSize: const Size(48, 48),
              textStyle: QuestwellTypography.control(),
              shape: QuestwellHearthMaterial.shape)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF152129),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: Color(0xFFFFDE98), width: 2)),
        contentPadding: const EdgeInsets.all(14),
        labelStyle: QuestwellTypography.body(color: muted),
        hintStyle: QuestwellTypography.body(color: muted),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surface,
        selectedColor: emerald,
        side: const BorderSide(color: brass),
        shape: QuestwellHearthMaterial.shape,
        labelStyle: QuestwellTypography.control(color: ink),
        secondaryLabelStyle: QuestwellTypography.control(color: ink),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      dialogTheme: DialogThemeData(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              side: BorderSide(color: brass, width: 2)),
          titleTextStyle: QuestwellHearthMaterial.serif(22),
          contentTextStyle: QuestwellTypography.body(fontSize: 16, color: ink)),
      bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
              side: BorderSide(color: brass))),
      snackBarTheme: SnackBarThemeData(
          backgroundColor: surface,
          contentTextStyle: QuestwellTypography.body(color: ink),
          actionTextColor: const Color(0xFFFFDE98),
          shape: const RoundedRectangleBorder(side: BorderSide(color: brass)),
          behavior: SnackBarBehavior.floating),
      dividerColor: const Color(0xFF796747),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: Color(0xFFE4C586)),
    );
  }

  static ButtonStyle primaryButton() =>
      QuestwellHearthMaterial.primaryButton().copyWith(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        textStyle: WidgetStatePropertyAll(QuestwellHearthMaterial.serif(17)),
        backgroundBuilder: (context, states, child) => DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: states.contains(WidgetState.disabled)
                      ? const [Color(0xFF48504A), Color(0xFF303B35)]
                      : const [Color(0xFF386C54), Color(0xFF173D32)]),
              border: Border.all(
                  color: states.contains(WidgetState.disabled)
                      ? const Color(0xFF786E55)
                      : brass),
            ),
            child: child),
      );
}

/// Shared page backdrop, preserving Scaffold keys, app bars and navigation.
class QuestwellScaffold extends Scaffold {
  QuestwellScaffold({
    super.key,
    Widget? body,
    super.appBar,
    super.bottomNavigationBar,
    Color? backgroundColor,
    super.resizeToAvoidBottomInset,
    super.floatingActionButton,
  }) : super(
          backgroundColor: backgroundColor ?? QuestwellAppStyle.background,
          body: body == null ? null : QuestwellHearthTimber(child: body),
        );
}
