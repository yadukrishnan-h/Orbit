/// Represents a remote file or directory on the server
class RemoteFile {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime? modified;
  final String permissions;
  final String owner;
  final String group;
  final bool isLink;

  RemoteFile({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    this.modified,
    this.permissions = '',
    this.owner = '',
    this.group = '',
    this.isLink = false,
  });

  /// Get formatted file size for display
  String get formattedSize {
    if (isDirectory) {
      // Show folder size or '-' for directories
      if (size < 1024) return '$size B';
      if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
      return '-';
    }
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get formatted modification date for display
  String get formattedModified {
    if (modified == null) return '-';
    final now = DateTime.now();
    final diff = now.difference(modified!);

    // Show relative time for recent files
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    // Show date for older files
    return '${modified!.day.toString().padLeft(2, '0')}/${modified!.month.toString().padLeft(2, '0')}/${modified!.year}';
  }

  /// Get file extension
  String get extension {
    if (isDirectory) return '';
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Check if file is hidden
  bool get isHidden => name.startsWith('.');

  /// Get file type category for icon selection
  String get fileType {
    if (isDirectory) return 'folder';
    if (isLink) return 'link';

    final ext = extension;
    if (_isImageFile(ext)) return 'image';
    if (_isVideoFile(ext)) return 'video';
    if (_isAudioFile(ext)) return 'audio';
    if (_isDocumentFile(ext)) return 'document';
    if (_isCodeFile(ext)) return 'code';
    if (_isArchiveFile(ext)) return 'archive';
    if (_isConfigFile(ext)) return 'config';
    return 'file';
  }

  bool _isImageFile(String ext) {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg', 'webp', 'ico', 'tiff']
        .contains(ext);
  }

  bool _isVideoFile(String ext) {
    return ['mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'm4v']
        .contains(ext);
  }

  bool _isAudioFile(String ext) {
    return ['mp3', 'wav', 'flac', 'aac', 'ogg', 'wma', 'm4a', 'opus']
        .contains(ext);
  }

  bool _isDocumentFile(String ext) {
    return [
      'pdf',
      'doc',
      'docx',
      'txt',
      'rtf',
      'odt',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'csv',
      'md'
    ].contains(ext);
  }

  bool _isCodeFile(String ext) {
    return [
      'js',
      'ts',
      'dart',
      'py',
      'java',
      'cpp',
      'c',
      'h',
      'cs',
      'php',
      'rb',
      'go',
      'rs',
      'swift',
      'kt',
      'html',
      'css',
      'scss',
      'json',
      'xml',
      'yaml',
      'yml',
      'sh',
      'bash'
    ].contains(ext);
  }

  bool _isArchiveFile(String ext) {
    return ['zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz', 'pkg', 'deb', 'rpm']
        .contains(ext);
  }

  bool _isConfigFile(String ext) {
    return ['conf', 'cfg', 'ini', 'env', 'toml'].contains(ext);
  }
}
