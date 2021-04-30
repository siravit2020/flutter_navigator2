import 'package:flutter/material.dart';

class Test2 extends StatefulWidget {
  Test2({Key key}) : super(key: key);

  @override
  _Test2State createState() => _Test2State();
}

class _Test2State extends State<Test2> {
  String _selectedPage;

  List<String> namePage = ['page1', 'page2', 'page3'];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Navigator(
        pages: [
          MaterialPage(
            key: ValueKey('BooksListPage'),
            child: BooksListScreen(
              page: namePage,
              onTapped: _handleBookTapped,
            ),
          ),
          if (_selectedPage != null)
            MaterialPage(
              child: BookDetailsScreen(book: _selectedPage),
            )
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            print('false');
            return false;
          }

          // Update the list of pages by setting _selectedBook to null
          setState(() {
            print('null');
            _selectedPage = null;
          });

          return true;
        },
      ),
    );
  }

  void _handleBookTapped(String book) {
    setState(() {
      _selectedPage = book;
    });
  }
}

class BooksListScreen extends StatelessWidget {
  final List<String> page;
  final ValueChanged<String> onTapped;

  BooksListScreen({
    @required this.page,
    @required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var book in page)
              RaisedButton(onPressed: () => onTapped(book), child: Text(book))
          ],
        ),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final String book;

  BookDetailsScreen({
    @required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(book),
          ],
        ),
      ),
    );
  }
}
