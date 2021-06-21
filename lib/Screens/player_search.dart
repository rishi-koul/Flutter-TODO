import 'package:flutter/material.dart';

class PlayerSearch extends SearchDelegate {
  List<String> soccerPlayers;
  // List<Todo> todoList;
  String selectedResult;

  PlayerSearch(this.soccerPlayers);

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Center(
        child: Text(selectedResult),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestedSoccerPlayers = [];
    query.isEmpty
        ? suggestedSoccerPlayers = soccerPlayers
        : suggestedSoccerPlayers.addAll(soccerPlayers.where(
            (element) => element.toLowerCase().contains(query.toLowerCase()),
          ));

    return ListView.builder(
        itemCount: suggestedSoccerPlayers.length,
        itemBuilder: (context, position) => ListTile(
              title: Text(suggestedSoccerPlayers[position]),
            ));
  }
}
