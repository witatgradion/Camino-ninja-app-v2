import 'package:camino_ninja_flutter/app/cubit/app_cubit.dart';
import 'package:camino_ninja_flutter/l10n/arb/app_localizations.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/announcement_detail/cubit/announcement_detail_cubit.dart';
import 'package:camino_ninja_flutter/widgets/camino_ninja_title.dart';
import 'package:camino_ninja_flutter/widgets/loading_widget.dart';
import 'package:camino_ninja_flutter/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:camino_ninja_flutter/utils/date_time_ext.dart';
import 'package:remote_data/remote_data.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  const AnnouncementDetailScreen({
    required this.announcementId,
    super.key,
  });

  final int announcementId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnnouncementDetailCubit(
        announcementId: announcementId,
        onMarkedAsRead: () {
          if (context.mounted) {
            context.read<AppCubit>().refreshNotificationsBadge();
          }
        },
      )..loadAnnouncement(),
      child: Scaffold(
        appBar: CaminoNinjaAppBar(
          title: AppLocalizations.of(context)
              .announcementDetail,
        ),
        body: BlocBuilder<AnnouncementDetailCubit,
            AnnouncementDetailState>(
          builder: (context, state) {
            if (state.status ==
                    AnnouncementDetailStatus.loading ||
                state.status ==
                    AnnouncementDetailStatus.initial) {
              return const Center(child: LoadingWidget());
            }
            if (state.status ==
                    AnnouncementDetailStatus.failure ||
                state.announcement == null) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)
                      .errorLoadingAnnouncements,
                ),
              );
            }
            return _AnnouncementDetailBody(
              announcement: state.announcement!,
            );
          },
        ),
      ),
    );
  }
}

class _AnnouncementDetailBody extends StatefulWidget {
  const _AnnouncementDetailBody({
    required this.announcement,
  });

  final AnnouncementResponse announcement;

  @override
  State<_AnnouncementDetailBody> createState() =>
      _AnnouncementDetailBodyState();
}

class _AnnouncementDetailBodyState
    extends State<_AnnouncementDetailBody> {
  late QuillController _quillController;

  @override
  void initState() {
    super.initState();
    _quillController = _buildController();
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  QuillController _buildController() {
    final content = widget.announcement.content;
    if (content != null && content['ops'] != null) {
      try {
        final ops = _sanitizeOps(content['ops'] as List);
        final doc = Document.fromJson(ops);
        return QuillController(
          document: doc,
          selection:
              const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } catch (_) {
        // Fallback to empty document
      }
    }
    return QuillController.basic();
  }

  /// Normalizes color attributes in Delta ops to formats
  /// supported by flutter_quill (named colors, #hex, rgba).
  ///
  /// Converts unsupported formats like `rgb(r, g, b)` to
  /// `#hex` to prevent "Color code not supported" errors.
  List<dynamic> _sanitizeOps(List<dynamic> ops) {
    return ops.map((op) {
      if (op is! Map<String, dynamic>) return op;
      final attributes = op['attributes'];
      if (attributes is! Map<String, dynamic>) return op;

      var changed = false;
      final sanitized = Map<String, dynamic>.from(attributes);

      for (final key in ['color', 'background']) {
        final value = sanitized[key];
        if (value is String) {
          final normalized = _normalizeColor(value);
          if (normalized != value) {
            sanitized[key] = normalized;
            changed = true;
          }
        }
      }

      if (!changed) return op;
      return <String, dynamic>{...op, 'attributes': sanitized};
    }).toList();
  }

  /// Converts unsupported color strings to #hex format.
  String _normalizeColor(String color) {
    // rgb(r, g, b) → #hex
    final rgbMatch = RegExp(
      r'^rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)$',
    ).firstMatch(color);
    if (rgbMatch != null) {
      final r = int.parse(rgbMatch.group(1)!);
      final g = int.parse(rgbMatch.group(2)!);
      final b = int.parse(rgbMatch.group(3)!);
      return '#${r.toRadixString(16).padLeft(2, '0')}'
          '${g.toRadixString(16).padLeft(2, '0')}'
          '${b.toRadixString(16).padLeft(2, '0')}';
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        formatIsoDate(widget.announcement.createdAt);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.announcement.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            dateStr,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Divider(height: 24),
          QuillEditor.basic(
            controller: _quillController,
            config: QuillEditorConfig(
              showCursor: false,
              enableInteractiveSelection: false,
              onLaunchUrl: (url) async {
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  try {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.inAppBrowserView,
                    );
                  } catch (e) {
                    AppLogger.e(
                      'Failed to open URL in-app',
                      tag: 'AnnouncementDetail',
                      error: e,
                    );
                  }
                }
              },
              embedBuilders:
                  FlutterQuillEmbeds.editorBuilders(
                imageEmbedConfig: QuillEditorImageEmbedConfig(
                  onImageClicked: (_) {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
