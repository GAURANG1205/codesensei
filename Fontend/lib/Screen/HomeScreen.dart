
import 'dart:async';
import 'dart:convert';

import 'package:codesensei/Common/CustomTextField.dart';
import 'package:codesensei/Modal/codeReviewModal.dart';
import 'package:codesensei/Screen/CodePasteScreen.dart';
import 'package:codesensei/Screen/CodeReviewScreen.dart';
import 'package:codesensei/Screen/CodeTranpilerScreen.dart';
import 'package:codesensei/Screen/LoginScreen.dart';
import 'package:codesensei/Screen/ReviewPage.dart';
import 'package:codesensei/Screen/RunCodeScreen.dart';
import 'package:codesensei/Theme/colors.dart';
import 'package:codesensei/logic/Auth/AuthCubit.dart';
import 'package:codesensei/logic/OtherCubit/codeTranspilerCubit.dart';
import 'package:codesensei/router/app_router.dart';
import 'package:codesensei/router/serviceLocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:highlight/languages/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _selEcIndex = 0;
  final _pageController = PageController();
  String _selectedFilter = 'All';
  String userName = "";
   @override
   void dispose(){
     super.dispose();
     _pageController.dispose();
   }
   @override
  void initState() {
    super.initState();
_loadUsername();
  }
  Future<List<Review>> fetchReviews(String userId) async {
     try{
    final response = await http.get(
      Uri.parse('http://192.168.0.115:8080/api/review/user/$userId'),
    ).timeout(const Duration(seconds: 4));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Review>.from(data.map((json) => Review.fromJson(json)));
    } else {
      throw Exception("Failed to load reviews");
    }}on TimeoutException catch(_){
       throw Exception("Request timed out. Please try again.");
     } catch (e) {
    throw Exception("Something went wrong: $e");
     }
  }
  Future<List<Review>> _loadUserAndReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? 0;
    return await fetchReviews(userId as String);
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    String storedUsername = prefs.getString('username') ?? 'User';
    setState(() {
      userName = storedUsername.isNotEmpty
          ? storedUsername[0].toUpperCase() + storedUsername.substring(1)
          : storedUsername;
    });
  }
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: isDarkMode ? DarkModeColor : LightModeColor,
          automaticallyImplyLeading: false,
          title: Text(
            "Code Sensei",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  getit<AuthCubit>().Logout();
                  getit<AppRouter>().pushAndRemoveUntil(LoginScreen());
                },
                icon: const Icon(Icons.logout_outlined))
          ],
        ),
        body: PageView(
          controller: _pageController,
         onPageChanged: (value){
          setState(() {
            _selEcIndex = value;
          });
         },
          children: [
        _HomePage(isDarkMode,size),
           ReviewPage(),
            Center(child: Text("Settings Page")),
          ],
        ),
    bottomNavigationBar:NavigationBar(
      selectedIndex: _selEcIndex,
        animationDuration: Duration(seconds: 1),
        onDestinationSelected: (value)=>setState(() {
          _selEcIndex=value;
          _pageController.jumpToPage(value);
        }),
        destinations: const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home"),
      NavigationDestination(icon:Icon(Icons.folder_shared_outlined),label: "My Reviews",),
    ]),
    );
  }
  Widget _HomePage(bool isDarkMode, Size size) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi $userName 👋,\nReady to improve some code today?',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.05
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
              getit<AppRouter>().push(CodePasteScreen());
              },
              icon: Icon(Icons.upload_file,color:isDarkMode?primaryColor:Colors.white),
              label: Text('Upload or Paste Code',style:TextStyle(color:isDarkMode?primaryColor:Colors.white),),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Reviews',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () {
                    _pageController.jumpToPage(1);
                  },
                  icon: Icon(Icons.chevron_right,color:isDarkMode?Colors.white:Colors.black ,),
                  label: Text('View All',style: TextStyle(color: isDarkMode?Colors.white:Colors.black),),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('All', isDarkMode),
                  _filterChip('Critical', isDarkMode),
                  _filterChip('Pending',  isDarkMode),
                  _filterChip('Completed',  isDarkMode),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Review>>(
              future: _loadUserAndReviews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(color: primaryColor,);
                } else if (snapshot.hasError) {
                  return Text("Error: Something Happen Try Again Later");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No Recent reviews found.");
                }

                final List<Review> sortedReviews = (_selectedFilter == 'All'
                    ? snapshot.data!
                    : snapshot.data!.where((r) => r.status == _selectedFilter).toList())
                  ..sort((a, b) => b.date.compareTo(a.date));

                final recentReviews = sortedReviews.take(5).toList();
                return Column(
                  children: recentReviews.map((review) {
                    return ListTile(
                      leading: Icon(Icons.code),
                      title: Text(review.fileName),
                      subtitle: Text('${review.status} • ${review.date.toLocal().toString().split(' ')[0]}'),
                      trailing: Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        getit<AppRouter>().push(CodeReviewScreen(
                          initialCode: review.code,
                          aiSummary: review.summary,
                          reviewId: review.id,
                          fileName: review.fileName,
                        ));
                      },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),
            Text(
              'Suggested Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                      Icons.run_circle_outlined,
                      'Run Code',
                      isDarkMode,
                (){getit<AppRouter>().push(RunCodeScreen());}
                  ),
                ),
                SizedBox(width: 16),
      Expanded(
        child: _actionButton(
          Icons.change_circle_outlined,
          'Code Transpiler',
          isDarkMode,
              () {
            getit<AppRouter>().push(
              BlocProvider<codeTranspilerCubit>(
                create: (_) => getit<codeTranspilerCubit>(),
                child: CodeTranspilerScreen(),
              ),
            );
          },
        ),
      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _filterChip(String label, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(label),
        onSelected: (bool selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        selected: _selectedFilter ==label,
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        selectedColor: isDarkMode ? primaryColor.withOpacity(0.5) : Colors.blue[100],
      ),
    );
  }
  Widget _actionButton(IconData icon, String label, bool isDarkMode,Function() voidCallBack) {
    return ElevatedButton.icon(
      onPressed: voidCallBack,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        backgroundColor: isDarkMode ? primaryColor.withOpacity(0.3) : Colors.blue[100],
        foregroundColor: isDarkMode ? Colors.white : Colors.blue[800],
      ),
    );
  }
}
