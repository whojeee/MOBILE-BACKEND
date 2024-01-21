import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tugaskelompok/Pages/get_start.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugaskelompok/Tools/Model/ads_start.dart';

void main() => runApp(MaterialApp(
      home: LoadingPage(isPremiumUser: true),
    ));

class LoadingPage extends StatefulWidget {
  final bool isPremiumUser;

  const LoadingPage({Key? key, required this.isPremiumUser}) : super(key: key);

  @override
  State<LoadingPage> createState() =>
      _LoadingPageState(isPremiumUser: isPremiumUser);
}

class _LoadingPageState extends State<LoadingPage> {
  final bool isPremiumUser;
  _LoadingPageState({required this.isPremiumUser});

  InterstitialAd? _interstitialAd;

  Future<void> _delayedNavigation() async {
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  void initState() {
    super.initState();
    _sharedpref();
    _loadInterstitialAd();
    _delayedNavigation().then((_) {
      _navigateToGetStart();
    });
  }

  @override
  void dispose() {
    if (_interstitialAd != null) {
      _interstitialAd!.dispose();
    }
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
          });

          _showInterstitialAd(isPremiumUser);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _navigateToGetStart();
        },
      ),
    );
  }

  void _sharedpref() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setBool(AdsStore.everCome, true);
  }

  void _showInterstitialAd(bool isPremium) {
    _navigateToGetStart();
    // }
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
