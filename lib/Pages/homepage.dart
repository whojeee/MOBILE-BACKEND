import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:localization/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugaskelompok/Pages/Auth/auth.dart';
import 'package:tugaskelompok/Pages/edit_event.dart';
import 'package:tugaskelompok/Pages/new_event.dart';
import 'package:tugaskelompok/Tools/Database/Database_helper.dart';
import 'package:tugaskelompok/Tools/Model/ads_start.dart';
import 'package:tugaskelompok/Tools/Model/event_model.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onPremiumStatusReceived;

  const HomePage({Key? key, required this.onPremiumStatusReceived})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController(initialPage: 0);
  int currentIndex = 0;
  int eventCount = 0;
  List<EventModel> events = [];
  List<EventModel> completedEvents = [];
  List<EventModel> unfinishedEvents = [];
  bool _isNewEventAdded = false;
  StreamController<int> notificationStreamController = StreamController<int>();
  Stream<int> get notificationStream => notificationStreamController.stream;
  Sink<int> get notificationSink => notificationStreamController.sink;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? user;
  late String userUid;
  late DocumentSnapshot userDoc;
  late Map<String, dynamic> userData;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool isPremium = false;
  bool isUserPremium = false;

  final StreamController<bool> _premiumStatusStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get premiumStatusStream => _premiumStatusStreamController.stream;

  late InterstitialAd _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  bool shouldShowInterstitialAd = true;

  @override
  void initState() {
    super.initState();
    _setFirebaseVar();
    checkOnboardingStatus();
    _loadPremiumStatus();
    _loadEvents();
    DatabaseHelper.instance.eventCountStream.listen((count) {
      setState(() {
        eventCount = count;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    notificationStreamController.close();
  }

  Future<void> _setFirebaseVar() async {
    user = await AuthFirebase().getUser();
    userUid = user!.uid;
    userDoc = await _firestore.collection('profile').doc(userUid).get();
    if (userDoc.exists) {
      userData = userDoc.data() as Map<String, dynamic>;
    }
  }

  Future<void> _loadPremiumStatus() async {
    try {
      setState(() {
        isUserPremium = userData['premium'] ?? false;
        print('Premium status loaded: $isUserPremium');
        _premiumStatusStreamController.add(isUserPremium);
      });

      if (!isUserPremium) {
        _initAdMob();
        _initInterstitialAd(isUserPremium);
      }

      widget.onPremiumStatusReceived(isUserPremium);
    } catch (error) {
      print('Error loading premium status: $error');
    }
  }

  void checkOnboardingStatus() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    bool hasCompletedOnboarding = _pref.getBool(AdsStore.everCome) ?? true;

    print("HasCompletedOnBoarding");
    print(hasCompletedOnboarding);
    if (hasCompletedOnboarding) {
      print("berhasil");
      shouldShowInterstitialAd = false;
      SharedPreferences _pref = await SharedPreferences.getInstance();
      _pref.setBool(AdsStore.everCome, false);
    } else {
      print("yah ini deh");
      SharedPreferences _pref = await SharedPreferences.getInstance();
      _pref.setBool(AdsStore.everCome, true);
      shouldShowInterstitialAd = true;
    }
  }

  void _initAdMob() {
    if (!isUserPremium) {
      _bannerAd = BannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/6300978111',
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isAdLoaded = true;
            });
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      );
      _bannerAd!.load();
    }
  }

  void _initInterstitialAd(bool isUserPremium) {
    if (!isUserPremium) {
      InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            setState(() {
              _interstitialAd = ad;
              _isInterstitialAdLoaded = true;
            });
            _showInterstitialAd(isUserPremium);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ),
      );
    }
  }

  void _showInterstitialAd(bool isPremium) {
    print(isPremium);
    if (!isPremium) {
      print(_isInterstitialAdLoaded);
      print(shouldShowInterstitialAd);
      if (_isInterstitialAdLoaded && shouldShowInterstitialAd) {
        print("berhasil");
        _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            setState(() {
              _isInterstitialAdLoaded = false;
            });
          },
          onAdFailedToShowFullScreenContent:
              (InterstitialAd ad, AdError error) {
            setState(() {
              _isInterstitialAdLoaded = false;
            });
          },
          onAdShowedFullScreenContent: (InterstitialAd ad) {
            _isInterstitialAdLoaded = false;
          },
        );
        _interstitialAd.show();
      } else {
        return;
      }
    }
  }

  Widget _buildAd() {
    if (isUserPremium || !_isAdLoaded) {
      return const SizedBox.shrink();
    } else {
      return Container(
        alignment: Alignment.bottomCenter,
        child: AdWidget(ad: _bannerAd!),
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
      );
    }
  }

  Future<void> _loadEventCount() async {
    DatabaseHelper.instance.eventCountStream.listen((count) {
      setState(() {
        eventCount = count;
        notificationSink.add(count);
      });
    });
  }

  Future<void> _loadEvents() async {
    if (mounted) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String userEmail = user.email ?? "";
          final eventsData =
              await DatabaseHelper.instance.queryAllEvents(userEmail);
          if (mounted) {
            eventsData.sort((a, b) => a.eventDate.compareTo(b.eventDate));
            setState(() {
              events = eventsData;
              completedEvents =
                  events.where((event) => event.isChecked).toList();
              unfinishedEvents =
                  events.where((event) => !event.isChecked).toList();
            });
          }
        }
      } catch (error) {
        print('Error loading events: $error');
      }
    }
  }

  void _handleDeleteButton(EventModel event) async {
    await DatabaseHelper.instance.deleteEvent(event.id!);

    setState(() {
      events.removeWhere((e) => e.id == event.id);
      completedEvents.removeWhere((e) => e.id == event.id);
      unfinishedEvents.removeWhere((e) => e.id == event.id);

      DatabaseHelper.instance.updateEventCount(userData['email']);
    });
  }

  void _handleEditButton(EventModel event) async {
    final updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(
          initialEvent: event,
          onDelete: _handleDeleteButton,
        ),
      ),
    );

    if (updatedEvent != null) {
      // Simpan perubahan pada database SQFlite
      await DatabaseHelper.instance.updateEvent(updatedEvent.toMap());

      setState(() {
        events.removeWhere((e) => e.id == event.id);
        events.add(updatedEvent);

        events.sort((a, b) => a.eventDate.compareTo(b.eventDate));

        completedEvents = events.where((event) => event.isChecked).toList();
        unfinishedEvents = events.where((event) => !event.isChecked).toList();

        DatabaseHelper.instance.updateEventCount(userData['email']);
      });
    } else {
      await _loadEvents();
    }
  }

  Widget _buildList(List body) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: body.length,
      itemBuilder: (context, index) {
        final eventName = body[index];
        String formattedDate = DateFormat('EEEE, d - MM - y')
            .format(DateTime.parse(eventName.eventDate));
        return GestureDetector(
          onTap: () {
            _handleEditButton(eventName);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Checkbox(
                    value: eventName.isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _handleCheckboxChanged(eventName, eventName.id, value!);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              eventName.eventName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          eventName.eventDescription,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (events.isEmpty) {
      return Center(child: Text('No-events-available'.i18n()));
    } else {
      return completedEvents.isEmpty
          ? _buildList(unfinishedEvents)
          : Column(
              children: [
                _buildList(unfinishedEvents),
                const Text("Done"),
                const Divider(),
                _buildList(completedEvents),
              ],
            );
    }
  }

  void _handleAddButton() async {
    final addedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewEventPage(
          onNewEventAdded: _handleNewEventAdded,
        ),
      ),
    );

    if (addedEvent != null) {
      await DatabaseHelper.instance.insertEvent(addedEvent.toMap());
      setState(() {
        events.add(addedEvent);
        events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        DatabaseHelper.instance.updateEventCount(userData['email']);
      });
    }
  }

  void _handleCheckboxChanged(EventModel event, int id, bool value) async {
    if (mounted && value) {
      event.isChecked = value;
      await _updateDatabase(event, id);

      setState(() {
        completedEvents.add(event);
        unfinishedEvents.remove(event);
        events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        completedEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        unfinishedEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      });
    } else {
      event.isChecked = value;
      await _updateDatabase(event, id);

      setState(() {
        unfinishedEvents.add(event);
        completedEvents.remove(event);
        events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        completedEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        unfinishedEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      });
    }
  }

  Future<void> _updateDatabase(EventModel updatedEvent, int id) async {
    final Map<String, dynamic> eventMap = updatedEvent.toMap();
    await DatabaseHelper.instance.updateEventChecked(id, eventMap);
    await DatabaseHelper.instance.updateEventCount(userData['email']);
  }

  @override
  Widget build(BuildContext context) {
    if (_isNewEventAdded) {
      _isNewEventAdded = false;
    }
    events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBody(),
            _buildAd(),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            _handleAddButton();
          },
          child: const Icon(Icons.create),
        ),
      ),
    );
  }

  void _handleNewEventAdded(EventModel addedEvent) async {
    setState(() {
      events.add(addedEvent);
      events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    });

    DatabaseHelper.instance.updateEventCount(userData['email']);

    await _loadEvents();
  }
}
