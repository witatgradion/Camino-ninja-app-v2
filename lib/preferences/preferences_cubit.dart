import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/app_helper.dart';
import 'package:camino_ninja_flutter/utils/network_util.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';

part 'preferences_state.dart';

class PreferencesCubit extends Cubit<PreferencesState> with SafeEmitMixin {
  PreferencesCubit() : super(const PreferencesState());

  final Repository _repository = GetIt.instance<Repository>();

  Stream<bool> get doNotAskShakeToReportStream =>
      stream.map((s) => s.doNotAskBugReportAgain).distinct();

  Future<void> initNecessaryData() async {
    final doNotAskBugReportAgain =
        await _repository.getDoNotAskShareToReport();
    final doNotAskStagePlannerAnnouncement =
        await _repository.getDoNotAskStagePlannerAnnouncement();
    final hasSeenNotificationPrompt =
        await _repository.getHasSeenNotificationPrompt();
    safeEmit(
      state.copyWith(
        doNotAskBugReportAgain: doNotAskBugReportAgain,
        doNotAskStagePlannerAnnouncement:
            doNotAskStagePlannerAnnouncement,
        hasSeenNotificationPrompt: hasSeenNotificationPrompt,
      ),
    );
  }

  Future<void> setDoNotAskShakeToReport(bool value) async {
    await _repository.setDoNotAskShareToReport(value);
    safeEmit(state.copyWith(doNotAskBugReportAgain: value));
  }

  Stream<bool> get doNotAskStagePlannerAnnouncementStream =>
      stream.map((s) => s.doNotAskStagePlannerAnnouncement).distinct();

  Future<void> setDoNotAskStagePlannerAnnouncement(bool value) async {
    await _repository.setDoNotAskStagePlannerAnnouncement(value);
    safeEmit(state.copyWith(doNotAskStagePlannerAnnouncement: value));
  }

  Future<void> setHasSeenNotificationPrompt() async {
    await _repository.setHasSeenNotificationPrompt(value: true);
    safeEmit(
      state.copyWith(hasSeenNotificationPrompt: true),
    );
  }

  Future<bool> shouldUpgradeToUseFeature() async {
    final optionalUpgradeMinBuild =
        await _repository.getOptionalUpgradeMinBuild();
    if (optionalUpgradeMinBuild == null) {
      return false;
    }
    final isNetworkConnected = NetworkUtil().isConnected;
    if (!isNetworkConnected) {
      return false;
    }
    return AppHelper.shouldUpgradeToUseFeature(optionalUpgradeMinBuild);
  }
}
