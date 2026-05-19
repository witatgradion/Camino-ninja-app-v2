import 'package:bloc/bloc.dart';
import 'package:camino_ninja_flutter/utils/app_helper.dart';
import 'package:camino_ninja_flutter/utils/safe_emit_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:repository/repository.dart';
import 'package:storage/storage.dart';

part 'more_state.dart';

class MoreCubit extends Cubit<MoreState> with SafeEmitMixin {
  MoreCubit() : super(const MoreState());

  final Repository _repository = GetIt.instance<Repository>();

  Stream<UserEntity?> get userStream =>
      stream.map((s) => s.userEntity).distinct();

  Future<void> init() async {
    try {
      safeEmit(state.copyWith(initStatus: MoreInitStatus.loading));
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final credential = await _repository.getCredential();
      safeEmit(
        MoreState(
          userEntity: credential?.user,
          initStatus: MoreInitStatus.success,
        ),
      );
      // ignore: empty_catches
    } catch (e) {
      safeEmit(state.copyWith(initStatus: MoreInitStatus.failure));
    }
  }

  Future<bool> shouldUpgradeToUseFeature() async {
    final optionalUpgradeMinBuild =
        await _repository.getOptionalUpgradeMinBuild();
    if (optionalUpgradeMinBuild == null) {
      return false;
    }
    return AppHelper.shouldUpgradeToUseFeature(optionalUpgradeMinBuild);
  }

  Future<void> deleteAccount() async {
    try {
      safeEmit(
        state.copyWith(deleteAccountStatus: MoreDeleteAccountStatus.loading),
      );
      await _repository.deleteAccount();
      safeEmit(
        state.copyWith(deleteAccountStatus: MoreDeleteAccountStatus.success),
      );
    } catch (e) {
      safeEmit(
        state.copyWith(deleteAccountStatus: MoreDeleteAccountStatus.failure),
      );
    }
  }
}
