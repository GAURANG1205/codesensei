import 'package:codesensei/Theme/colors.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPage createState() => _ReviewPage();
}

class _ReviewPage extends State<ReviewPage> {
  TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _reviews = [
    {
      'fileName': 'LoginScreen.dart',
      'rating': 4.7,
      'summary': 'Great use of Bloc pattern...',
      'date': '25 Apr',
    },
    {
      'fileName': 'ChatService.java',
      'rating': 2,
      'summary': 'Handle exceptions properly...',
      'date': '24 Apr',
    },
    {
      'fileName': 'ProfileScreen.js',
      'rating': 4.8,
      'summary': 'Excellent modularization...',
      'date': '23 Apr',
    },
  ];
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.of(context).platformBrightness==Brightness.dark;
    final filteredReviews = _reviews.where((review) {
      final query = _searchController.text.toLowerCase();
      return review['fileName'].toLowerCase().contains(query);
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
                  return Card(
                    color: isDarkMode?DarkModeColor.withOpacity(0.9):LightModeColor.withOpacity(0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.insert_drive_file, color: Colors.blueAccent),
                      title: Text(
                        review['fileName'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(review['summary']),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 18),
                              SizedBox(width: 4),
                              Text(review['rating'].toString()),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            review['date'],
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
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