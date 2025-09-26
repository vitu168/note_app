import 'package:note_app/model/model.dart';
import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  final Model? note;
  AddPage({this.note});
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _fromKey = GlobalKey<FormState>();
  late String _title;
  late String _contexnt;
  late String _description;
  late bool _isFavorite;

  @override
  void InitState() {
    super.initState();
    _title = widget.note?.title ?? '';
    _contexnt = widget.note?.content ?? '';
    _description = widget.note?.description ?? '';
    _isFavorite = widget.note?.isFavorite ?? false;
  }

  void _saveNote() async {
    if (_fromKey.currentState!.validate()) {
      _fromKey.currentState!.save();
      final now = DateTime.now().toIso8601String();
      final note = Model(
        id: widget.note?.id,
        title: _title,
        content: _contexnt,
        description: _description,
        date: now,
        isFavorite: _isFavorite,
      );
      try {
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Saving note: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
                key: _fromKey,
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    TextFormField(
                      initialValue: _title,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) => _title = value!,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: _description,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      onSaved: (value) => _description = value!,
                    )
                  ],
                )))));
  }
}
