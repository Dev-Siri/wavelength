class ApiResponse<T> {
  final bool success;
  final T data;

  const ApiResponse({required this.success, required this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? processData,
  ) {
    return ApiResponse(
      success: json["success"] as bool,
      data: processData != null ? processData(json["data"]) : json["data"] as T,
    );
  }
}
