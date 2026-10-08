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
    final overtimeAmount =
        overtimeHours * hourlyRate * InvoiceModel.overtimeMultiplier;
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

  Stream<List<InvoiceModel>> watchByAssmat(String assmatUid) =>
      _watchWhere('assmatUid', assmatUid);

  Stream<List<InvoiceModel>> watchByParent(String parentUid) =>
      _watchWhere('parentUid', parentUid);

  /// Factures dont [field] vaut [uid], des plus récentes aux plus anciennes.
  Stream<List<InvoiceModel>> _watchWhere(String field, String uid) {
    return _invoices
        .where(field, isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(InvoiceModel.fromFirestore).toList());
  }

  Future<String> getOnboardingLink(String assmatUid) async {
    final data =
        await _callStripeFunction('createStripeOnboardingLink', assmatUid);
    return data?['url'] as String? ?? '';
  }

  Future<bool> checkStripeConnected(String assmatUid) async {
    final data =
        await _callStripeFunction('checkStripeAccountStatus', assmatUid);
    return data?['connected'] as bool? ?? false;
  }

  /// Dépose un appel dans `_callables/{functionName}/calls` puis relit
  /// immédiatement le document créé.
  Future<Map<String, dynamic>?> _callStripeFunction(
    String functionName,
    String assmatUid,
  ) async {
    final callRef = await FirebaseFirestore.instance
        .collection('_callables')
        .doc(functionName)
        .collection('calls')
        .add({
      'assmatUid': assmatUid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final snap = await callRef.get();
    return snap.data();
  }
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return InvoiceRepository(firebaseService: firebaseService);
});
