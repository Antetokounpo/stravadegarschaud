
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stravadegarschaud/models/app_model.dart';

class SaveActivityPage extends StatelessWidget {


  const SaveActivityPage({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SaveActivityForm()
      ) 
    );
  }
}

class SaveActivityForm extends StatefulWidget {
  @override
  State<SaveActivityForm> createState() => _SaveActivityFormState();
}

class _SaveActivityFormState extends State<SaveActivityForm> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController? titleController;

  @override
  void dispose() {
    titleController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var activity = context.read<AppModel>();

    titleController = TextEditingController();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: Container(
              color: theme.primaryColor,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      activity.toggleRunning(); // Restart activity because it was stopped earlier
                      Navigator.of(context).pop();
                    },
                    child: const Text("Annuler", style: TextStyle(color: Colors.white),),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if(_formKey.currentState!.validate()) {
                        String title = titleController!.text;
                        activity.saveBrosse(title);
                        activity.resetActivity(); // Now that it's saved, reset current activity
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text("Enregistrer", style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Nom de la brosse",
                border: OutlineInputBorder()
              ),
              validator: (value) {
                if(value == null || value.isEmpty) {
                  return "Entrez un nom";
                }
                return null;
              },
              controller: titleController,
            ),
          )
        ],
      ),
    );
  }
}
