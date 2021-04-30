import 'package:flutter/material.dart';

void main() {
  runApp(PageApp());
}

class PageRoutePath {
  final int id;
  final bool isUnknown;

  PageRoutePath.home()
      : id = null,
        isUnknown = false;

  PageRoutePath.details(this.id) : isUnknown = false;

  PageRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;

  bool get isDetailsPage => id != null;
}

class PageApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PageAppState();
}

class _PageAppState extends State<PageApp> {
  PageRouterDelegate _routerDelegate = PageRouterDelegate();
  PageRouteInformationParser _routeInformationParser =
      PageRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class PageRouteInformationParser extends RouteInformationParser<PageRoutePath> {
  @override
  Future<PageRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    // Handle '/'
    print('Uri : ${uri.pathSegments}');
    if (uri.pathSegments.length == 0) {
      print('information home');
      return PageRoutePath.home();
    }

    // Handle '/book/:id'
    if (uri.pathSegments.length == 2) {
      print('information ${uri.pathSegments[0]}');
      if (uri.pathSegments[0] != 'page') return PageRoutePath.unknown();
      var remaining = uri.pathSegments[1];
      var id = int.tryParse(remaining);
      if (id == null) return PageRoutePath.unknown();
      return PageRoutePath.details(id);
    }

    // Handle unknown routes
    return PageRoutePath.unknown();
  }

  @override
  RouteInformation restoreRouteInformation(PageRoutePath path) {
    print('restoreRoute ${path.id}');
    if (path.isUnknown) {
      return RouteInformation(location: '/404');
    }
    if (path.isHomePage) {
      return RouteInformation(location: '/');
    }
    if (path.isDetailsPage) {
      return RouteInformation(location: '/page/${path.id}');
    }
    return null;
  }
}

class PageRouterDelegate extends RouterDelegate<PageRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PageRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;
  List<String> namePage = ['page1', 'page2', 'page3'];
  String _selectedPage;
  bool show404 = false;

  PageRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  PageRoutePath get currentConfiguration {
    print('current ${namePage.indexOf(_selectedPage)}');
    if (show404) {
      return PageRoutePath.unknown();
    }
    return _selectedPage == null
        ? PageRoutePath.home()
        : PageRoutePath.details(namePage.indexOf(_selectedPage));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('BooksListPage'),
          child: PagesListScreen(
            pages: namePage,
            onTapped: _handleBookTapped,
          ),
        ),
        if (show404)
          MaterialPage(key: ValueKey('UnknownPage'), child: UnknownScreen())
        else if (_selectedPage != null)
          PagesDetailsPage(book: _selectedPage)
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        _selectedPage = null;
        show404 = false;
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(PageRoutePath path) async {
    if (path.isUnknown) {
      print('path unknow');
      _selectedPage = null;
      show404 = true;
      return;
    }

    if (path.isDetailsPage) {
      print('path ${path.isDetailsPage}');
      if (path.id < 0 || path.id > namePage.length - 1) {
        show404 = true;
        return;
      }
      _selectedPage = namePage[path.id];
      
    } else {
      print('path false');
      _selectedPage = null;
    }

    show404 = false;
  }

  void _handleBookTapped(String book) {
    _selectedPage = book;
    notifyListeners();
  }
}

class PagesDetailsPage extends Page {
  final String book;

  PagesDetailsPage({
    this.book,
  }) : super(key: ValueKey(book));

  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return PageDetailsScreen(book: book);
      },
    );
  }
}

class PagesListScreen extends StatelessWidget {
  final List<String> pages;
  final ValueChanged<String> onTapped;

  PagesListScreen({
    @required this.pages,
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
            for (var index = 0; index < pages.length; index++)
              RaisedButton(
                  color: Colors.amber[(index+1) * 100],
                  onPressed: () => onTapped(pages[index]),
                  child: Text(pages[index]))
          ],
        ),
      ),
    );
  }
}

class PageDetailsScreen extends StatelessWidget {
  final String book;

  PageDetailsScreen({
    @required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
        child: Text(book,style: TextStyle(fontSize: 30),),
      ),
      ),
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('404!'),
      ),
    );
  }
}
