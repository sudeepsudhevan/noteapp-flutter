import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:noteapp/data/get_all_notes_resp/get_all_notes_resp.dart';
import 'package:noteapp/data/note_model/note_model.dart';
import 'package:noteapp/data/url.dart';

abstract class ApiCalls {
  Future<NoteModel?> createNote(NoteModel value);
  Future<List<NoteModel>> getAllNotes();
  Future<NoteModel?> updateNote(NoteModel value);
  Future<void> deleteNote(String id);
}

class NoteDB extends ApiCalls {
  //== singleton

  NoteDB._internal();

  static NoteDB insatance = NoteDB._internal();

  NoteDB facotry() {
    return insatance;
  }

  //== end singleton

  final dio = Dio();

  final url = Url();

  ValueNotifier<List<NoteModel>> noteListNotifier = ValueNotifier([]);

  NoteDB() {
    dio.options = BaseOptions(
      //baseUrl: ,
      responseType: ResponseType.json,
      contentType: 'application/json',
    );
  }

  @override
  Future<NoteModel?> createNote(NoteModel value) async {
    try {
      final _result = await dio.post(
        url.baseUrl + url.createNote,
        data: value.toJson(),
      );
      //final _resultasjson = jsonDecode(_result.data);
      final note = NoteModel.fromJson(_result.data as Map<String, dynamic>);
      noteListNotifier.value.insert(0, note);
      noteListNotifier.notifyListeners();
      return note;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    final _result =
        await dio.delete(url.baseUrl + url.deleteNote.replaceFirst('{id}', id));
    if (_result.data == null) {
      return;
    }
    final _index = noteListNotifier.value.indexWhere((note) => note.id == id);
    if (_index == -1) {
      return;
    }
    noteListNotifier.value.removeAt(_index);
    noteListNotifier.notifyListeners();
  }

  @override
  Future<List<NoteModel>> getAllNotes() async {
    final _result = await dio.get(url.baseUrl + url.getAllNotes,
        options: Options(responseType: ResponseType.plain));
    if (_result.data != null) {
      final _resultAsJson = jsonDecode(_result.data);
      final getNoteResp =
          GetAllNotesResp.fromJson(_resultAsJson as Map<String, dynamic>);

      noteListNotifier.value.clear();
      noteListNotifier.value.addAll(getNoteResp.data);
      noteListNotifier.notifyListeners();
      return getNoteResp.data;
    } else {
      noteListNotifier.value.clear();
      return [];
    }
  }

  @override
  Future<NoteModel?> updateNote(NoteModel value) async {
    final _result = dio.put(url.baseUrl + url.updateNote, data: value.toJson());
    if (_result == null) {
      return null;
    }

    // find index

    final index =
        noteListNotifier.value.indexWhere((note) => note.id == value.id);
    if (index == -1) {
      return null;
    }

    // remove old note
    noteListNotifier.value.removeAt(index);

    // add new note

    noteListNotifier.value.insert(index, value);
    noteListNotifier.notifyListeners();
    return value;
  }

  NoteModel? getNoteById(String id) {
    try {
      final _note =
          noteListNotifier.value.firstWhere((element) => element.id == id);
      return _note;
    } catch (_) {
      //print(e.toString());
      return null;
    }
  }
}
