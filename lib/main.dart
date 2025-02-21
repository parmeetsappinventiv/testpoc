import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Deferred import
import 'home.dart' deferred as home;
import 'details.dart' deferred as details;

class WebRouteBuilder extends StatelessWidget {
  final Widget child;
  final Future<dynamic> Function() callback;

  const WebRouteBuilder({
    super.key,
    required this.child,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    // Log to confirm widget is being built
    print("WebRouteBuilder is being built");

    return FutureBuilder(
      future: callback(), // Call the callback function directly here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // When the Future is still loading, show a loading spinner
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // If there is an error, print it
          print("Error occurred: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future has finished, return the child widget
          return child;
        }

        // Default return in case of an unexpected connection state
        return const CircularProgressIndicator();
      },
    );
  }
}
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return FutureBuilder(
            future: home.loadLibrary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return home.HomeScreen();
              }
              return const LoadingScreen();
            },
          );
        },
      ),
      GoRoute(
        path: '/details',
        builder: (context, state) {
          return WebRouteBuilder(
            callback: () async {
              await details.loadLibrary();
              await Future.delayed(Duration(seconds: 2));
              return "Library Loaded!";  // Return some value when done
            },
            child: details.DetailsScreen(),
          );
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }
}

// Placeholder loading screen
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
