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
          if (contractType == 'cdi') ...[
            _buildCdiEngagementSection(),
            pw.SizedBox(height: 16),
            _buildCdiLieuTravailSection(),
            pw.SizedBox(height: 16),
            _buildCdiDateEffetSection(data),
            pw.SizedBox(height: 16),
            _buildCdiDureeHorairesAccueilSection(data),
            pw.SizedBox(height: 16),
            _buildCdiRemunerationSection(data),
            pw.SizedBox(height: 16),
            _buildCdiIndemnitesSection(data),
            pw.SizedBox(height: 16),
            _buildCdiReposHebdomadaireSection(data),
            pw.SizedBox(height: 16),
            _buildCdiJoursFeriesSection(data),
            pw.SizedBox(height: 16),
            _buildCdiCongesAnnuelsSection(data),
            pw.SizedBox(height: 16),
            _buildCdiConfidentialiteSection(),
            pw.SizedBox(height: 16),
            _buildCdiConditionsParticulieresSection(data),
            pw.SizedBox(height: 16),
            _buildCdiSignaturesSection(data),
            pw.SizedBox(height: 16),
          ] else ...[
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
          ],
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
          _cdiField('N° de Sécurité sociale', data.securiteSocialeNo),
          _cdiField('Référence de l\'agrément', data.agrementRef),
          _cdiField('Date de délivrance agrément', data.agrementDate),
          pw.SizedBox(height: 4),
          _cdiField('Assurance RC Pro', data.assuranceRcPro),
          _cdiField('N° de police RC Pro', data.assuranceRcProPoliceNo),
          _cdiField('Assurance automobile', data.assuranceAuto),
          _cdiField('N° de police auto', data.assuranceAutoPoliceNo),
        ],
      ),
    );
  }

  pw.Widget _buildCdiEngagementSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildCdiSectionTitle('1. Engagement'),
        pw.SizedBox(height: 8),
        pw.Text(
          'Convention collective',
          style: const pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Ce contrat est régi par les dispositions de la Convention collective '
          'nationale de la branche du secteur des particuliers employeurs '
          'et de l\'emploi à domicile. Le salarié est informé de la possibilité '
          'de consulter le texte de la Convention collective nationale sur le '
          'site internet www.legifrance.gouv.fr.',
          style: const pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Retraite complémentaire et prévoyance',
          style: const pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Les institutions compétentes en matière de retraite et de prévoyance sont:\n'
          '→ Ircem AGIRC / ARRCO\n'
          '→ Ircem prévoyance\n'
          'Toutes deux domiciliées: 261 avenue des Nations-Unies – BP 593 – '
          '59060 ROUBAIX Cedex',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  pw.Widget _buildCdiLieuTravailSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildCdiSectionTitle('2. Lieu de travail et d\'accueil de l\'enfant'),
        pw.SizedBox(height: 8),
        pw.Text(
          'Le lieu de travail et d\'accueil de l\'enfant est exclusivement fixé :',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 6),
        _checkboxRow('Au domicile du salarié'),
        pw.SizedBox(height: 4),
        _checkboxRow('Dans une maison d\'assistants maternels'),
      ],
    );
  }

  pw.Widget _checkboxRow(String label, {bool checked = false}) {
    return pw.Row(
      children: [
        pw.Container(
          width: 10,
          height: 10,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey600, width: 1.2),
            color: checked ? PdfColors.black : null,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  pw.Widget _buildCdiDateEffetSection(ContractFormData data) {
    final childNom = data.nomEnfant.isNotEmpty ? data.nomEnfant : '………';
    final childPrenom = data.childFirstName.isNotEmpty
        ? data.childFirstName
        : data.prenomEnfant.isNotEmpty
            ? data.prenomEnfant
            : '………';
    final childDateNaissance =
        data.dateNaissanceEnfant.isNotEmpty ? data.dateNaissanceEnfant : '………';
    final dateDebut = data.dateDebut.isNotEmpty ? data.dateDebut : '………';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildCdiSectionTitle(
            '3. Date d\'effet du contrat'),
        pw.SizedBox(height: 8),
        pw.Text(
          'Le présent contrat est établi pour l\'accueil de l\'enfant :',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 6),
        pw.Row(
          children: [
            pw.SizedBox(width: 30, child: pw.Text('Nom :',
                style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.Text(childNom,
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Row(
          children: [
            pw.SizedBox(width: 30, child: pw.Text('Prénom :',
                style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.Text(childPrenom,
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.SizedBox(height: 3),
        pw.Row(
          children: [
            pw.SizedBox(width: 30, child: pw.Text('Né(e) le :',
                style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold))),
            pw.Text(childDateNaissance,
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Il prendra effet à la date de l\'embauche, le $dateDebut, '
          'pour une durée indéterminée. '
          '(À compter du premier jour de la période d\'essai).',
          style: const pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Période d\'essai',
          style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '(Articles 44-1 du socle commun et 95-1 du socle spécifique '
          '« assistant maternel » de la convention collective).',
          style: const pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
        ),
        pw.SizedBox(height: 6),
        _cdiField('Durée de la période d\'essai :', data.periodeEssai.isNotEmpty ? data.periodeEssai : '………'),
        pw.SizedBox(height: 6),
        pw.Text(
          'La période d\'essai ainsi que le délai de prévenance en cas de '
          'rupture durant la période d\'essai sont facultatifs.',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Période d\'adaptation',
          style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '(Article 94 du socle spécifique « assistant maternel » de la '
          'convention collective).',
          style: const pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'La période d\'adaptation débute le premier jour de travail effectif, '
          'pour une durée maximale de 30 jours calendaires.',
          style: const pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Les parties conviennent d\'une période d\'adaptation de '
          '${data.dureeAdaptation.isNotEmpty ? data.dureeAdaptation : '………'} '
          'jours calendaires, organisée du '
          '${data.dateDebutAdaptation.isNotEmpty ? data.dateDebutAdaptation : '………'} '
          'au ${data.dateFinAdaptation.isNotEmpty ? data.dateFinAdaptation : '………'}.',
          style: const pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Pendant cette période d\'adaptation, incluse dans la période '
          'd\'essai, le salarié sera rémunéré sur la base du salaire mensuel '
          'du présent contrat duquel sera déduite la rémunération des heures '
          'de travail non effectué.',
          style: const pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.justify,
        ),
      ],
    );
  }

  pw.Widget _buildCdiDureeHorairesAccueilSection(ContractFormData data) {
    final is52Semaines = data.semainesAn == '52';
    final is46OuMoins = data.semainesAn.isNotEmpty && data.semainesAn != '52';
    final heureParSem = data.heuresParSemaine.isNotEmpty ? data.heuresParSemaine : '………';
    final nbSem = data.nombreSemainesAn.isNotEmpty ? data.nombreSemainesAn : '………';
    final delaiPrev = data.delaiPrevenance.isNotEmpty ? data.delaiPrevenance : '………';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildCdiSectionTitle(
            '4. Durée et horaires d\'accueil'),
        pw.SizedBox(height: 8),
        pw.Text(
          '(Articles 97-1, 97-2 et 98-1-1 du socle spécifique '
          '« assistant maternel » de la convention collective).',
          style: const pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'L\'enfant sera accueilli (au choix) :',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 6),
        _checkboxRow(
          'Accueil de l\'enfant sur 52 semaines (y compris les congés, '
          'par période de 12 mois consécutifs)',
          checked: is52Semaines,
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Cas n°1 :',
          style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Le salarié travaille $heureParSem heures / semaine réparties comme suit :',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 6),
        _buildSimpleTable(['Jours de travail', 'Horaires de travail', 'Nombre d\'heures']),
        pw.SizedBox(height: 6),
        pw.Text(
          'Les parties conviennent de la possibilité de modifier les éléments '
          'mentionnés ci-dessus, sous réserve du respect d\'un délai de '
          'prévenance de $delaiPrev semaines calendaires. '
          '(À définir entre les parties.)',
          style: const pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'La durée maximale de travail est fixée à 48 heures par semaine, '
          'calculée sur une moyenne de 4 mois.',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 12),
        _checkboxRow(
          'Accueil de l\'enfant sur 46 semaines ou moins (hors congés, '
          'par période de 12 mois consécutifs)',
          checked: is46OuMoins,
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          'Cas n°2 :',
          style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Le salarié accueille l\'enfant pendant $nbSem semaines. '
          '(Préciser le nombre de semaines de garde effective sur '
          'les 12 mois consécutifs.)',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Le salarié travaille $heureParSem heures et ……… jours par semaine :',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 6),
        _buildSimpleTable(['Jours de travail', 'Horaires de travail', 'Nombre d\'heures']),
        pw.SizedBox(height: 6),
        pw.Text(
          'Les parties conviennent de la possibilité de modifier les éléments '
          'mentionnés ci-dessus, sous réserve du respect d\'un délai de '
          'prévenance de $delaiPrev semaines calendaires '
          '(à définir entre les parties).',
          style: const pw.TextStyle(fontSize: 9),
          textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        if (data.planningRemis)
          _checkboxRow(
            'Les jours et horaires de travail sont définis par un planning '
            'de travail remis au salarié par écrit dans le respect d\'un '
            'délai de prévenance de $delaiPrev semaines calendaires '
            '(à définir entre les parties). Ce délai ne peut être inférieur '
            'à 2 mois calendaires.',
            checked: true,
          ),
        pw.SizedBox(height: 4),
        pw.Text(
          'La durée maximale de travail est fixée à 48 heures par semaine, '
          'calculée sur une moyenne de 4 mois.',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  pw.Widget _buildSimpleTable(List<String> headers) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            color: PdfColors.grey200,
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: pw.Row(
              children: headers.map((h) => pw.Expanded(
                child: pw.Text(h, style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              )).toList(),
            ),
          ),
          for (int i = 0; i < 4; i++)
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: i % 2 == 0 ? pw.BoxDecoration(color: PdfColors.grey50) : null,
              child: pw.Row(
                children: headers.map((_) => pw.Expanded(
                  child: pw.Text('……………………………', style: const pw.TextStyle(fontSize: 8)),
                )).toList(),
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildCdiRemunerationSection(ContractFormData data) {
    final salaireBrut = data.salaireHoraire.isNotEmpty ? data.salaireHoraire : '………';
    final salaireNet = data.salaireHoraireNet.isNotEmpty ? data.salaireHoraireNet : '………';
    final salaireBrutMajore = data.salaireBrutBaseMajore.isNotEmpty ? data.salaireBrutBaseMajore : '………';
    final salaireNetMajore = data.salaireNetBaseMajore.isNotEmpty ? data.salaireNetBaseMajore : '………';
    final tauxMajore = data.tauxHoraireBrutMajore.isNotEmpty ? data.tauxHoraireBrutMajore : '………';
    final is52Sem = data.semainesAn == '52';
    final mensuelBrut = data.salaireMensuel.isNotEmpty ? data.salaireMensuel : '………';
    final mensuelNet = data.salaireMensuelNet.isNotEmpty ? data.salaireMensuelNet : '………';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildCdiSectionTitle('5. Rémunération à la date d\'embauche'),
        pw.SizedBox(height: 10),
        pw.Text('Salaire horaire de base',
            style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(
          'Salaire horaire brut de base : $salaireBrut€  '
          'Salaire horaire net de base : $salaireNet€',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Si le salarié est amené à effectuer des heures complémentaires '
          '(au-delà de l\'horaire contractuel et en-deçà de 45 heures '
          'hebdomadaires), celles-ci sont rémunérées au taux horaire normal. '
          'Les heures complémentaires peuvent donner lieu à une majoration '
          'de salaire, sur décision écrite des parties prévue dans le contrat '
          'de travail (article 110-2 de la convention collective).',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Salaire horaire brut de base majoré : $salaireBrutMajore€  '
          'Salaire horaire net de base majoré : $salaireNetMajore€',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Si le salarié est amené à effectuer des heures majorées '
          '(au-delà de 45 heures hebdomadaires), celles-ci donneront '
          'lieu à une majoration du salaire et seront rémunérées au taux '
          'horaire brut majoré de $tauxMajore% (ce taux ne pouvant '
          'être inférieur à 10% selon l\'article 110-1 de la convention '
          'collective).',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 12),
        pw.Text('Salaire mensuel de base',
            style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 6),
        pw.Text(
          is52Sem ? 'Cas n°1 :' : 'Cas n°2 :',
          style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          is52Sem
              ? 'Accueil de l\'enfant 52 semaines, y compris les congés, '
                  'sur une période de 12 mois consécutifs'
              : 'Accueil de l\'enfant 46 semaines ou moins, hors congés, '
                  'sur une période de 12 mois consécutifs',
          style: const pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          is52Sem
              ? 'Le salaire mensuel brut est calculé de la façon suivante : '
                  'salaire horaire brut × nombre d\'heures de travail '
                  'hebdomadaire × 52 semaines ÷ 12 mois'
              : 'Le salaire mensuel brut est calculé de la façon suivante : '
                  'salaire horaire brut × nombre d\'heures de travail '
                  'hebdomadaire × nombre de semaines programmées ÷ 12 mois',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Salaire mensuel brut de base : $mensuelBrut€  '
          'Salaire mensuel net de base : $mensuelNet€',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 10),
        pw.Text('Régularisation prévisionnelle',
            style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          'Selon l\'article 109-2 de la convention collective, une '
          'régularisation prévisionnelle est réalisée chaque année à la date '
          'anniversaire du contrat de travail, en comparant les salaires '
          'mensualisés versés pendant les douze (12) derniers mois écoulés, '
          'aux salaires qui auraient dû être versés en application du contrat '
          'de travail, au titre des heures réellement effectuées. Cette '
          'régularisation est établie par un écrit, signé par les parties.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Au cours de l\'exécution du contrat de travail, les '
          'régularisations prévisionnelles annuelles se compensent entre '
          'elles et n\'entraînent pas de règlement.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'À la fin du contrat de travail, les sommes restant dues au titre '
          'de la régularisation sont déclarées et font l\'objet d\'un '
          'règlement dans les conditions prévues à l\'article 56 du socle '
          'commun de la convention collective.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
      ],
    );
  }

  pw.Widget _buildCdiIndemnitesSection(ContractFormData data) {
    final indemniteEntretien = data.indemniteEntretienMontant.isNotEmpty
        ? data.indemniteEntretienMontant : '………';
    final indemniteJourHeures = data.indemniteEntretienJourHeures.isNotEmpty
        ? data.indemniteEntretienJourHeures : '………';
    final repasMontant = data.repasMontant.isNotEmpty ? data.repasMontant : '………';
    final fraisKm = data.fraisDeplacementKm.isNotEmpty ? data.fraisDeplacementKm : '………';
    final paiementJour = data.paiementJour.isNotEmpty ? data.paiementJour : '………';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Indemnités d\'entretien, frais de repas et indemnités de déplacement',
            style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Indemnités d\'entretien',
            style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          'Le montant horaire de cette indemnité est prévu dans le contrat '
          'de travail. Il varie en fonction de la durée de travail effectif, '
          'sans pouvoir être inférieur à 90% du minimum garanti lorsque la '
          'durée de travail journalière est de neuf (9) heures.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Quel que soit le nombre d\'heures de travail effectif par jour '
          'de travail, le montant journalier de cette indemnité ne peut pas '
          'être inférieur à 2,65 €.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Pour une journée de $indemniteJourHeures heures, le montant '
          'horaire de l\'indemnité d\'entretien est de $indemniteEntretien €.',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Frais de repas',
            style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Les repas sont fournis par (cocher la mention utile) :',
            style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 3),
        _checkboxRow(
          'Le particulier employeur sur une base de $repasMontant €/repas.',
          checked: data.repasFournisParEmployeur,
        ),
        pw.SizedBox(height: 2),
        _checkboxRow(
          'L\'assistant maternel agréé sur une base de $repasMontant €/repas.',
          checked: !data.repasFournisParEmployeur,
        ),
        pw.SizedBox(height: 8),
        pw.Text('Frais de déplacement',
            style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          '$fraisKm €/km (ne peut être ni inférieur au barème de '
          'l\'administration ni supérieur au barème fiscal).',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 8),
        pw.Text('Indemnité de fin de contrat',
            style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          'En fin de CDI, en cas de retrait d\'enfant, l\'employeur doit '
          'verser une indemnité de rupture si l\'enfant est accueilli depuis '
          'au moins 9 mois. Elle est égale à 1/80e du total des salaires '
          'bruts perçus pendant la durée du contrat (hors indemnités non '
          'soumises à contributions et cotisations sociales telles que '
          'l\'indemnité kilométrique, l\'indemnité d\'entretien et les frais '
          'de repas).',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 8),
        pw.Text('Date de paiement du salaire',
            style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          'La rémunération mensuelle (y compris les indemnités d\'entretien, '
          'et le cas échéant les indemnités de repas et de déplacement), '
          'est versée au salarié le $paiementJour de chaque mois.',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 4),
        if (data.pajemploiPlus)
          _checkboxRow(
            'Optionnel : le salarié donne son accord pour que le particulier '
            'employeur confie le versement de la rémunération à l\'Urssaf '
            'service Pajemploi, à travers le dispositif Pajemploi+.',
            checked: true,
          ),
      ],
    );
  }

  pw.Widget _cdiField(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 160,
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

  pw.Widget _buildCdiReposHebdomadaireSection(ContractFormData data) {
    final reposJour = data.reposHebdoJour.isNotEmpty ? data.reposHebdoJour : '………';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildCdiSectionTitle('6. Repos hebdomadaire'),
        pw.SizedBox(height: 8),
        pw.Text(
          'La période de repos hebdomadaire du salarié est fixée au : '
          '$reposJour auquel s\'ajoute le repos quotidien de 11 heures.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          'Cependant, l\'enfant peut exceptionnellement être confié au '
          'salarié, avec son accord écrit. Les parties conviennent alors '
          'que le travail pendant la période de repos hebdomadaire est :',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        _checkboxRow(
          'rémunéré au taux horaire dû, majoré à hauteur de 25%.',
          checked: data.reposTravailRemunere,
        ),
        pw.SizedBox(height: 2),
        _checkboxRow(
          'récupéré par un repos équivalent à la durée de travail, majoré de 25%.',
          checked: data.reposTravailRecupere,
        ),
      ],
    );
  }

  pw.Widget _buildCdiJoursFeriesSection(ContractFormData data) {
    final jfMajoration = data.jfMajoration.isNotEmpty ? data.jfMajoration : '………';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildCdiSectionTitle('7. Jours fériés'),
        pw.SizedBox(height: 8),
        pw.Text('Le 1er mai sera (cocher la mention utile) :',
            style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 4),
        _checkboxRow(
          'chômé. Le paiement du jour férié est inclus dans la mensualisation.',
          checked: data.premierMaiChome,
        ),
        pw.SizedBox(height: 2),
        _checkboxRow(
          'travaillé. En contrepartie, le salarié bénéficie d\'une '
          'rémunération majorée à hauteur de 100% (soit une rémunération '
          'doublée par rapport à la rémunération habituelle).',
          checked: data.premierMaiTravaille,
        ),
        pw.SizedBox(height: 10),
        pw.Text('Les jours fériés ordinaires travaillés (cocher les cases correspondantes) :',
            style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 4),
        _buildCdiJfCheckboxRow('1er janvier', data.jfTravaille1erJanvier),
        _buildCdiJfCheckboxRow('Vendredi Saint (Alsace-Moselle uniquement)', data.jfTravailleVendrediSaint),
        _buildCdiJfCheckboxRow('Lundi de Pâques', data.jfTravailleLundiPaques),
        _buildCdiJfCheckboxRow('8 mai', data.jfTravaille8Mai),
        _buildCdiJfCheckboxRow('Jeudi de l\'Ascension', data.jfTravailleAscension),
        _buildCdiJfCheckboxRow('Lundi de Pentecôte', data.jfTravailleLundiPentecote),
        _buildCdiJfCheckboxRow('Abolition de l\'esclavage (DROM uniquement)', data.jfTravailleAbolition),
        _buildCdiJfCheckboxRow('14 juillet', data.jfTravaille14Juillet),
        _buildCdiJfCheckboxRow('15 août', data.jfTravaille15Aout),
        _buildCdiJfCheckboxRow('1er novembre', data.jfTravaille1erNovembre),
        _buildCdiJfCheckboxRow('11 novembre', data.jfTravaille11Novembre),
        _buildCdiJfCheckboxRow('25 décembre', data.jfTravaille25Decembre),
        _buildCdiJfCheckboxRow('26 décembre (Alsace-Moselle uniquement)', data.jfTravaille26Decembre),
        pw.SizedBox(height: 6),
        pw.Text(
          'Le jour férié chômé qui tombe un jour habituellement travaillé '
          'par le salarié est rémunéré dans les conditions prévues par '
          'l\'article 47-2 du socle commun de la convention collective.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'En contrepartie du travail un jour férié ordinaire, le salarié '
          'perçoit, au titre des heures effectuées, une rémunération '
          'majorée de $jfMajoration% (taux de majoration ne pouvant être '
          'inférieur à 10%), calculée sur la base du salaire habituel '
          'fixé au présent contrat.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
      ],
    );
  }

  pw.Widget _buildCdiJfCheckboxRow(String label, bool checked) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 12, top: 2),
      child: _checkboxRow(label, checked: checked),
    );
  }

  pw.Widget _buildCdiCongesAnnuelsSection(ContractFormData data) {
    final is52Sem = data.semainesAn == '52';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildCdiSectionTitle('8. Congés annuels'),
        pw.SizedBox(height: 8),
        pw.Text(
          '(Article 48-1-1 du socle commun et 102-1 et 102-2 du socle '
          'spécifique « assistant maternel » de la convention collective)',
          style: const pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
        ),
        pw.SizedBox(height: 6),
        pw.Text('Prise des congés annuels',
            style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          'Les congés payés annuels doivent être pris. Lorsque le salarié '
          'accueille les enfants de plusieurs particuliers employeurs, '
          'ceux-ci s\'efforcent de fixer d\'un commun accord, au plus tard '
          'le 1er mars de chaque année, la date des congés. À défaut '
          'd\'accord entre tous les particuliers employeurs, le salarié '
          'fixe lui-même ses semaines de congés annuels. Il communique '
          'alors les dates de ses congés annuels par écrit à chacun de '
          'ses particuliers employeurs, au plus tard le 1er mars de chaque '
          'année, répartis comme suit :',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        pw.Text('→ 4 semaines pendant la période du 1er mai au 31 octobre de l\'année;',
            style: const pw.TextStyle(fontSize: 9)),
        pw.Text('→ 1 semaine en hiver.',
            style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 4),
        pw.Text(
          'Lorsque le salarié travaille pour un seul particulier employeur, '
          'à défaut d\'accord entre les parties sur les dates des congés, '
          'c\'est le particulier employeur qui, au plus tard le 1er mars '
          'de chaque année, fixe ces dates et en informe le salarié. '
          'Lorsque le salarié n\'acquiert pas 30 jours ouvrables de congés '
          'payés au cours de la période de référence, visée à l\'article '
          '48-1-1-1 du socle commun de la convention collective, il '
          'bénéficie de congés complémentaires non rémunérés pour lui '
          'permettre de bénéficier d\'un repos annuel de 30 jours ouvrables.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 8),
        pw.Text('Indemnité de congés annuels',
            style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          is52Sem ? 'Cas n°1 :' : 'Cas n°2 :',
          style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          is52Sem
              ? 'Accueil de l\'enfant 52 semaines, y compris les congés, '
                  'sur une période de 12 mois consécutifs. L\'indemnité des '
                  'congés payés est versée au salarié au moment où les congés '
                  'sont pris, en lieu et place de la rémunération.'
              : 'Accueil de l\'enfant 46 semaines ou moins, hors congés, '
                  'sur une période de 12 mois consécutifs.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        if (!is52Sem) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Il est convenu entre les parties que l\'indemnité des congés '
            'payés pour l\'année de référence écoulée, calculée au 31 mai '
            'de chaque année, s\'ajoute au salaire mensuel de base prévu '
            'au présent contrat.',
            style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
          ),
          pw.SizedBox(height: 4),
          pw.Text('Elle est versée (à choisir) :',
              style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 3),
          _checkboxRow('soit en une seule fois au mois de juin.',
              checked: data.congesVersement == 'juin'),
          pw.SizedBox(height: 2),
          _checkboxRow('soit en une seule fois lors de la prise principale des congés payés.',
              checked: data.congesVersement == 'prise'),
          pw.SizedBox(height: 2),
          _checkboxRow(
              'soit au fur et à mesure de la prise des congés payés au '
              'prorata du nombre de jours ouvrables de congés pris.',
              checked: data.congesVersement == 'fur'),
        ],
        pw.SizedBox(height: 8),
        pw.Text('Rémunération de l\'indemnité de congés payés',
            style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(
          'L\'indemnité de congés payés est calculée par comparaison entre '
          'les méthodes suivantes, étant précisé que le montant le plus '
          'avantageux pour le salarié sera retenu :',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          '→ La rémunération brute que le salarié aurait perçue pour une '
          'durée de travail égale à celle du congé payé.',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          '→ Le dixième (1/10ème) de la rémunération totale brute, hors '
          'éventuelle indemnité visée au chapitre VIII du socle commun de '
          'la présente convention collective, perçue par lui au cours de '
          'la période de référence pour l\'acquisition des congés payés à '
          'rémunérer, y compris celle versée au titre des congés payés '
          'pris au cours de ladite période.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
      ],
    );
  }

  pw.Widget _buildCdiConfidentialiteSection() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildCdiSectionTitle('9. Confidentialité'),
        pw.SizedBox(height: 8),
        pw.Text(
          'Les parties s\'engagent à conserver confidentielles les '
          'informations personnelles transmises entre elles dans le cadre '
          'de l\'exécution du présent contrat. Elles prennent les mesures '
          'nécessaires pour garantir cette confidentialité.',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
      ],
    );
  }

  pw.Widget _buildCdiConditionsParticulieresSection(ContractFormData data) {
    final conditions = data.conditionsParticulieres.isNotEmpty
        ? data.conditionsParticulieres : '………………………………………';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildCdiSectionTitle('10. Conditions particulières à définir s\'il y a lieu'),
        pw.SizedBox(height: 8),
        pw.Text(
          'Les parties peuvent prévoir certaines règles particulières pour '
          'l\'accueil ou l\'accompagnement des enfants accueillis, adaptées '
          'à leur situation (activités conseillées ou à proscrire, '
          'utilisation d\'un cahier de liaison, présence d\'animaux …) :',
          style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
        ),
        pw.SizedBox(height: 4),
        pw.Text(conditions, style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 6),
        pw.Text(
          '→ Les documents à joindre au contrat de travail '
          '(article 90-4 de la convention collective) :',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.SizedBox(height: 2),
        pw.Text('https://www.legifrance.gouv.fr',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.blue)),
      ],
    );
  }

  pw.Widget _buildCdiSignaturesSection(ContractFormData data) {
    final faitA = data.faitA.isNotEmpty ? data.faitA : '………';
    final faitLe = data.faitLe.isNotEmpty ? data.faitLe : '………';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400))),
          child: pw.Text(
            'Le présent contrat est établi en deux exemplaires. Un '
            'exemplaire est remis au salarié et l\'autre est conservé par '
            'le particulier employeur.',
            style: const pw.TextStyle(fontSize: 9), textAlign: pw.TextAlign.justify,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text('Fait à : $faitA     Le : $faitLe',
            style: const pw.TextStyle(fontSize: 9)),
        pw.SizedBox(height: 20),
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Signature du particulier employeur',
                      style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('(précédée de « Lu et approuvé »)',
                      style: const pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
                  pw.SizedBox(height: 40),
                  pw.Container(
                    height: 1, color: PdfColors.grey400,
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 30),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Signature de l\'assistant maternel',
                      style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('(précédée de « Lu et approuvé »)',
                      style: const pw.TextStyle(fontSize: 8, fontStyle: pw.FontStyle.italic)),
                  pw.SizedBox(height: 40),
                  pw.Container(
                    height: 1, color: PdfColors.grey400,
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            color: PdfColors.grey50,
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Avec Pajemploi+ :',
                  style: const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text(
                'Simplifiez vos démarches en choisissant de confier à '
                'l\'Urssaf l\'ensemble du processus de rémunération.',
                style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.justify,
              ),
              pw.Text(
                'Téléchargez et complétez l\'attestation d\'adhésion. '
                'Deux exemplaires doivent être établis puis conservés par '
                'les 2 parties.',
                style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.justify,
              ),
            ],
          ),
        ),
      ],
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
    int? step,
  }) async {
    final now = DateTime.now().toIso8601String();
    final updateData = <String, dynamic>{
      'contractData': formData.toJson(),
      'updatedAt': now,
    };
    if (step != null) {
      updateData['currentStep'] = step;
    }
    await _contracts.doc(contractId).update(updateData);
  }

  /// Cherche un brouillon existant entre parent et assmat.
  Future<({ContractFormData formData, int? step, String status, String id})?> findDraft({
    required String parentUid,
    required String assmatUid,
  }) async {
    final existing = await _contracts
        .where('parentUid', isEqualTo: parentUid)
        .where('assmatUid', isEqualTo: assmatUid)
        .where('status', whereIn: [
          ContractStatus.draft.name,
          ContractStatus.pendingParent.name,
          ContractStatus.pendingAssmat.name,
          ContractStatus.active.name,
        ])
        .limit(1)
        .get();
        
    if (existing.docs.isEmpty) return null;
    
    final doc = existing.docs.first;
    final data = doc.data();
    final contractData = data['contractData'] as Map<String, dynamic>?;
    
    if (contractData == null) return null;
    
    return (
      formData: _parseContractFormData(contractData),
      step: data['currentStep'] as int?,
      status: data['status'] as String? ?? 'draft',
      id: doc.id,
    );
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
      nomNaissanceSalarie: salarie['nomNaissance'] as String? ?? '',
      nomUsageSalarie: salarie['nomUsage'] as String? ?? '',
      prenomSalarie: salarie['prenom'] as String? ?? '',
      adresseSalarie: salarie['adresse'] as String? ?? '',
      villeSalarie: salarie['ville'] as String? ?? '',
      cpSalarie: salarie['cp'] as String? ?? '',
      telSalarie: salarie['telephone'] as String? ?? '',
      emailSalarie: salarie['email'] as String? ?? '',
      securiteSocialeNo: salarie['securiteSocialeNo'] as String? ?? '',
      agrementRef: salarie['agrementRef'] as String? ?? '',
      agrementDate: salarie['agrementDate'] as String? ?? '',
      assuranceRcPro: salarie['assuranceRcPro'] as String? ?? '',
      assuranceRcProPoliceNo: salarie['assuranceRcProPoliceNo'] as String? ?? '',
      assuranceAuto: salarie['assuranceAuto'] as String? ?? '',
      assuranceAutoPoliceNo: salarie['assuranceAutoPoliceNo'] as String? ?? '',
      childFirstName: enfant['prenom'] as String? ?? '',
      prenomEnfant: enfant['prenomComplet'] as String? ?? '',
      nomEnfant: enfant['nom'] as String? ?? '',
      dateNaissanceEnfant: enfant['dateNaissance'] as String? ?? '',
      dateDebut: contrat['dateDebut'] as String? ?? '',
      dateEmbauche: contrat['dateEmbauche'] as String? ?? '',
      finContrat: contrat['finContrat'] as String? ?? '',
      periodeEssai: contrat['periodeEssai'] as String? ?? '',
      dureeAdaptation: contrat['dureeAdaptation'] as String? ?? '',
      dateDebutAdaptation: contrat['dateDebutAdaptation'] as String? ?? '',
      dateFinAdaptation: contrat['dateFinAdaptation'] as String? ?? '',
      heuresSemaine: contrat['heuresSemaine'] as String? ?? '',
      heuresMois: contrat['heuresMois'] as String? ?? '',
      semainesAn: contrat['semainesAn'] as String? ?? '',
      salaireMensuel: contrat['salaireMensuel'] as String? ?? '',
      salaireHoraire: contrat['salaireHoraire'] as String? ?? '',
      salaireHoraireNet: contrat['salaireHoraireNet'] as String? ?? '',
      salaireBrutBaseMajore: contrat['salaireBrutBaseMajore'] as String? ?? '',
      salaireNetBaseMajore: contrat['salaireNetBaseMajore'] as String? ?? '',
      tauxHoraireBrutMajore: contrat['tauxHoraireBrutMajore'] as String? ?? '',
      heuresParSemaine: contrat['heuresParSemaine'] as String? ?? '',
      nombreSemainesAn: contrat['nombreSemainesAn'] as String? ?? '',
      delaiPrevenance: contrat['delaiPrevenance'] as String? ?? '',
      planningRemis: contrat['planningRemis'] as bool? ?? false,
      salaireMensuelNet: contrat['salaireMensuelNet'] as String? ?? '',
      indemniteEntretienMontant: contrat['indemniteEntretienMontant'] as String? ?? '',
      indemniteEntretienJourHeures: contrat['indemniteEntretienJourHeures'] as String? ?? '',
      repasFournisParEmployeur: contrat['repasFournisParEmployeur'] as bool? ?? false,
      repasMontant: contrat['repasMontant'] as String? ?? '',
      fraisDeplacementKm: contrat['fraisDeplacementKm'] as String? ?? '',
      paiementJour: contrat['paiementJour'] as String? ?? '',
      pajemploiPlus: contrat['pajemploiPlus'] as bool? ?? false,
      reposHebdoJour: contrat['reposHebdoJour'] as String? ?? '',
      reposTravailRemunere: contrat['reposTravailRemunere'] as bool? ?? false,
      reposTravailRecupere: contrat['reposTravailRecupere'] as bool? ?? false,
      premierMaiChome: contrat['premierMaiChome'] as bool? ?? false,
      premierMaiTravaille: contrat['premierMaiTravaille'] as bool? ?? false,
      jfTravaille1erJanvier: contrat['jfTravaille1erJanvier'] as bool? ?? false,
      jfTravailleVendrediSaint: contrat['jfTravailleVendrediSaint'] as bool? ?? false,
      jfTravailleLundiPaques: contrat['jfTravailleLundiPaques'] as bool? ?? false,
      jfTravaille8Mai: contrat['jfTravaille8Mai'] as bool? ?? false,
      jfTravailleAscension: contrat['jfTravailleAscension'] as bool? ?? false,
      jfTravailleLundiPentecote: contrat['jfTravailleLundiPentecote'] as bool? ?? false,
      jfTravailleAbolition: contrat['jfTravailleAbolition'] as bool? ?? false,
      jfTravaille14Juillet: contrat['jfTravaille14Juillet'] as bool? ?? false,
      jfTravaille15Aout: contrat['jfTravaille15Aout'] as bool? ?? false,
      jfTravaille1erNovembre: contrat['jfTravaille1erNovembre'] as bool? ?? false,
      jfTravaille11Novembre: contrat['jfTravaille11Novembre'] as bool? ?? false,
      jfTravaille25Decembre: contrat['jfTravaille25Decembre'] as bool? ?? false,
      jfTravaille26Decembre: contrat['jfTravaille26Decembre'] as bool? ?? false,
      jfMajoration: contrat['jfMajoration'] as String? ?? '',
      congesVersement: contrat['congesVersement'] as String? ?? '',
      conditionsParticulieres: contrat['conditionsParticulieres'] as String? ?? '',
      faitA: contrat['faitA'] as String? ?? '',
      faitLe: contrat['faitLe'] as String? ?? '',
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
