/// A tiny, dependency-free Either-style result wrapper used by
/// repositories so controllers never have to wrap every call in try/catch.
sealed class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = ApiSuccess<T>;
  const factory ApiResult.failure(String message) = ApiFailure<T>;

  bool get isSuccess => this is ApiSuccess<T>;
  bool get isFailure => this is ApiFailure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    final self = this;
    if (self is ApiSuccess<T>) return success(self.data);
    if (self is ApiFailure<T>) return failure(self.message);
    throw StateError('Unreachable');
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResult<T> {
  final String message;
  const ApiFailure(this.message);
}
