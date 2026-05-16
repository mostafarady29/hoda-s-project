class ApiInterceptor {
  String? token;

  Map<String, String> getHeaders() {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  void setToken(String newToken) {
    token = newToken;
  }
}
