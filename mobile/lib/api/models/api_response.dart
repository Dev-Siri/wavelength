sealed class ApiResponse<T> {}

class ApiResponseSuccess<T> extends ApiResponse<T> {
  final T data;

  ApiResponseSuccess({required this.data});

  @override
  String toString() => "ApiResponseSuccess(data: $data)";
}

class ApiResponseError<T> extends ApiResponse<T> {
  final String message;

  ApiResponseError({required this.message});

  @override
  String toString() => "ApiResponseError(message: $message)";
}
