import 'package:flutter/material.dart';
import 'package:github_repo/provider/connectivity_provider.dart';
import 'package:provider/provider.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Consumer<ConnectivityProvider>(
            builder: (context, result, child) {
              return Text(
                result.isConnectivity
                    ? "Internet Connection is on"
                    : "Internet Connection is Off",
              );
            },
          ),
        ),
      ),
    );
  }
}
