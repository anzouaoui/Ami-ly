import 'package:cloud_firestore/cloud_firestore.dart';

enum InvoiceStatus {
  pending,
  paid,
  failed;

  String get label {
    switch (this) {
      case InvoiceStatus.pending:
        return 'En attente';
      case InvoiceStatus.paid:
        return 'Payée';
      case InvoiceStatus.failed:
        return 'Échouée';
    }
  }
}

class InvoiceModel {
  const InvoiceModel({
    required this.id,
    required this.assmatUid,
    required this.parentUid,
    required this.assmatName,
    required this.familyName,
    required this.childName,
    required this.month,
    required this.year,
    required this.hours,
    required this.hourlyRate,
    required this.meals,
    required this.mealRate,
    required this.overtimeHours,
    required this.maintenanceAllowance,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.stripePaymentIntentId,
    this.stripeClientSecret,
    this.paidAt,
  });

  final String id;
  final String assmatUid;
  final String parentUid;
  final String assmatName;
  final String familyName;
  final String childName;
  final int month;
  final int year;
  final double hours;
  final double hourlyRate;
  final int meals;
  final double mealRate;
  final double overtimeHours;
  final double maintenanceAllowance;
  final double totalAmount;
  final InvoiceStatus status;
  final DateTime createdAt;
  final String? stripePaymentIntentId;
  final String? stripeClientSecret;
  final DateTime? paidAt;

  String get period => '$month/$year';

  int get amountCents => (totalAmount * 100).round();

  double get baseSalary => hours * hourlyRate;
  double get mealCost => meals * mealRate;
  double get overtimeAmount => overtimeHours * hourlyRate * 1.25;

  factory InvoiceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? {};
    return InvoiceModel(
      id: doc.id,
      assmatUid: d['assmatUid'] as String? ?? '',
      parentUid: d['parentUid'] as String? ?? '',
      assmatName: d['assmatName'] as String? ?? '',
      familyName: d['familyName'] as String? ?? '',
      childName: d['childName'] as String? ?? '',
      month: d['month'] as int? ?? 0,
      year: d['year'] as int? ?? 0,
      hours: (d['hours'] as num?)?.toDouble() ?? 0,
      hourlyRate: (d['hourlyRate'] as num?)?.toDouble() ?? 0,
      meals: d['meals'] as int? ?? 0,
      mealRate: (d['mealRate'] as num?)?.toDouble() ?? 0,
      overtimeHours: (d['overtimeHours'] as num?)?.toDouble() ?? 0,
      maintenanceAllowance: (d['maintenanceAllowance'] as num?)?.toDouble() ?? 0,
      totalAmount: (d['totalAmount'] as num?)?.toDouble() ?? 0,
      status: InvoiceStatus.values.firstWhere(
        (s) => s.name == d['status'],
        orElse: () => InvoiceStatus.pending,
      ),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      stripePaymentIntentId: d['stripePaymentIntentId'] as String?,
      stripeClientSecret: d['stripeClientSecret'] as String?,
      paidAt: (d['paidAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'assmatUid': assmatUid,
        'parentUid': parentUid,
        'assmatName': assmatName,
        'familyName': familyName,
        'childName': childName,
        'month': month,
        'year': year,
        'hours': hours,
        'hourlyRate': hourlyRate,
        'meals': meals,
        'mealRate': mealRate,
        'overtimeHours': overtimeHours,
        'maintenanceAllowance': maintenanceAllowance,
        'totalAmount': totalAmount,
        'status': status.name,
        'createdAt': Timestamp.fromDate(createdAt),
        if (stripePaymentIntentId != null)
          'stripePaymentIntentId': stripePaymentIntentId,
        if (stripeClientSecret != null)
          'stripeClientSecret': stripeClientSecret,
        if (paidAt != null) 'paidAt': Timestamp.fromDate(paidAt!),
      };
}
