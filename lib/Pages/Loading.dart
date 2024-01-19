import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tugaskelompok/Pages/Auth/auth.dart';
import 'package:tugaskelompok/Pages/GetStart.dart';
import 'package:tugaskelompok/main.dart';

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

  late InterstitialAd _interstitialAd;
  bool _isAdLoaded = true;

  Future<void> _delayedNavigation() async {
    await Future.delayed(Duration(seconds: 2));
    // _showInterstitialAd(widget.isPremiumUser);
  }

  @override
  void initState() {
    super.initState();
    // _loadInterstitialAd();
    _delayedNavigation().then((_) {
      // _showInterstitialAd(isPremiumUser);
      _navigateToGetStart();
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

          // Move the call to showInterstitialAd here
          _showInterstitialAd(isPremiumUser);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error');
          _navigateToGetStart();
        },
      ),
    );
  }

  void _showInterstitialAd(bool isPremium) {
    // Tampilkan interstitial ad hanya jika pengguna bukan premium
    // if (!isPremium) {
      // if (_isAdLoaded && _interstitialAd != true) {
      //   _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      //     onAdDismissedFullScreenContent: (InterstitialAd ad) {
      //       // Navigasi ke GetStart setelah menutup iklan
      //       _navigateToGetStart();
      //     },
      //     onAdFailedToShowFullScreenContent:
      //         (InterstitialAd ad, AdError error) {
      //       // Navigasi ke GetStart jika gagal menampilkan iklan
      //       _navigateToGetStart();
      //     },
      //     onAdShowedFullScreenContent: (InterstitialAd ad) {
      //       // Iklan ditampilkan, Anda dapat melakukan tindakan apa pun di sini
      //     },
      //   );
      //   _interstitialAd.show();
      // } else {
        // Jika iklan gagal dimuat atau tidak diinisialisasi, navigasi ke GetStart segera
        _navigateToGetStart();
      // }
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
