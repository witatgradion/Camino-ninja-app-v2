import 'package:remote_data/remote_data.dart';
import 'package:storage/storage.dart';

class Mappers {
  static CredentialEntity convertToCredential(LoginResponse loginResponse) {
    final now = DateTime.now();
    DateTime? accessTokenExpiry;
    DateTime? refreshTokenExpiry;
    if (loginResponse.accessTokenExpiresIn != null) {
      accessTokenExpiry = now.add(
        Duration(
          seconds: loginResponse.accessTokenExpiresIn!,
        ),
      );
    }
    if (loginResponse.refreshTokenExpiresIn != null) {
      refreshTokenExpiry = now.add(
        Duration(
          seconds: loginResponse.refreshTokenExpiresIn!,
        ),
      );
    }
return CredentialEntity(
      accessToken: loginResponse.accessToken,
      refreshToken: loginResponse.refreshToken,
      accessTokenExpiry: accessTokenExpiry,
      refreshTokenExpiry: refreshTokenExpiry,
      user: loginResponse.user != null
          ? UserEntity(
              id: loginResponse.user?.id,
              username: loginResponse.user?.username,
              fullName: loginResponse.user?.fullName,
              email: loginResponse.user?.email,
              role: loginResponse.user?.role,
            )
          : null,
    );
  }
}
