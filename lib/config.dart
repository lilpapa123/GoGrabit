/// Application configuration. Set `API_BASE` at build/run time with --dart-define.
const String apiBase = String.fromEnvironment(
  'apiBase',
  defaultValue: 'http://localhost:5000/api',
);

/// Example usage:
/// final uri = Uri.parse('$API_BASE/auth/login');
