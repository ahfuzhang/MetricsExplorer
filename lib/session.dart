// ─── Session (shared across all authenticated API calls) ──────────────────────

class AppSession {
  final String apiPath;
  final String sessionToken;
  final String userName;
  final String salt;

  const AppSession({
    required this.apiPath,
    required this.sessionToken,
    required this.userName,
    required this.salt,
  });

  Map<String, String> get headers => {
        'Content-Type': 'application/protobuf',
        'X-Session': sessionToken,
      };
}
