import 'dart:io';

import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/albergue_details/gallery_screen.dart';

import 'package:camino_ninja_flutter/utils/app_theme.dart';
import 'package:camino_ninja_flutter/utils/context_ext.dart';
import 'package:camino_ninja_flutter/utils/image_converter.dart';
import 'package:camino_ninja_flutter/widgets/custom_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker extends StatefulWidget {
  const PhotoPicker({
    required this.onChange,
    this.initialFiles,
    this.galleryRoutePath = '/gallery',
    super.key,
  });
  final List<File>? initialFiles;
  final ValueChanged<List<File>> onChange;
  final String galleryRoutePath;

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final ValueNotifier<List<File>> _selectedFiles = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _selectedFiles.value = widget.initialFiles ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Align(
      alignment: Alignment.topLeft,
      child: ValueListenableBuilder<List<File>>(
        valueListenable: _selectedFiles,
        builder: (context, images, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              const crossAxisCount = 3;
              final itemSize =
                  (constraints.maxWidth - (crossAxisCount - 1) * spacing) /
                      crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  ...images.mapIndexed(
                    (index, data) => _PhotoItem(
                      file: data,
                      size: itemSize,
                      onRemove: () => _removePhoto(index),
                      onTap: () {
                        context.push(
                          widget.galleryRoutePath,
                          extra: GalleryScreenArguments(
                            items: images.map((e) {
                              return GalleryItem(file: e);
                            }).toList(),
                            initialIndex: index,
                          ),
                        );
                      },
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Ink(
                      width: itemSize,
                      height: itemSize,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.gray900 : AppColors.gray200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _onPickPhoto,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/ic_camera.svg',
                              width: 24,
                              color: isDark
                                  ? AppColors.primary80
                                  : AppColors.primary40,
                            ),
                            Text(
                              AppLocalizations.of(context).addPhoto,
                              style: context.textTheme.titleSmall?.copyWith(
                                color: isDark
                                    ? AppColors.primary80
                                    : AppColors.primary40,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _onPickPhoto() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      imageQuality: 100,
      maxWidth: 1920,
    );
    if (images.isEmpty || !mounted) {
      return;
    }
    final result = await showPhotoPreviewBottomSheet(
      context,
      images: images,
      galleryRoutePath: widget.galleryRoutePath,
    );
    if (result != null) {
      final values = List<File>.from(_selectedFiles.value)..addAll(result);
      _selectedFiles.value = values;
      widget.onChange(values);
    }
  }

  void _removePhoto(int index) {
    final values = List<File>.from(_selectedFiles.value)..removeAt(index);
    _selectedFiles.value = values;
    widget.onChange(values);
  }
}

class _PhotoItem extends StatelessWidget {
  const _PhotoItem({
    required this.file,
    required this.size,
    required this.onRemove,
    required this.onTap,
  });
  final double size;
  final File file;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Image.file(
            file,
            fit: BoxFit.cover,
            width: size,
            height: size,
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.transparent,
              child: Ink(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF05252).withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: onRemove,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/ic_trash.svg',
                      width: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<File>?> showPhotoPreviewBottomSheet(
  BuildContext context, {
  required List<XFile> images,
  String galleryRoutePath = '/gallery',
  Stream<bool>? uploadingStream,
  void Function(List<File>)? onConfirm,
  VoidCallback? onCancel,
}) {
  final isDarkMode = context.isDarkMode;
  return showModalBottomSheet<List<File>?>(
    context: context,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
      minHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: isDarkMode ? AppColors.gray800 : Colors.white,
    builder: (context) => PhotoPreviewBottomSheet(
      images: images,
      galleryRoutePath: galleryRoutePath,
      uploadingStream: uploadingStream,
      onConfirm: onConfirm,
      onCancel: onCancel,
    ),
  );
}

class PhotoPreviewBottomSheet extends StatefulWidget {
  const PhotoPreviewBottomSheet({
    required this.images,
    this.galleryRoutePath = '/gallery',
    this.uploadingStream,
    this.onConfirm,
    this.onCancel,
    super.key,
  });
  final List<XFile> images;
  final String galleryRoutePath;
  final void Function(List<File>)? onConfirm;
  final VoidCallback? onCancel;
  final Stream<bool>? uploadingStream;

  @override
  State<PhotoPreviewBottomSheet> createState() =>
      _PhotoPreviewBottomSheetState();
}

class _PhotoPreviewBottomSheetState extends State<PhotoPreviewBottomSheet> {
  List<File?> _files = [];
  final Set<int> _removedIndices = {};

  @override
  void initState() {
    super.initState();
    _initializeFiles();
    _convertImages();
  }

  void _initializeFiles() {
    // Initialize with null placeholders
    _files = List.filled(widget.images.length, null);
  }

  Future<void> _convertImages() async {
    // Convert images one by one with proper yielding to avoid blocking UI
    for (var i = 0; i < widget.images.length; i++) {
      if (_removedIndices.contains(i)) continue;

      try {
        // Add a small delay to allow UI to update
        // ignore: inference_failure_on_instance_creation
        await Future.delayed(const Duration(milliseconds: 50));

        final file = await ImageConverter.convertToJpeg(widget.images[i]);
        if (mounted && !_removedIndices.contains(i)) {
          setState(() {
            _files[i] = file;
          });
        }

        // Yield control back to the UI thread after each conversion
        // ignore: inference_failure_on_instance_creation
        await Future.delayed(const Duration(milliseconds: 10));
      } catch (e) {
        if (mounted && !_removedIndices.contains(i)) {
          setState(() {
            // Mark as failed conversion - could show error state
            _files[i] = null;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final visibleFiles = <MapEntry<int, File?>>[];

    // Build list of visible files (not removed)
    for (var i = 0; i < _files.length; i++) {
      if (!_removedIndices.contains(i)) {
        visibleFiles.add(MapEntry(i, _files[i]));
      }
    }

    return SafeArea(
      bottom: false,
      child: StreamBuilder(
        stream: widget.uploadingStream,
        builder: (context, asyncSnapshot) {
          final isUploading = asyncSnapshot.data ?? false;
          return Container(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: context.getBottomPadding(context, additionalPadding: 8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (isUploading) {
                          widget.onCancel?.call();
                          return;
                        }
                        context.pop();
                      },
                      child: SvgPicture.asset(
                        'assets/ic_close.svg',
                        color:
                            isDark ? AppColors.primary80 : AppColors.primary40,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Column(
                            children: [
                              Text(
                                AppLocalizations.of(context).uploadImages,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                ),
                                itemCount: visibleFiles.length,
                                itemBuilder: (context, index) => LayoutBuilder(
                                  builder: (context, constraints) {
                                    final entry = visibleFiles[index];
                                    final originalIndex = entry.key;
                                    final file = entry.value;

                                    if (file == null) {
                                      // Show loading placeholder while converting
                                      return Container(
                                        width: constraints.maxWidth,
                                        height: constraints.maxWidth,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? AppColors.gray700
                                              : AppColors.gray200,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                isDark
                                                    ? AppColors.primary80
                                                    : AppColors.primary40,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return _PhotoItem(
                                        file: file,
                                        size: constraints.maxWidth,
                                        onRemove: () {
                                          if (isUploading) return;
                                          _removePhoto(originalIndex);
                                        },
                                        onTap: () {
                                          context.push(
                                            widget.galleryRoutePath,
                                            extra: GalleryScreenArguments(
                                              items: visibleFiles.map((e) {
                                                return GalleryItem(
                                                    file: e.value,);
                                              }).toList(),
                                              initialIndex: index,
                                            ),
                                          );
                                        },);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: CustomButton(
                          isLoading: isUploading,
                          text: AppLocalizations.of(context).confirm,
                          onTap: () async {
                            final confirmedFiles = <File>[];
                            for (var i = 0; i < _files.length; i++) {
                              if (!_removedIndices.contains(i) &&
                                  _files[i] != null) {
                                confirmedFiles.add(_files[i]!);
                              }
                            }

                            if (widget.uploadingStream != null &&
                                widget.onConfirm != null) {
                              widget.onConfirm!(confirmedFiles);
                              return;
                            }
                            context.pop(confirmedFiles);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _removePhoto(int originalIndex) {
    setState(() {
      _removedIndices.add(originalIndex);
    });
  }
}
