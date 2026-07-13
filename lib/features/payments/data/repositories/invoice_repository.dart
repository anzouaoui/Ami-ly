import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/firebase_service.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  InvoiceRepository({
    required FirebaseService firebaseService,
    FirebaseFunctions? functions,
  })  : _firestore = firebaseService.firestore,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

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
    final totalAmount =
        baseSalary + mealCost + overtimeAmount + maintenanceAllowance;

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
    final result =
        await _functions.httpsCallable('createStripeOnboardingLink').call({
      'assmatUid': assmatUid,
    });
    return result.data['url'] as String;
  }

  Future<bool> checkStripeConnected(String assmatUid) async {
    final result =
        await _functions.httpsCallable('checkStripeAccountStatus').call({
      'assmatUid': assmatUid,
    });
    return result.data['connected'] as bool;
  }

  Future<String> createPaymentIntent(String invoiceId) async {
    final result =
        await _functions.httpsCallable('createPaymentIntent').call({
      'invoiceId': invoiceId,
    });
    return result.data['clientSecret'] as String;
  }
}

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return InvoiceRepository(firebaseService: firebaseService);
});
