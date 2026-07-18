import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/invoice_model.dart';
import '../../data/repositories/invoice_repository.dart';

final invoicesByAssmatProvider =
    StreamProvider.autoDispose<List<InvoiceModel>>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(invoiceRepositoryProvider).watchByAssmat(uid);
});

final invoicesByParentProvider =
    StreamProvider.autoDispose<List<InvoiceModel>>((ref) {
  final uid = ref.watch(currentUserProvider).valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(invoiceRepositoryProvider).watchByParent(uid);
});

final pendingInvoicesCountProvider = Provider.autoDispose<int>((ref) {
  final invoices = ref.watch(invoicesByAssmatProvider).valueOrNull ?? [];
  return invoices.where((i) => i.status == InvoiceStatus.pending).length;
});

final monthlyRevenueProvider = Provider.autoDispose<double>((ref) {
  final invoices = ref.watch(invoicesByAssmatProvider).valueOrNull ?? [];
  final now = DateTime.now();
  return invoices
      .where((i) =>
          i.status == InvoiceStatus.paid &&
          i.month == now.month &&
          i.year == now.year)
      .fold(0.0, (sum, i) => sum + i.totalAmount);
});

final monthlyInvoiceCountProvider = Provider.autoDispose<int>((ref) {
  final invoices = ref.watch(invoicesByAssmatProvider).valueOrNull ?? [];
  final now = DateTime.now();
  return invoices
      .where((i) => i.month == now.month && i.year == now.year)
      .length;
});
