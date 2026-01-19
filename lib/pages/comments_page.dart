

import 'package:flutter/material.dart';

class CommentsPage extends StatelessWidget {

  const CommentsPage({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);


    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child : Container(
                color: theme.primaryColor,
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white)
                    )
                  ],
                ),
              )
            ),
            Spacer(),
            CommentBoxForm()
          ],
        )
      ),
    );
  }
}

class CommentBoxForm extends StatefulWidget {

  const CommentBoxForm({
    super.key
  });

  @override
  State<CommentBoxForm> createState() => _CommentBoxFormState();
}

class _CommentBoxFormState extends State<CommentBoxForm> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Ajouter un commentaire sur cette brosse"
              ),
            ),
          )),
          TextButton(
            onPressed: () {},
            child: const Icon(Icons.check)
          )
        ],
      ),
    );
  }
}