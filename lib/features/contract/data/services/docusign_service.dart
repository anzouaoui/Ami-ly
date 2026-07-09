import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class DocusignService {
  final FirebaseFunctions _functions;

  DocusignService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<String> createEnvelope({
    required String contractId,
    required String pdfUrl,
  }) async {
    final result = await _functions.httpsCallable('createEnvelope').call({
      'contractId': contractId,
      'pdfUrl': pdfUrl,
    });
    return result.data['envelopeId'] as String;
  }

  Future<String> getRecipientViewUrl({
    required String contractId,
    required String userId,
  }) async {
    final result = await _functions.httpsCallable('getRecipientViewUrl').call({
      'contractId': contractId,
      'userId': userId,
    });
    return result.data['signingUrl'] as String;
  }

  Future<String?> getExistingEnvelopeId(String contractId) async {
    final doc =
        await FirebaseFirestore.instance.collection('contracts').doc(contractId).get();
    final data = doc.data();
    return data?['docusignEnvelopeId'] as String?;
  }
}
