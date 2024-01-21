import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tugaskelompok/Pages/Auth/Login.dart';
import 'package:tugaskelompok/Pages/Auth/Profile.dart';
import 'package:tugaskelompok/Pages/Auth/auth.dart';
import 'package:tugaskelompok/Pages/EditEvent.dart';
import 'package:tugaskelompok/Pages/GetStart.dart';
import 'package:tugaskelompok/Pages/NewEvent.dart';
import 'package:tugaskelompok/Pages/Loading.dart';
import 'package:tugaskelompok/botnav.dart';
import 'Pages/Calendar.dart';
import 'Drawer.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:tugaskelompok/Tools/Model/event_model.dart';
import 'package:tugaskelompok/Tools/Database/Database_helper.dart';
import 'package:tugaskelompok/Tools/Model/AdsStart.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:localization/localization.dart  ';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  await requestPermission();

  bool isPremiumUser = false;

  runApp(MyApp(
    isPremiumUser: isPremiumUser,
  ));
}

Future<void> requestPermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

class MyApp extends StatelessWidget {
  final bool isPremiumUser;

  const MyApp({Key? key, required this.isPremiumUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LocalJsonLocalization.delegate.directories = ['lib/i18n'];
    return MaterialApp(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'),
        Locale('ja', 'JP'),
        Locale('it', 'IT'),
        Locale('ko', 'KR'),
        Locale('zh', 'CN'),
        Locale('es', 'ES'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        LocalJsonLocalization.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (supportedLocales.contains(locale)) {
          return locale;
        }
        return const Locale('id', 'ID');
      },
      title: 'Planner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (_) => MyHomePage(
            title: "Daily-Minder".i18n(), isPremiumUser: isPremiumUser)
      },
      home: LoadingPage(
        isPremiumUser: isPremiumUser,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final String? email;

  const MyHomePage(
      {Key? key, required this.title, this.email, required bool isPremiumUser});

  @override
  State<MyHomePage> createState() => _MyHomePageState(isPremiumUser: false);
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  List<EventModel> events = [];
  int eventCount = 0;
  late AuthFirebase auth;

  var isPremiumUser;

  _MyHomePageState({required this.isPremiumUser});

  final List<Widget> _children = [
    HomePage(
      onPremiumStatusReceived: (p0) {},
    ),
    CalendarPage(),
  ];
  StreamController<int> myNotificationStreamController =
      StreamController<int>.broadcast();
  @override
  void dispose() {
    super.dispose();
    myNotificationStreamController.close();
  }

  @override
  void initState() {
    super.initState();
    auth = AuthFirebase();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout() async {
    await auth.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.title),
            SizedBox(width: 10),
            StreamBuilder<int>(
              stream: DatabaseHelper.instance.eventCountStream,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data! > 0) {
                  return Stack(
                    children: [
                      Icon(Icons.notifications),
                      Positioned(
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 8,
                          child: Text(
                            snapshot.data.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Icon(Icons.notifications);
                }
              },
            )
          ],
        ),
      ),
      drawer: MyDrawer(
        email: widget.email ?? "user@example.com",
        logoutCallback: _logout,
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        onTabTapped: onTabTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(bool) onPremiumStatusReceived;

  HomePage({Key? key, required this.onPremiumStatusReceived}) : super(key: key);

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
  StreamSubscription<bool>? _premiumStatusSubscription;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool isPremium = false;
  bool isUserPremium = false;

  StreamController<bool> _premiumStatusStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get premiumStatusStream => _premiumStatusStreamController.stream;

  late InterstitialAd _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  bool shouldShowInterstitialAd = true;

  @override
  void initState() {
    super.initState();
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

  Future<void> _loadPremiumStatus() async {
    try {
      final User? user = await AuthFirebase().getUser();

      if (user != null) {
        final String userUid = user.uid;
        final DocumentSnapshot userDoc =
            await _firestore.collection('profile').doc(userUid).get();

        if (userDoc.exists) {
          final Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

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
        }
      }
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
        request: AdRequest(),
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
        request: AdRequest(),
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
      return SizedBox.shrink();
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
      final eventsData = await DatabaseHelper.instance.queryAllEvents();
      print('loaded events : $eventsData');
      if (eventsData != null && mounted) {
        eventsData.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        setState(() {
          events = eventsData;
          completedEvents = events.where((event) => event.isChecked).toList();
          unfinishedEvents = events.where((event) => !event.isChecked).toList();
        });
      }
    }
  }

  void _handleEditButton(EventModel event) async {
    final updatedEvent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(
          initialEvent: event,
        ),
      ),
    );

    if (updatedEvent != null) {
      await DatabaseHelper.instance.updateEvent(updatedEvent.toMap());
      setState(() {
        events.removeWhere((e) => e.id == event.id);
        events.add(updatedEvent);
        events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        DatabaseHelper.instance.updateEventCount();
        // Update completed and unfinished events lists
        completedEvents = events.where((event) => event.isChecked).toList();
        unfinishedEvents = events.where((event) => !event.isChecked).toList();
      });
    }
  }

  Widget _buildList(List body) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: body.length,
      itemBuilder: (context, index) {
        String formattedDate = DateFormat('EEEE, d - MM - y')
            .format(DateTime.parse(body[index].eventDate));
        return GestureDetector(
          onTap: () {
            _handleEditButton(body[index]);
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Checkbox(
                    value: body[index].isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _handleCheckboxChanged(body, index, value!);
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              body[index].eventName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          body[index].eventDescription,
                          style: TextStyle(fontSize: 14),
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
    return events == null || events.isEmpty
        ? Center(child: Text('No-events-available'.i18n()))
        : completedEvents.isEmpty
            ? _buildList(unfinishedEvents)
            : Column(
                children: [
                  _buildList(unfinishedEvents),
                  Text("Done"),
                  Divider(),
                  _buildList(completedEvents),
                ],
              );
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
        DatabaseHelper.instance.updateEventCount();
      });
    }
  }

  void _handleCheckboxChanged(List eventList, int index, bool value) async {
    if (mounted) {
      setState(() {
        eventList[index].isChecked = value;
        if (value) {
          completedEvents.add(eventList[index]);
          unfinishedEvents.remove(eventList[index]);
        } else {
          unfinishedEvents.add(eventList[index]);
          completedEvents.remove(eventList[index]);
        }

        events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
        _isNewEventAdded = true;
      });
      await _updateDatabase(eventList[index]);
    }
  }

  Future<void> _updateDatabase(EventModel updatedEvent) async {
    final Map<String, dynamic> eventMap = updatedEvent.toMap();
    await DatabaseHelper.instance.updateEvent(eventMap);
    await DatabaseHelper.instance.updateEventCount();
  }

  // void _handleCheckboxChanged(int index, bool value) async {
  //   print('Checkbox changed: $index, $value');

  //   if (value && index < events.length && events[index].id != null) {
  //     print("Deleting event with ID: ${events[index].id}");

  //     await DatabaseHelper.instance.deleteEvent(events[index].id!);

  //     DatabaseHelper.instance.updateEventCount();

  //     if (index == 0) {
  //       final User? user = await AuthFirebase().getUser();
  //       if (user != null) {
  //         final String userUid = user.uid;
  //         await FirebaseFirestore.instance
  //             .collection('profile')
  //             .doc(userUid)
  //             .update({
  //           'premium': true,
  //         });

  //         setState(() {
  //           isPremium = true;
  //         });

  //         ProfilePage.isPremium = true;
  //       }
  //     }
  //   }

  //   setState(() {
  //     events[index].isChecked = value;
  //     events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
  //     _isNewEventAdded = true;
  //   });
  // }

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
          child: Icon(Icons.create),
        ),
      ),
    );
  }

  void _handleNewEventAdded(EventModel addedEvent) async {
    setState(() {
      events.add(addedEvent);
      events.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    });

    DatabaseHelper.instance.updateEventCount();

    await _loadEvents();
  }

  void _navigateToGetStart() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GetStart(),
      ),
    );
  }
}
