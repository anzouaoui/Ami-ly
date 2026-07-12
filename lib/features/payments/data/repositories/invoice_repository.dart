import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_service.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  InvoiceRepository({required FirebaseService firebaseService})
      : _firestore = firebaseService.firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _invoices =>
      _firestore.collection('invoices');

  Future<InvoiceModel> createInvoice({
    required String assmatUid,
    required String parentUid,
    required String assmatName,
    required String familyName,
    required String childName,
    required int month,
    required int year,
    required double hours,
    required double hourlyRate,
    required int meals,
    required double mealRate,
    required double overtimeHours,
    required double maintenanceAllowance,
  }) async {
    final baseSalary = hours * hourlyRate;
    final mealCost = meals * mealRate;
    final overtimeAmount = overtimeHours * hourlyRate * 1.25;
    final totalAmount = baseSalary + mealCost + overtimeAmount + maintenanceAllowance;

    final doc = _invoices.doc();
    final invoice = InvoiceModel(
      id: doc.id,
      assmatUid: assmatUid,
      parentUid: parentUid,
      assmatName: assmatName,
      familyName: familyName,
      childName: childName,
      month: month,
      year: year,
      hours: hours,
      hourlyRate: hourlyRate,
      meals: meals,
      mealRate: mealRate,
      overtimeHours: overtimeHours,
      maintenanceAllowance: maintenanceAllowance,
      totalAmount: totalAmount,
      status: InvoiceStatus.pending,
      createdAt: DateTime.now(),
    );

    await doc.set(invoice.toFirestore());

    return invoice;
  }

  Stream<List<InvoiceModel>> watchByAssmat(String assmatUid) {
    return _invoices
        .where('assmatUid', isEqualTo: assmatUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => InvoiceModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<InvoiceModel>> watchByParent(String parentUid) {
    return _invoices
        .where('parentUid', isEqualTo: parentUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => InvoiceModel.fromFirestore(doc))
            .toList());
  }

  Future<String> getOnboardingLink(String assmatUid) async {
    final result = await FirebaseFirestore.instance
        .collection('_callables')
        .doc('createStripeOnboardingLink')
        .collection('calls')
        .add({
      'assmatUid': assmatUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final snap = await result.get();
    final data = snap.data();
    return data?['url'] as String? ?? '';
  }

  Future<bool> checkStripeConnected(String assmatUid) async {
    final result = await FirebaseFirestore.instance
        .collection('_callables')
        .doc('checkStripeAccountStatus')
        .collection('calls')
        .add({
      'assmatUid': assmatUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final snap = await result.get();
    final data = snap.data();
    return data?['connected'] as bool? ?? false;
  }
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return InvoiceRepository(firebaseService: firebaseService);
});
