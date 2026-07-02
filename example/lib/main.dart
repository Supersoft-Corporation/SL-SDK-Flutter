import 'package:flutter/material.dart';
import 'package:softlink_flutter/softlink_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _screen = 'None';
  Map<String, dynamic> _params = {};

  @override
  void initState() {
    super.initState();
    SoftLink.init(
      baseUrl: 'https://api-link.supersoft.com.pk',
      apiKey: 'sl_your_api_key_here',
      onDeepLink: (deepLink) {
        if (deepLink == null) return;
        setState(() {
          _screen = deepLink.screen;
          _params = deepLink.params;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoftLink Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('SoftLink Example')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Screen: $_screen', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Params: $_params', style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  final url = await SoftLink.generateReferralLink(
                    screenKey: 'PRODUCT_DETAIL',
                    values: {'productCode': '207'},
                    referrerId: 'USER_123',
                  );
                  if (url != null) {
                    debugPrint('Generated link: $url');
                  }
                },
                child: const Text('Generate Referral Link'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
