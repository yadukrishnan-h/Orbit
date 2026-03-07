import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/files/data/remote_file.dart';

/// Enhanced file item widget with modern UI design
class RemoteFileItem extends StatelessWidget {
  final RemoteFile file;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isInMultiSelectMode;
  final bool isNavigationDisabled;
  final VoidCallback? onToggleSelect;
  final ViewMode viewMode;

  const RemoteFileItem({
    super.key,
    required this.file,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isInMultiSelectMode = false,
    this.isNavigationDisabled = false,
    this.onToggleSelect,
    this.viewMode = ViewMode.list,
  });

  @override
  Widget build(BuildContext context) {
    if (viewMode == ViewMode.grid) {
      return _buildGridItem();
    }
    return _buildListItem();
  }

  Widget _buildListItem() {
    return IgnorePointer(
      ignoring: isNavigationDisabled,
      child: AnimatedOpacity(
        opacity: isNavigationDisabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isInMultiSelectMode ? onToggleSelect : onTap,
            onLongPress: isNavigationDisabled ? null : onLongPress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.border.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Selection checkbox in multi-select mode
                  if (isInMultiSelectMode) ...[
                    Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => onToggleSelect?.call(),
                        activeColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  // File/Folder Icon with thumbnail
                  _buildFileIcon(),
                  const SizedBox(width: 12),
                  // File Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // File Name with hidden indicator
                        Row(
                          children: [
                            if (file.isHidden) ...[
                              Icon(
                                LucideIcons.eyeOff,
                                size: 12,
                                color: AppTheme.textSecondary
                                    .withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                            ],
                            if (file.isLink) ...[
                              Icon(
                                LucideIcons.link,
                                size: 12,
                                color: AppTheme.warning,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                file.name,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: file.isDirectory
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: file.isDirectory
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Metadata row
                        Row(
                          children: [
                            // Permissions badge
                            if (file.permissions.isNotEmpty &&
                                !file.isDirectory) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppTheme.zinc800,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  file.permissions,
                                  style: GoogleFonts.firaCode(
                                    fontSize: 9,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            // Size
                            Text(
                              file.formattedSize,
                              style: AppTheme.infoLabelStyle
                                  .copyWith(fontSize: 11),
                            ),
                            const SizedBox(width: 8),
                            // Modified time
                            Text(
                              '•',
                              style: AppTheme.infoLabelStyle
                                  .copyWith(fontSize: 11),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              file.formattedModified,
                              style: AppTheme.infoLabelStyle
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Navigation chevron for directories
                  if (file.isDirectory && !isInMultiSelectMode)
                    Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem() {
    return IgnorePointer(
      ignoring: isNavigationDisabled,
      child: AnimatedOpacity(
        opacity: isNavigationDisabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: isInMultiSelectMode ? onToggleSelect : onTap,
            onLongPress: isNavigationDisabled ? null : onLongPress,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.15)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.border.withValues(alpha: 0.5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selection overlay in multi-select mode
                  if (isInMultiSelectMode)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Icon(
                          isSelected
                              ? LucideIcons.checkCircle2
                              : LucideIcons.circle,
                          size: 20,
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  // File Icon (large)
                  Center(
                    child: _buildFileIcon(size: 48),
                  ),
                  const SizedBox(height: 12),
                  // File Name
                  Expanded(
                    child: Text(
                      file.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: file.isDirectory
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Size
                  Text(
                    file.formattedSize,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileIcon({double size = 24}) {
    IconData icon;
    Color iconColor;

    if (file.isDirectory) {
      icon = LucideIcons.folder;
      iconColor = AppTheme.primary; // Mint green for folders
    } else {
      iconColor = AppTheme.textSecondary; // Grey for files
      switch (file.fileType) {
        case 'image':
          icon = LucideIcons.image;
          break;
        case 'video':
          icon = LucideIcons.video;
          break;
        case 'audio':
          icon = LucideIcons.music;
          break;
        case 'document':
          icon = LucideIcons.fileText;
          break;
        case 'code':
          icon = LucideIcons.fileCode;
          break;
        case 'archive':
          icon = LucideIcons.fileArchive;
          break;
        case 'config':
          icon = LucideIcons.settings;
          break;
        default:
          icon = LucideIcons.file;
      }
    }

    return Icon(
      icon,
      size: size,
      color: iconColor,
    );
  }
}

/// View mode enum
enum ViewMode { list, grid }
