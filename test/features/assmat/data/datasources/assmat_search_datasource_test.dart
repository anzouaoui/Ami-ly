// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:amily/core/services/firebase_service.dart';
import 'package:amily/features/assmat/data/datasources/assmat_search_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebase extends Mock implements FirebaseService {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class _MockSnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class _MockDoc extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

_MockDoc _doc(String id, Map<String, dynamic> data) {
  final doc = _MockDoc();
  when(() => doc.id).thenReturn(id);
  when(() => doc.data()).thenReturn(data);
  return doc;
}

_MockSnapshot _snapshot(List<_MockDoc> docs) {
  final snap = _MockSnapshot();
  when(() => snap.docs).thenReturn(docs);
  return snap;
}

void main() {
  test('watchSearchableParents associe à chaque parent ses enfants, '
      'dans l\'ordre des parents', () async {
    final firebase = _MockFirebase();
    final parents = _MockCollection();
    final searchable = _MockQuery();
    when(() => firebase.parentsCollection).thenReturn(parents);
    when(() => parents.where('searchPaused', isEqualTo: false))
        .thenReturn(searchable);
    when(() => searchable.snapshots()).thenAnswer(
      (_) => Stream.value(_snapshot([
        _doc('p1', {'firstName': 'Alice'}),
        _doc('p2', {'firstName': 'Bruno'}),
      ])),
    );

    // Les enfants de p1 arrivent après ceux de p2 : l'ordre des parents
    // doit malgré tout être conservé.
    final p1Children = Completer<QuerySnapshot<Map<String, dynamic>>>();
    for (final (uid, future) in [
      ('p1', p1Children.future),
      ('p2', Future.value(
          _snapshot([_doc('c2', {'firstName': 'Zoé'})])
              as QuerySnapshot<Map<String, dynamic>>)),
    ]) {
      final children = _MockCollection();
      final ordered = _MockQuery();
      when(() => firebase.childrenCollection(uid)).thenReturn(children);
      when(() => children.orderBy('createdAt')).thenReturn(ordered);
      when(() => ordered.get()).thenAnswer((_) => future);
    }

    final result =
        AssmatSearchDatasource(firebase).watchSearchableParents().first;
    p1Children.complete(_snapshot([_doc('c1', {'firstName': 'Léo'})]));
    final list = await result;

    expect(list.map((p) => p.parent.uid), ['p1', 'p2']);
    expect(list[0].children.map((c) => c.firstName), ['Léo']);
    expect(list[1].children.map((c) => c.firstName), ['Zoé']);
  });
}
