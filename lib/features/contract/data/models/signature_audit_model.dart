class SignatureAuditModel {
  SignatureAuditModel({
    required this.uid,
    required this.role,
    required this.signedName,
    DateTime? timestamp,
    this.ipAddress,
    this.method = 'typed_name',
    this.consentText = '',
  }) : timestamp = timestamp ?? DateTime.now();

  final String uid;
  final String role;
  final String signedName;
  final DateTime timestamp;
  final String? ipAddress;
  final String method;
  final String consentText;

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'role': role,
        'signedName': signedName,
        'timestamp': timestamp.toIso8601String(),
        'ipAddress': ipAddress,
        'method': method,
        'consentText': consentText,
      };

  factory SignatureAuditModel.fromJson(Map<String, dynamic> json) {
    return SignatureAuditModel(
      uid: json['uid'] as String,
      role: json['role'] as String,
      signedName: json['signedName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      ipAddress: json['ipAddress'] as String?,
      method: json['method'] as String? ?? 'typed_name',
      consentText: json['consentText'] as String? ?? '',
    );
  }
}
