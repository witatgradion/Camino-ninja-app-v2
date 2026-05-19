import 'dart:convert';
import 'dart:io';

import 'package:analytics_services/analytics_services.dart';
import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/tabs/route/screens/review_feedback/review_feedback_type.dart';
import 'package:camino_ninja_flutter/utils/camino_util.dart';
import 'package:camino_ninja_flutter/utils/client_context.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'review_feedback_state.dart';

class ReviewFeedbackCubit extends Cubit<ReviewFeedbackState>
    with SafeEmitMixin {
  ReviewFeedbackCubit() : super(const ReviewFeedbackState());

  final Repository _repository = GetIt.instance<Repository>();

  Future<void> init(
    ReviewFeedbackType type, {
    int? albergueId,
    int? cityId,
    File? screenshot,
  }) async {
    final userrCredential = await _repository.getCredential();
    safeEmit(
      state.copyWith(
        type: type,
        albergueId: albergueId,
        cityId: cityId,
        attachments: screenshot != null ? [screenshot] : null,
        isLoggedIn: userrCredential.isLoggedIn,
      ),
    );
  }

  void setName(String name) {
    safeEmit(state.copyWith(name: name, isNameEmpty: false));
  }

  void setEmail(String email) {
    safeEmit(state.copyWith(email: email, isEmailInvalid: false));
  }

  void setAddress(String address) {
    safeEmit(state.copyWith(address: address, isAddressEmpty: false));
  }

  void setFeedback(String feedback) {
    safeEmit(
      state.copyWith(
        feedback: feedback,
        isFeedbackEmpty: feedback.isEmpty,
      ),
    );
  }

  void setRating(double rating) {
    final ratingInvalid = rating <= 0;
    safeEmit(
      state.copyWith(
        rating: rating,
        ratingInvalid: ratingInvalid,
      ),
    );
  }

  void setAttachments(List<File> attachments) {
    safeEmit(state.copyWith(attachments: attachments));
  }

  /// Toggle for the bug-report-only "include stage plan data"
  /// checkbox. The default in [ReviewFeedbackState] is `false`
  /// (informed-consent default). Wired to the UI checkbox via
  /// `onChanged`.
  void setIncludeDbDump(bool value) {
    safeEmit(state.copyWith(includeDbDump: value));
  }

  void submit() {
    switch (state.type) {
      case ReviewFeedbackType.missingAccommodation:
        submitMissingAccommodation();
        return;
      case ReviewFeedbackType.feedbackAlbergue:
        submitFeedback();
        return;
      case ReviewFeedbackType.reviewAlbergue:
        submitReview();
        return;
      case ReviewFeedbackType.bugReport:
      case ReviewFeedbackType.bugReportInMoreTab:
        submitShakeToReport();
        return;
    }
  }

  Future<void> submitFeedback() async {
    if (state.albergueId == null) return;
    final isFeedbackEmpty = state.feedback.isEmpty;
    if (state.isLoggedIn) {
      if (isFeedbackEmpty) {
        safeEmit(
          state.copyWith(
            isFeedbackEmpty: isFeedbackEmpty,
          ),
        );
        return;
      }
    }
    {
      final isEmailInvalid = !CaminoUtil.isValidEmail(state.email ?? '') &&
          (state.email?.isNotEmpty ?? false);
      if (isFeedbackEmpty || isEmailInvalid) {
        safeEmit(
          state.copyWith(
            isFeedbackEmpty: isFeedbackEmpty,
            isEmailInvalid: isEmailInvalid,
          ),
        );
        return;
      }
    }

    safeEmit(
      state.copyWith(
        submitStatus: SubmitReviewFeedbackStatus.submitting,
      ),
    );
    try {
      await _repository.createAlbergueFeedback(
        albergueId: state.albergueId!,
        feedback: state.feedback,
        images: state.attachments,
        email: state.email,
        name: state.name,
      );
      GetIt.instance<IAnalyticsService>().track(
        FeedbackSubmittedEvent(
          albergueId: state.albergueId!,
          comment: state.feedback,
          submitterName: state.name,
          email: state.email,
          attachments: state.attachments?.length,
        ),
      );
      safeEmit(
        state.copyWith(
          submitStatus: SubmitReviewFeedbackStatus.submitted,
        ),
      );
    } catch (e) {
      GetIt.instance<IAnalyticsService>().track(
        FeedbackSubmitErrorEvent(
          albergueId: state.albergueId!,
          comment: state.feedback,
          submitterName: state.name,
          email: state.email,
          attachments: state.attachments?.length,
          error: e.toString(),
        ),
      );
      safeEmit(
        state.copyWith(
          submitStatus: SubmitReviewFeedbackStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> submitReview() async {
    if (state.albergueId == null) return;

    final isFeedbackEmpty = state.feedback.isEmpty;
    final ratingInvalid = state.rating <= 0;
    if (isFeedbackEmpty || ratingInvalid) {
      safeEmit(
        state.copyWith(
          isFeedbackEmpty: isFeedbackEmpty,
          ratingInvalid: ratingInvalid,
        ),
      );
      return;
    }
    safeEmit(
      state.copyWith(
        submitStatus: SubmitReviewFeedbackStatus.submitting,
      ),
    );
    try {
      await _repository.createAlbergueReview(
        albergueId: state.albergueId!,
        comment: state.feedback,
        rating: state.rating.toInt(),
        images: state.attachments,
        email: (state.email?.isEmpty ?? true) ? null : state.email,
        name: (state.name?.isEmpty ?? true) ? null : state.name,
      );
      GetIt.instance<IAnalyticsService>().track(
        ReviewSubmittedEvent(
          albergueId: state.albergueId!,
          rating: state.rating.toInt(),
          comment: state.feedback,
          submitterName: state.name,
          email: state.email,
          attachments: state.attachments?.length,
        ),
      );
      safeEmit(
        state.copyWith(
          submitStatus: SubmitReviewFeedbackStatus.submitted,
        ),
      );
    } catch (e) {
      GetIt.instance<IAnalyticsService>().track(
        ReviewSubmitErrorEvent(
          albergueId: state.albergueId!,
          rating: state.rating.toInt(),
          comment: state.feedback,
          submitterName: state.name,
          email: state.email,
          attachments: state.attachments?.length,
          error: e.toString(),
        ),
      );
      safeEmit(
        state.copyWith(
          submitStatus: SubmitReviewFeedbackStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> submitMissingAccommodation() async {
    if (state.cityId == null) return;
    final isFeedbackEmpty = state.feedback.isEmpty;
    final isNameEmpty = state.name?.isEmpty ?? true;
    final isAddressEmtpty = state.address.isEmpty;
    if (isFeedbackEmpty || isNameEmpty || isAddressEmtpty) {
      safeEmit(
        state.copyWith(
          isFeedbackEmpty: isFeedbackEmpty,
          isNameEmpty: isNameEmpty,
          isAddressEmpty: isAddressEmtpty,
        ),
      );
      return;
    }

    safeEmit(
      state.copyWith(
        submitStatus: SubmitReviewFeedbackStatus.submitting,
      ),
    );
    try {
      await _repository.reportMissingAlbergue(
        cityId: state.cityId!,
        reportDetails: state.feedback,
        images: state.attachments,
        email: state.email,
        name: state.name,
        address: state.address,
      );
      GetIt.instance<IAnalyticsService>().track(
        MissingAlbergueReportedEvent(
          cityId: state.cityId,
          reportDetails: state.feedback,
          submitterName: state.name,
          email: state.email,
          attachments: state.attachments?.length,
        ),
      );
      safeEmit(
        state.copyWith(
          submitStatus: SubmitReviewFeedbackStatus.submitted,
        ),
      );
    } catch (e) {
      GetIt.instance<IAnalyticsService>().track(
        MissingAlbergueReportErrorEvent(
          cityId: state.cityId,
          reportDetails: state.feedback,
          submitterName: state.name,
          email: state.email,
          attachments: state.attachments?.length,
          error: e.toString(),
        ),
      );
      safeEmit(
        state.copyWith(
          submitStatus: SubmitReviewFeedbackStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> submitShakeToReport() async {
    final isFeedbackEmpty = state.feedback.isEmpty;

    if (state.isLoggedIn) {
      if (isFeedbackEmpty) {
        safeEmit(
          state.copyWith(
            isFeedbackEmpty: isFeedbackEmpty,
          ),
        );
        return;
      }
    } else {
      final isEmailInvalid = !CaminoUtil.isValidEmail(state.email ?? '') &&
          (state.email?.isNotEmpty ?? false);
      if (isFeedbackEmpty || isEmailInvalid) {
        safeEmit(
          state.copyWith(
            isFeedbackEmpty: isFeedbackEmpty,
            isEmailInvalid: isEmailInvalid,
          ),
        );
        return;
      }
    }

    safeEmit(
      state.copyWith(
        submitStatus: SubmitReviewFeedbackStatus.submitting,
      ),
    );

    // Build the optional DB-dump attachment first. If the export
    // fails we deliberately swallow the error and continue without
    // the attachment — the user's primary intent here is filing
    // the bug, not attaching a DB. We log the failure for forensics
    // and ship the bug report with `includesDbDump = false` so the
    // analytics event reflects what actually went out.
    var dbDumpFile = await _maybeBuildDbDump();
    final includesDbDumpFinal = dbDumpFile != null;

    // Always attempt to attach client_context. Capture failures
    // are non-fatal (returns null) — the bug report still ships
    // without the diagnostic blob rather than blocking on it.
    final clientContextJson = await _buildClientContextJson();

    try {
      await _repository.createBugReport(
        text: state.feedback,
        images: state.attachments,
        email: state.email,
        dbDump: dbDumpFile,
        clientContext: clientContextJson,
      );
      GetIt.instance<IAnalyticsService>().track(
        BugReportSubmittedEvent(
          comment: state.feedback,
          submitterName: state.name,
          email: state.email,
          attachments: state.attachments?.length,
          includesDbDump: includesDbDumpFinal,
        ),
      );
      safeEmit(
        state.copyWith(
          submitStatus: SubmitReviewFeedbackStatus.submitted,
        ),
      );
    } catch (e) {
      GetIt.instance<IAnalyticsService>().track(
        BugReportSubmitErrorEvent(
          comment: state.feedback,
          submitterName: state.name,
          email: state.email,
          attachments: state.attachments?.length,
          includesDbDump: includesDbDumpFinal,
          error: e.toString(),
        ),
      );
      safeEmit(
        state.copyWith(
          submitStatus: SubmitReviewFeedbackStatus.error,
          error: e.toString(),
        ),
      );
    } finally {
      // Best-effort cleanup of the on-device export — the upload
      // already finished (success or failure) by this point. The
      // OS will eventually purge the temp dir anyway, but tidying
      // up immediately avoids accumulating zips on Android where
      // the cache dir is not auto-purged.
      if (dbDumpFile != null) {
        try {
          if (dbDumpFile.existsSync()) {
            await dbDumpFile.delete();
          }
        } catch (e) {
          AppLogger.w(
            'Failed to delete bug-report DB dump: $e',
            tag: 'ReviewFeedbackCubit',
          );
        }
        dbDumpFile = null;
      }
    }
  }

  /// Captures triage context (`ClientContext`) and returns a
  /// JSON-encoded string suitable for the `client_context` multipart
  /// part. Returns null on unsupported platforms or any capture
  /// failure — never throws and never blocks the bug-report submit.
  Future<String?> _buildClientContextJson() async {
    try {
      final ctx = await ClientContext.capture();
      if (ctx == null) return null;
      return jsonEncode(ctx.toJson());
    } catch (e, st) {
      AppLogger.w(
        'client_context capture failed: $e',
        tag: 'ReviewFeedbackCubit',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Returns the anonymized DB-export zip if the user opted in via
  /// the checkbox AND the export succeeds. Returns null otherwise
  /// (opted-out, prod build, or export failure). Failures here are
  /// non-fatal: we want the bug report to ship even if the DB
  /// export blew up.
  Future<File?> _maybeBuildDbDump() async {
    if (!state.includeDbDump) return null;
    if (AppConfig.flavor == Flavor.production) {
      // The exporter itself rejects production, but short-circuit
      // here so we don't even attempt the work.
      AppLogger.w(
        'DB dump requested in production build; ignoring.',
        tag: 'ReviewFeedbackCubit',
      );
      return null;
    }
    try {
      final info = await PackageInfo.fromPlatform();
      return await DbExporter().exportAnonymizedArchive(
        appVersion: info.version,
        buildNumber: info.buildNumber,
        flavorName: AppConfig.flavor.name,
      );
    } catch (e, st) {
      AppLogger.w(
        'DB dump failed; submitting bug report without it: $e',
        tag: 'ReviewFeedbackCubit',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }
}
