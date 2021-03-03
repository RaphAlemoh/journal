import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/services/db_firestore_api.dart';

class DbFirestoreService implements DbApi {
    Firestore _firestore = Firestore.instance;
    String _collectionJournals = 'journals';

    DbFirestoreService() {
    _firestore.settings();
    }


  Stream<List<Journal>> getJournalList(String uid) {
    return _firestore
        .collection(_collectionJournals)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((QuerySnapshot snapshot) {
    List<Journal> _journalDocs = snapshot.documents.map((doc) => Journal.fromDoc(doc)).toList();
    _journalDocs.sort((comp1, comp2) => comp2.date.compareTo(comp1.date));
    return _journalDocs;
    });
  }

  Future<Journal> getJournal(String documentID) {
    return _firestore
        .collection(_collectionJournals)
        .document(documentID)
        .get()
        .then((documentSnapshot) {
      return Journal.fromDoc(documentSnapshot);
    });
  }

  Future<bool> addJournal(Journal journal) async {
      DocumentReference _documentReference =
      await _firestore.collection(_collectionJournals).add({
      'date': journal.date,
      'mood': journal.mood,
      'note': journal.note,
      'uid': journal.uid,
    });
    return _documentReference.documentID != null;
  }


    void updateJournal(Journal journal) async {
        await _firestore
        .collection(_collectionJournals)
        .document(journal.documentID)
        .updateData({
        'date': journal.date,
        'mood': journal.mood,
        'note': journal.note,
        })
        .catchError((error) => print('Error updating: $error'));
    }

  void updateJournalWithTransaction(Journal journal) async {
    DocumentReference _documentReference = _firestore.collection(_collectionJournals).document(journal.documentID);
    var journalData = {
      'date': journal.date,
      'mood': journal.mood,
      'note': journal.note,
    };
    _firestore.runTransaction((transaction) async {
      await transaction
          .update(_documentReference, journalData)
          .catchError((error) => print('Error updating: $error'));
    });
  }

    void deleteJournal(Journal journal) async {
      await _firestore
      .collection(_collectionJournals)
      .document(journal.documentID)
      .delete()
      .catchError((error) => print('Error deleting: $error'));
    }

}