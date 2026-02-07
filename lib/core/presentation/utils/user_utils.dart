String extractNameFromEmail(String? email) {
  if (email == null || email.isEmpty) return 'User';
  final prefix = email.split('@').first.trim();
  // remove leading/trailing non-alphanumeric characters
  var cleaned = prefix.replaceAll(RegExp(r'^[^A-Za-z0-9]+|[^A-Za-z0-9]+$'), '');
  // fallback: remove any non-alphanumeric characters if nothing left
  if (cleaned.isEmpty) {
    cleaned = prefix.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  }
  // clamp length for UI
  if (cleaned.length > 20) cleaned = cleaned.substring(0, 20);
  return cleaned.isEmpty ? 'User' : cleaned;
}