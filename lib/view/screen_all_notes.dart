import 'package:flutter/material.dart';
import 'package:noteapp/data/data.dart';
import 'package:noteapp/data/note_model/note_model.dart';
import 'package:noteapp/view/screen_add_note.dart';

class ScreenAllNotes extends StatelessWidget {
  ScreenAllNotes({super.key});

  // final List<NoteModel> noteList = [];

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NoteDB.insatance.getAllNotes();

      // print(note);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Notes'),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: NoteDB.insatance.noteListNotifier,
          builder: (context, List<NoteModel> newNotes, _) {
            if (newNotes.isEmpty) {
              return const Center(
                child: Text('No Notes'),
              );
            }
            return GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.all(20),
              children: List.generate(
                newNotes.length,
                (index) {
                  final _note = NoteDB.insatance.noteListNotifier.value[index];
                  if (_note.id == null) {
                    return const SizedBox();
                  }
                  return NoteItem(
                    id: _note.id!,
                    title: _note.title ?? 'No Title',
                    content: _note.content ?? 'No Content',
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => ScreenAddNote(type: ActionType.addNote),
            ),
          );
        },
        label: const Text('Add Note'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class NoteItem extends StatelessWidget {
  final String id;
  final String title;
  final String content;

  const NoteItem(
      {super.key,
      required this.id,
      required this.title,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ScreenAddNote(
              type: ActionType.editNote,
              id: id,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    NoteDB.insatance.deleteNote(id);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                )
              ],
            ),
            Text(
              content,
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
