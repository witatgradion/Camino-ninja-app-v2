sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiSuccess<T> extends ApiResult<T> {

  const ApiSuccess(this.data);
  final T data;
}

final class ApiFailure<Exception> extends ApiResult<Exception> {

  const ApiFailure(this.message);
  final String message;
}
