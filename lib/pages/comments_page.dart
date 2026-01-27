import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stravadegarschaud/common/db_commands.dart';
import 'package:stravadegarschaud/common/drink_data.dart';

class CommentsPage extends StatefulWidget {
  final String brosseId;
  final String userId;

  const CommentsPage({super.key, required this.brosseId, required this.userId});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {

  void refresh() {
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
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
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: FutureBuilder(
                  future: Database.getCommentsOnActivity(widget.brosseId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Comment> comments = snapshot.data!;
                      comments.sort((a, b) => a.datetime.compareTo(b.datetime));

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) => FutureBuilder(
                          future: Database.getDisplayName(comments[index].userId),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                child: CommentTile(
                                  text: comments[index].text,
                                  userName: snapshot.data!,
                                  datetime: comments[index].datetime,
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 100, color: Colors.red),
                            Text(
                              "Erreur lors de la récupération des données de brosses",
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
            //Spacer(),
            CommentBoxForm(brosseId: widget.brosseId, userId: widget.userId, callback: refresh),
          ],
        ),
      ),
    );
  }
}

class CommentBoxForm extends StatefulWidget {
  final String brosseId;
  final String userId;
  final Function callback;

  const CommentBoxForm({
    super.key,
    required this.brosseId,
    required this.userId,
    required this.callback,
  });

  @override
  State<CommentBoxForm> createState() => _CommentBoxFormState();
}

class _CommentBoxFormState extends State<CommentBoxForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: TextFormField(
                controller: _controller,
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? "Le commentaire ne peut être vide"
                            : null,
                decoration: const InputDecoration(
                  labelText: "Ajouter un commentaire sur cette brosse",
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Database.commentActivity(
                  widget.brosseId,
                  widget.userId,
                  _controller.text,
                );

                // This is utterly RETARDED
                //Navigator.of(context).pop();
                //Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsPage(brosseId: widget.brosseId, userId: widget.userId)));

                widget.callback();

                // Clear la box de texte après soumission
                _controller.clear();
              }
            },
            child: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {

  final String text;
  final String userName;
  final DateTime datetime;

  const CommentTile({
    super.key,
    required this.text,
    required this.userName,
    required this.datetime
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.orange,
          child: Text(
            userName.split(' ').map((e) => e.toUpperCase()[0]).join()
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$userName | ${DateFormat('yyyy-MM-dd HH:mm').format(datetime)}",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        )
      ],
    );
  }
}
