import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WordSearchScreen extends StatefulWidget {
  const WordSearchScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _WordSearchScreenState();
  }
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  TextEditingController searchTextController = TextEditingController();
  TextEditingController rowController = TextEditingController();
  TextEditingController columnController = TextEditingController();
  TextEditingController alphaController = TextEditingController();
  String searchResult = '';
  bool disableRowColumn = false;
  bool isDisplayGrid = false;
  String rowColumnError = '';
  String alphabetError = '';
  List<bool> highlightedCells = List.filled(0, false);

  @override
  void initState() {
    super.initState();
  }

  Widget button() {
    return TextButton(onPressed: () {
      setState(() {
        disableRowColumn = false;
        isDisplayGrid = false;
        searchTextController.text ='';
        rowController.text ='';
        columnController.text ='';
        alphaController.text = '';
      });
    }, child: const Text('Reset'));
  }

  List<bool> _searchAndHighlight(String searchText) {
    List<bool> result = List.filled(int.parse(rowController.text) * int.parse(columnController.text), false);

    List<String> gridText = [];
    for (int i = 0; i < int.parse(rowController.text) * int.parse(columnController.text); i++) {
      gridText.add(alphaController.text[i % alphaController.text.length]);
    }

    // Search and highlight (left to right)
    for (int i = 0; i < gridText.length; i++) {
      if (gridText.length - i >= searchText.length) {
        String substring = gridText.sublist(i, i + searchText.length).join();
        if (substring == searchText) {
          for (int j = i; j < i + searchText.length; j++) {
            result[j] = true;
          }
        }
      }
    }

    // Search and highlight in top to bottom (south) direction
    for (int i = 0; i < int.parse(columnController.text); i++) {
      List<String> column = [];
      for (int j = i; j < gridText.length; j += int.parse(columnController.text)) {
        column.add(gridText[j]);
      }
      if (_isTextReadable(column, searchText)) {
        for (int j = i; j < gridText.length; j += int.parse(columnController.text)) {
          result[j] = true;
        }
      }
    }

    // Search and highlight in diagonal (south-east) direction
    for (int i = 0; i < gridText.length; i += int.parse(columnController.text)) {
      List<String> diagonal = [];
      for (int j = i, k = 0; j < gridText.length && k < int.parse(columnController.text); j += int.parse(columnController.text) + 1, k++) {
        diagonal.add(gridText[j]);
      }
      if (_isTextReadable(diagonal, searchText)) {
        for (int j = i, k = 0; j < gridText.length && k < int.parse(columnController.text); j += int.parse(columnController.text) + 1, k++) {
          result[j] = true;
        }
      }
    }

    return result;
  }

  bool _isTextReadable(List<String> text, String searchText) {
    // Customize this function based on your readability criteria
    // For example, you may want to check if the text matches the searchText
    return text.join().contains(searchText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Word Search"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text('Enter row and column'),
              TextField(
                keyboardType: TextInputType.number,
                enabled: !disableRowColumn,
                controller: rowController,
                decoration: const InputDecoration(
                  labelText: "enter row",
                ),
              ),
              TextField(
                enabled: !disableRowColumn,
                keyboardType: TextInputType.number,
                controller: columnController,
                decoration: const InputDecoration(
                  labelText: "enter column",
                ),
              ),
              if (rowColumnError.isNotEmpty)
                Text(
                  rowColumnError,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              if (!disableRowColumn)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      button(),
                      ElevatedButton(
                        onPressed: () {
                          if (rowController.text.isNotEmpty &&
                              columnController.text.isNotEmpty) {
                            setState(() {
                              rowColumnError = '';
                              disableRowColumn = true;
                            });
                          } else {
                            setState(() {
                              rowColumnError = 'Please enter values in row and column';
                            });
                          }
                        },
                        child: const Text("Enter Alphabets"),
                      ),
                    ],
                  ),
                ),
              if (disableRowColumn)
                TextField(
                  keyboardType: TextInputType.text,
                  controller: alphaController,
                  inputFormatters: [
                    FilteringTextInputFormatter(RegExp('[A-Z]'),
                        allow: true),
                  ],
                  textCapitalization: TextCapitalization.characters,
                  maxLength: int.parse(rowController.text) *
                      int.parse(columnController.text),
                  decoration: const InputDecoration(
                    labelText: "enter alphabets",
                  ),
                ),
              if (alphabetError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    alphabetError,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                  ),
                ),
              if (isDisplayGrid)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: searchTextController,
                    maxLength: int.parse(rowController.text) *
                        int.parse(columnController.text),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp('[A-Z]'), allow: true),
                    ],
                    decoration: const InputDecoration(
                        labelText: "Search text",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        )),
                  ),
                ),
              if (disableRowColumn && !isDisplayGrid)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      button(),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (alphaController.text.length ==
                                int.parse(rowController.text) *
                                    int.parse(columnController.text)) {
                              isDisplayGrid = true;
                              alphabetError = '';
                            } else {
                              isDisplayGrid = false;
                              alphabetError =
                                  'no. of alphabets should be ${int.parse(rowController.text) * int.parse(columnController.text)}';
                            }
                          });
                        },
                        child: const Text("Create Grid"),
                      ),
                    ],
                  ),
                ),
              if(disableRowColumn && isDisplayGrid) Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    button(),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          setState(() {
                            highlightedCells =
                                _searchAndHighlight(searchTextController.text);
                          });
                        });
                      },
                      child: const Text("Search Text"),
                    ),
                  ],
                ),
              ),
              if (isDisplayGrid && alphaController.text.isNotEmpty)
                SizedBox(
                  height: 300,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: int.parse(columnController.text),
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: highlightedCells.isNotEmpty ? highlightedCells[index] ? Colors.yellow : Colors.white : null,
                        ),
                        child: Center(
                          child: Text(
                            alphaController
                                .text[index % alphaController.text.length],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      );
                    },
                    itemCount: int.parse(rowController.text) *
                        int.parse(columnController.text),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
