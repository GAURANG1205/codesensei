import 'dart:convert';

import 'package:codesensei/Common/ScaffoldMessage.dart';
import 'package:codesensei/Screen/CodeReviewScreen.dart';
import 'package:codesensei/Theme/colors.dart';
import 'package:codesensei/router/app_router.dart';
import 'package:codesensei/router/serviceLocator.dart';
import 'package:flutter/material.dart';
import 'package:highlight/languages/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Modal/codeReviewModal.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPage createState() => _ReviewPage();
}

class _ReviewPage extends State<ReviewPage> {
  TextEditingController _searchController = TextEditingController();
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndReviews();
  }

  Future<void> _loadUserAndReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    if (userId.isEmpty) return;

    final response = await http.get(
      Uri.parse('http://192.168.0.115:8080/api/review/user/$userId'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        _reviews = data.map((e) => Review.fromJson(e)).toList();
        _isLoading = false;
      });
    } else {
      throw Exception("Failed to load reviews");
    }
  }
  Future<void> _deleteReview(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.0.115:8080/api/review/delete/$id'),
      );

      if (response.statusCode == 200) {
        print("Review deleted");
      } else {
        print("Server responded: ${response.statusCode}, Body: ${response.body}");
        throw Exception("Failed to delete review");
      }
    } catch (e) {
      print("Delete error: $e");
      throw Exception("Failed to delete review: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness==Brightness.dark;
    final filteredReviews = _reviews.where((review) {
      final query = _searchController.text.toLowerCase();
      return review.fileName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search reviews...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredReviews.length,
                itemBuilder: (context, index) {
                  final review = filteredReviews[index];
                  return Dismissible(
                    key: ValueKey(review.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.delete, color: isDarkMode?Colors.blueGrey:Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Review'),
                          content: Text('Are you sure you want to delete this review?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (direction) async {
                      await _deleteReview(review.id!);
                      setState(() {
                        _reviews.removeAt(index);
                      });
                      ScaffoldMessage.showSnackBar(context, message: "Review Deleted",isError: false);
                    },
                    child: Card(
                      color: isDarkMode ? DarkModeColor.withOpacity(0.9) : LightModeColor.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.insert_drive_file, color: Colors.blueAccent),
                        title: Text(
                          review.fileName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          review.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 18),
                                SizedBox(width: 4),
                                Text(review.rating.toString()),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              review.date.toLocal().toString().split(' ')[0],
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () {
                          getit<AppRouter>().push(CodeReviewScreen(initialCode: review.code, aiSummary: review.summary,reviewId: review.id,            // NEW
                              fileName: review.fileName));
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}