part of 'more_cubit.dart';

enum MoreInitStatus {
  initial,
  loading,
  success,
  failure,
}

enum MoreDeleteAccountStatus {
  initial,
  loading,
  success,
  failure,
}

class MoreState extends Equatable {
  const MoreState({
    this.userEntity,
    this.initStatus = MoreInitStatus.initial,
    this.deleteAccountStatus = MoreDeleteAccountStatus.initial,
  });

  final UserEntity? userEntity;
  final MoreInitStatus initStatus;
  final MoreDeleteAccountStatus deleteAccountStatus;

  //copyWith
  MoreState copyWith({
    UserEntity? userEntity,
    MoreInitStatus? initStatus,
    MoreDeleteAccountStatus? deleteAccountStatus,
  }) {
    return MoreState(
      userEntity: userEntity ?? this.userEntity,
      initStatus: initStatus ?? this.initStatus,
      deleteAccountStatus: deleteAccountStatus ?? this.deleteAccountStatus,
    );
  }

  @override
  List<Object?> get props => [
        userEntity,
        initStatus,
        deleteAccountStatus,
      ];
}
