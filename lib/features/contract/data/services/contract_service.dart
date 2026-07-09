import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/services/firebase_service.dart';
import '../models/contract_form_data.dart';
import '../models/contract_model.dart';
import '../models/signature_audit_model.dart';

class ContractService {
  ContractService({
    required FirebaseService firebaseService,
  })  : _firestore = firebaseService.firestore,
        _storage = firebaseService.storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _contracts =>
      _firestore.collection('contracts');

  CollectionReference<Map<String, dynamic>> _signatures(String contractId) =>
      _contracts.doc(contractId).collection('signatures');

  /// Crée ou récupère un contrat existant entre parent et assmat.
  Future<String> getOrCreateContract({
    required String parentUid,
    required String assmatUid,
  }) async {
    final existing = await _contracts
        .where('parentUid', isEqualTo: parentUid)
        .where('assmatUid', isEqualTo: assmatUid)
        .where('status', whereIn: [ContractStatus.draft.name, ContractStatus.pendingParent.name, ContractStatus.pendingAssmat.name])
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    final docRef = await _contracts.add({
      'parentUid': parentUid,
      'assmatUid': assmatUid,
      'status': ContractStatus.draft.name,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    return docRef.id;
  }

  /// Génère le PDF du contrat avec les données du formulaire.
  Future<List<int>> generateContractPdf(ContractFormData data, {String contractType = 'engagement'}) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        build: (context) => [
          _buildHeader(contractType == 'engagement'),
          pw.SizedBox(height: 24),
          if (contractType == 'cdi') ...[
            _buildCdiSectionTitle('Entre le particulier employeur :'),
            _buildCdiEmployeurSection(data),
          ] else
            _buildSection("Employeur", [
              _row('Civilité', data.civiliteEmployeur),
              _row('Type', data.typeEmployeur),
              _row('Nom', '${data.prenomEmployeur} ${data.nomEmployeur}'),
              _row('Adresse', data.adresseEmployeur),
              if (data.villeEmployeur.isNotEmpty || data.cpEmployeur.isNotEmpty)
                _row('Ville / CP', '${data.villeEmployeur} ${data.cpEmployeur}'.trim()),
              _row('Téléphone', data.telEmployeur),
              _row('Email', data.emailEmployeur),
            ]),
          pw.SizedBox(height: 16),
          if (contractType == 'cdi') ...[
            _buildCdiSectionTitle('Entre le salarié :'),
            _buildCdiSalarieSection(data),
          ] else
            _buildSection("Salarié — Assistante maternelle", [
              _row('Civilité', data.civiliteSalarie),
              _row('Nom', '${data.prenomSalarie} ${data.nomSalarie}'),
              _row('Adresse', data.adresseSalarie),
              if (data.villeSalarie.isNotEmpty || data.cpSalarie.isNotEmpty)
                _row('Ville / CP', '${data.villeSalarie} ${data.cpSalarie}'.trim()),
              _row('Téléphone', data.telSalarie),
              _row('Email', data.emailSalarie),
            ]),
          pw.SizedBox(height: 16),
          _buildSection("Enfant concerné", [
            if (data.childFirstName.isNotEmpty)
              _row('Prénom', data.childFirstName),
            if (data.prenomEnfant.isNotEmpty)
              _row('Prénom (contrat)', data.prenomEnfant),
            if (data.nomEnfant.isNotEmpty)
              _row('Nom', data.nomEnfant),
            if (data.dateNaissanceEnfant.isNotEmpty)
              _row('Date de naissance', data.dateNaissanceEnfant),
          ]),
          pw.SizedBox(height: 16),
          _buildSection("Conditions d'accueil et rémunération", [
            if (data.dateDebut.isNotEmpty)
              _row('Date de début', data.dateDebut),
            if (data.dateEmbauche.isNotEmpty)
              _row("Date d'embauche", data.dateEmbauche),
            if (data.finContrat.isNotEmpty)
              _row('Fin de contrat', data.finContrat),
            if (data.periodeEssai.isNotEmpty)
              _row('Période d\'essai', data.periodeEssai),
            if (data.heuresSemaine.isNotEmpty)
              _row('Heures / Semaine', '${data.heuresSemaine} h'),
            if (data.heuresMois.isNotEmpty)
              _row('Heures / Mois', '${data.heuresMois} h'),
            if (data.semainesAn.isNotEmpty)
              _row('Semaines / An', '${data.semainesAn} sem.'),
            if (data.salaireMensuel.isNotEmpty)
              _row('Salaire mensuel brut', '${data.salaireMensuel} €'),
            if (data.salaireHoraire.isNotEmpty)
              _row('Salaire horaire brut', '${data.salaireHoraire} €'),
          ]),
          pw.SizedBox(height: 32),
          pw.Paragraph(
            text: contractType == 'engagement'
                ? 'Fait pour servir et valoir ce que de droit.\n'
                    'Document généré par Ami-ly — signature électronique.'
                : 'Fait pour servir et valoir ce que de droit, dans le cadre d\'un contrat de travail à durée indéterminée.\n'
                    'Document généré par Ami-ly — signature électronique.',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Paragraph(
            text:
                'Signatures électroniques au sens du règlement eIDAS (UE 910/2014).\n'
                'Cachet électronique apposé via l\'application Ami-ly.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ],
      ),
    );

    return await doc.save();
  }

  pw.Widget _buildHeader(bool isEngagement) {
    if (isEngagement) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Contrat d'engagement réciproque",
            style: const pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Entre un parent employeur et une assistante maternelle agréée',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey),
          ),
          pw.Divider(color: PdfColors.blueGrey200),
        ],
      );
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Contrat de travail à durée indéterminée (CDI)',
          style: const pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blueGrey800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Assistant maternel agréé',
          style: const pw.TextStyle(
            fontSize: 14,
            color: PdfColors.blueGrey600,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          height: 2,
          color: PdfColors.blueGrey200,
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Convention collective nationale des assistants maternels du 1er juillet 2004 - IDCC 3239',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
        ),
      ],
    );
  }

  pw.Widget _buildCdiSectionTitle(String title) {
    return pw.Container(
      color: PdfColors.blueGrey50,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        title,
        style: const pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey800,
        ),
      ),
    );
  }

  pw.Widget _buildCdiEmployeurSection(ContractFormData data) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _cdiField('Nom de naissance', data.nomEmployeur),
          _cdiField('Nom d\'usage', data.nomUsageEmployeur),
          _cdiField('Prénom', data.prenomEmployeur),
          _cdiField('Adresse', data.adresseEmployeur),
          _cdiField('Ville', data.villeEmployeur),
          _cdiField('Code postal', data.cpEmployeur),
          _cdiField('N° de téléphone', data.telEmployeur),
          _cdiField('E-mail', data.emailEmployeur),
          _cdiField('En qualité de', data.typeEmployeur),
          _cdiField('N° Pajemploi', data.pajemploiNo),
          _cdiField('Code IDCC', data.idccCode),
        ],
      ),
    );
  }

  pw.Widget _buildCdiSalarieSection(ContractFormData data) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _cdiField('Civilité', data.civiliteSalarie),
          _cdiField('Nom', data.nomSalarie),
          _cdiField('Prénom', data.prenomSalarie),
          _cdiField('Adresse', data.adresseSalarie),
          _cdiField('Ville', data.villeSalarie),
          _cdiField('Code postal', data.cpSalarie),
          _cdiField('N° de téléphone', data.telSalarie),
          _cdiField('E-mail', data.emailSalarie),
        ],
      ),
    );
  }

  pw.Widget _cdiField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isNotEmpty ? value : '………',
              style: const pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSection(String title, List<pw.Widget> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          color: PdfColors.blueGrey50,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey800,
            ),
          ),
        ),
        pw.SizedBox(height: 6),
        ...rows,
        pw.SizedBox(height: 4),
      ],
    );
  }

  pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5, horizontal: 8),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  /// Calcule le hash SHA-256 du PDF.
  String computePdfHash(List<int> pdfBytes) {
    final bytes = utf8.encode(base64.encode(pdfBytes));
    final hash = _sha256(bytes);
    return hash;
  }

  String _sha256(List<int> bytes) {
    final sha = _SHA256();
    sha.update(bytes);
    return sha.digest();
  }

  /// Upload le PDF vers Firebase Storage.
  Future<String> uploadPdf({
    required String contractId,
    required List<int> pdfBytes,
  }) async {
    final ref = _storage.ref('contracts/$contractId/contrat_engagement.pdf');
    await ref.putData(Uint8List.fromList(pdfBytes));
    return await ref.getDownloadURL();
  }

  /// Sauvegarde la signature dans Firestore.
  Future<void> saveSignature({
    required String contractId,
    required SignatureAuditModel audit,
  }) async {
    await _signatures(contractId).add(audit.toJson());
  }

  /// Met à jour le statut du contrat après signature parent.
  Future<void> finalizeParentSignature({
    required String contractId,
    required ContractFormData formData,
    required String signedName,
    String pdfUrl = '',
    String pdfHash = '',
    String? ipAddress,
    String method = 'typed_name',
    String contractType = 'engagement',
  }) async {
    final now = DateTime.now().toIso8601String();
    final data = formData.toJson();

    final doc = await _contracts.doc(contractId).get();
    final currentStatus = doc.data()?['status'] as String?;

    await _contracts.doc(contractId).update({
      if (currentStatus != ContractStatus.active.name)
        'status': ContractStatus.pendingAssmat.name,
      'pdfUrl': pdfUrl,
      'pdfHash': pdfHash,
      'contractData': data,
      'parentSignedAt': now,
      'parentSignedName': signedName,
      'parentSignatureIp': ipAddress,
      'signatureMethod': method,
      'contractType': contractType,
      'updatedAt': now,
    });
  }

  /// Récupère un contrat par son ID.
  Future<Map<String, dynamic>?> getContractById(String contractId) async {
    final doc = await _contracts.doc(contractId).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Met à jour le statut du contrat après signature assmat.
  Future<void> finalizeAssmatSignature({
    required String contractId,
    required String signedName,
    String? ipAddress,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _contracts.doc(contractId).update({
      'status': ContractStatus.active.name,
      'assmatSignedAt': now,
      'assmatSignedName': signedName,
      'assmatSignatureIp': ipAddress,
      'updatedAt': now,
    });
  }

  /// Génère le PDF finalisé après signature des deux parties.
  Future<void> generateFinalizedPdf({
    required String contractId,
    required ContractFormData formData,
    String contractType = 'engagement',
  }) async {
    final doc = await _contracts.doc(contractId).get();
    final data = doc.data();
    if (data == null) return;

    final parentSigned = data['parentSignedAt'] as String?;
    final assmatSigned = data['assmatSignedAt'] as String?;
    if (parentSigned == null || assmatSigned == null) return;

    final pdfBytes = await generateContractPdf(formData, contractType: contractType);
    final hash = computePdfHash(pdfBytes);

    final ref = _storage.ref('contracts/$contractId/contrat_finalise.pdf');
    await ref.putData(Uint8List.fromList(pdfBytes));
    final pdfUrl = await ref.getDownloadURL();

    await _contracts.doc(contractId).update({
      'finalPdfUrl': pdfUrl,
      'finalPdfHash': hash,
      'finalizedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Sauvegarde les données du formulaire en brouillon.
  Future<void> saveDraft({
    required String contractId,
    required ContractFormData formData,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _contracts.doc(contractId).update({
      'contractData': formData.toJson(),
      'updatedAt': now,
    });
  }

  /// Cherche un brouillon existant entre parent et assmat.
  Future<ContractFormData?> findDraft({
    required String parentUid,
    required String assmatUid,
  }) async {
    final existing = await _contracts
        .where('parentUid', isEqualTo: parentUid)
        .where('assmatUid', isEqualTo: assmatUid)
        .where('status', isEqualTo: 'draft')
        .limit(1)
        .get();
    if (existing.docs.isEmpty) return null;
    final data = existing.docs.first.data();
    final contractData = data['contractData'] as Map<String, dynamic>?;
    if (contractData == null) return null;
    return _parseContractFormData(contractData);
  }

  static ContractFormData _parseContractFormData(Map<String, dynamic> json) {
    final employer = json['employeur'] as Map<String, dynamic>? ?? {};
    final salarie = json['salarie'] as Map<String, dynamic>? ?? {};
    final enfant = json['enfant'] as Map<String, dynamic>? ?? {};
    final contrat = json['contrat'] as Map<String, dynamic>? ?? {};

    return ContractFormData(
      civiliteEmployeur: employer['civilite'] as String? ?? '',
      typeEmployeur: employer['type'] as String? ?? '',
      nomEmployeur: employer['nom'] as String? ?? '',
      nomNaissanceEmployeur: employer['nomNaissance'] as String? ?? '',
      nomUsageEmployeur: employer['nomUsage'] as String? ?? '',
      prenomEmployeur: employer['prenom'] as String? ?? '',
      adresseEmployeur: employer['adresse'] as String? ?? '',
      villeEmployeur: employer['ville'] as String? ?? '',
      cpEmployeur: employer['cp'] as String? ?? '',
      telEmployeur: employer['telephone'] as String? ?? '',
      emailEmployeur: employer['email'] as String? ?? '',
      pajemploiNo: employer['pajemploiNo'] as String? ?? '',
      idccCode: employer['idccCode'] as String? ?? '3239',
      civiliteSalarie: salarie['civilite'] as String? ?? '',
      nomSalarie: salarie['nom'] as String? ?? '',
      prenomSalarie: salarie['prenom'] as String? ?? '',
      adresseSalarie: salarie['adresse'] as String? ?? '',
      villeSalarie: salarie['ville'] as String? ?? '',
      cpSalarie: salarie['cp'] as String? ?? '',
      telSalarie: salarie['telephone'] as String? ?? '',
      emailSalarie: salarie['email'] as String? ?? '',
      childFirstName: enfant['prenom'] as String? ?? '',
      prenomEnfant: enfant['prenomComplet'] as String? ?? '',
      nomEnfant: enfant['nom'] as String? ?? '',
      dateNaissanceEnfant: enfant['dateNaissance'] as String? ?? '',
      dateDebut: contrat['dateDebut'] as String? ?? '',
      dateEmbauche: contrat['dateEmbauche'] as String? ?? '',
      finContrat: contrat['finContrat'] as String? ?? '',
      periodeEssai: contrat['periodeEssai'] as String? ?? '',
      heuresSemaine: contrat['heuresSemaine'] as String? ?? '',
      heuresMois: contrat['heuresMois'] as String? ?? '',
      semainesAn: contrat['semainesAn'] as String? ?? '',
      salaireMensuel: contrat['salaireMensuel'] as String? ?? '',
      salaireHoraire: contrat['salaireHoraire'] as String? ?? '',
    );
  }

  /// Récupère l'adresse IP approximative via un service externe.
  static Future<String?> getPublicIp() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://api.ipify.org'));
      final response = await request.close();
      if (response.statusCode == 200) {
        return await response.transform(utf8.decoder).first;
      }
    } catch (_) {}
    return null;
  }
}

// ─── Mini SHA-256 (sans dépendance externe) ──────────────────────────────────────
class _SHA256 {
  final _h = List<int>.generate(8, (_) => 0);
  final _w = List<int>.generate(64, (_) => 0);
  final _k = <int>[
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];

  void update(List<int> bytes) {
    final padding = _pad(bytes);
    for (var i = 0; i < padding.length; i += 64) {
      _process(padding.sublist(i, i + 64));
    }
  }

  String digest() {
    return _h.map((v) => v.toRadixString(16).padLeft(8, '0')).join();
  }

  List<int> _pad(List<int> data) {
    final bitLen = data.length * 8;
    final padLen = (448 - (bitLen + 1) % 512) % 512;
    final result = List<int>.from(data)
      ..add(0x80)
      ..addAll(List.filled(padLen ~/ 8, 0))
      ..addAll([
        (bitLen >> 56) & 0xff,
        (bitLen >> 48) & 0xff,
        (bitLen >> 40) & 0xff,
        (bitLen >> 32) & 0xff,
        (bitLen >> 24) & 0xff,
        (bitLen >> 16) & 0xff,
        (bitLen >> 8) & 0xff,
        bitLen & 0xff,
      ]);
    return result;
  }

  void _process(List<int> block) {
    for (var i = 0; i < 16; i++) {
      _w[i] = (block[i * 4] << 24) |
          (block[i * 4 + 1] << 16) |
          (block[i * 4 + 2] << 8) |
          block[i * 4 + 3];
    }
    for (var i = 16; i < 64; i++) {
      final s0 = _rotr(_w[i - 15], 7) ^ _rotr(_w[i - 15], 18) ^ (_w[i - 15] >>> 3);
      final s1 = _rotr(_w[i - 2], 17) ^ _rotr(_w[i - 2], 19) ^ (_w[i - 2] >>> 10);
      _w[i] = (_w[i - 16] + s0 + _w[i - 7] + s1) & 0xffffffff;
    }

    var a = _h[0], b = _h[1], c = _h[2], d = _h[3];
    var e = _h[4], f = _h[5], g = _h[6], h = _h[7];

    for (var i = 0; i < 64; i++) {
      final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ ((~e) & g);
      final temp1 = (h + s1 + ch + _k[i] + _w[i]) & 0xffffffff;
      final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (s0 + maj) & 0xffffffff;

      h = g;
      g = f;
      f = e;
      e = (d + temp1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) & 0xffffffff;
    }

    _h[0] = (_h[0] + a) & 0xffffffff;
    _h[1] = (_h[1] + b) & 0xffffffff;
    _h[2] = (_h[2] + c) & 0xffffffff;
    _h[3] = (_h[3] + d) & 0xffffffff;
    _h[4] = (_h[4] + e) & 0xffffffff;
    _h[5] = (_h[5] + f) & 0xffffffff;
    _h[6] = (_h[6] + g) & 0xffffffff;
    _h[7] = (_h[7] + h) & 0xffffffff;
  }

  int _rotr(int x, int n) => (x >>> n) | (x << (32 - n));
}
