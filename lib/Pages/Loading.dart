import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tugaskelompok/Pages/GetStart.dart';

import 'Auth/Profile.dart';

void main() => runApp(MaterialApp(
      home: LoadingPage(),
    ));

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late InterstitialAd _interstitialAd;
  bool _isAdLoaded = false;

  Future<void> _delayedNavigation() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _delayedNavigation().then((_) {
      _showInterstitialAd();
    });
  }

  @override
  void dispose() {
    _interstitialAd.dispose();
    super.dispose();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          setState(() {
            _interstitialAd = ad;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          // Continue to the next screen even if the ad fails to load
          _navigateToGetStart();
        },
      ),
    );
  }

  void _showInterstitialAd() {
    // Use the premium status obtained from the ProfilePage
    bool isPremiumUser = ProfilePage.isPremium;

    if (isPremiumUser) {
      _navigateToGetStart();
      return;
    }

    if (_isAdLoaded) {
      _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          _navigateToGetStart();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          _navigateToGetStart();
        },
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          // Ad was shown, you can perform any actions here
        },
      );
      _interstitialAd.show();
    } else {
      // If the ad failed to load, navigate to GetStart immediately
      _navigateToGetStart();
    }
  }

  void _navigateToGetStart() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GetStart(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Image.asset(
          'assets/images/Loading.png',
          width: 450.0,
          height: 450.0,
        ),
      ),
    );
  }
}
