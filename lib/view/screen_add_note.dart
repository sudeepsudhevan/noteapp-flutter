import 'package:flutter/material.dart';
import 'package:noteapp/data/data.dart';
import 'package:noteapp/data/note_model/note_model.dart';

enum ActionType {
  addNote,
  editNote,
}

class ScreenAddNote extends StatelessWidget {
  final ActionType type;
  final String? id;
  ScreenAddNote({super.key, required this.type, this.id});

  @override
  Widget get saveButton => TextButton.icon(
        onPressed: () {
          switch (type) {
            case ActionType.addNote:
              saveNote();
              break;
            case ActionType.editNote:
              saveEditNote();
              break;
          }
        },
        icon: const Icon(
          Icons.save,
          color: Colors.white,
        ),
        label: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    if (type == ActionType.editNote) {
      if (id == null) {
        Navigator.pop(context);
      }

      final note = NoteDB.insatance.getNoteById(id!);
      if (note == null) {
        Navigator.pop(context);
      }

      _titleController.text = note!.title ?? 'No Title';
      _contentController.text = note.content ?? 'No Content';
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(type.name.toUpperCase()),
        actions: [
          saveButton,
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter title',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _contentController,
                maxLines: 4,
                maxLength: 100,
                decoration: const InputDecoration(
                  hintMaxLines: 4,
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                  hintText: 'Enter content',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveNote() async {
    final title = _titleController.text;
    final content = _contentController.text;

    final _knewNote = NoteModel.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
    );

    final newNote = await NoteDB.insatance.createNote(_knewNote);
    if (newNote != null) {
      print("Note saved successfully");
      Navigator.pop(_scaffoldKey.currentContext!);
    } else {
      print("Error while saving note");
    }
  }

  Future<void> saveEditNote() async {
    final _title = _titleController.text;
    final _content = _contentController.text;

    final editNote = NoteModel.create(
      id: id,
      title: _title,
      content: _content,
    );

    final _note = await NoteDB.insatance.updateNote(editNote);
    if (_note == null) {
      print('Error while updating note');
    } else {
      print('Note updated successfully');
      Navigator.pop(_scaffoldKey.currentContext!);
    }
  }
}
