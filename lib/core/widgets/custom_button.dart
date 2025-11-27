import 'package:flutter/material.dart';

import '../../config/theme/app_colors.dart';

enum ButtonType { primary, secondary, outline, ghost }
enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final List<Color>? gradientColors;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.prefixIcon,
    this.suffixIcon,
    this.gradientColors,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 40;
      case ButtonSize.medium:
        return 52;
      case ButtonSize.large:
        return 60;
    }
  }

  EdgeInsets _getPadding() {
    if (padding != null) return padding!;
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 18;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  Widget _buildButton(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton();
      case ButtonType.secondary:
        return _buildSecondaryButton();
      case ButtonType.outline:
        return _buildOutlineButton();
      case ButtonType.ghost:
        return _buildGhostButton();
    }
  }

  Widget _buildPrimaryButton() {
    final colors = gradientColors ?? AppColors.primaryGradient;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: onPressed != null ? colors : [AppColors.textDisabled, AppColors.textDisabled],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(14),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: colors.first.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(14),
          child: Padding(
            padding: _getPadding(),
            child: _buildContent(AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null ? AppColors.surfaceVariant : AppColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(14),
          child: Padding(
            padding: _getPadding(),
            child: _buildContent(
              onPressed != null ? AppColors.textPrimary : AppColors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: onPressed != null ? AppColors.primary : AppColors.textDisabled,
          width: 1.5,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: borderRadius ?? BorderRadius.circular(14),
          child: Padding(
            padding: _getPadding(),
            child: _buildContent(
              onPressed != null ? AppColors.primary : AppColors.textDisabled,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGhostButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: borderRadius ?? BorderRadius.circular(14),
        child: Padding(
          padding: _getPadding(),
          child: _buildContent(
            onPressed != null ? AppColors.primary : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: _getIconSize(),
          height: _getIconSize(),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: _getIconSize(), color: color),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        if (suffixIcon != null) ...[
          const SizedBox(width: 8),
          Icon(suffixIcon, size: _getIconSize(), color: color),
        ],
      ],
    );
  }
}

class IconOnlyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool hasShadow;

  const IconOnlyButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48,
    this.backgroundColor,
    this.iconColor,
    this.hasShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceVariant,
        shape: BoxShape.circle,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Icon(
            icon,
            size: size * 0.5,
            color: iconColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}





