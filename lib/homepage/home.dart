import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:final_640710536/helpers/api_caller.dart';
import 'package:final_640710536/helpers/my_list_tile.dart';
import 'package:final_640710536/helpers/my_text_field.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ApiCaller _apiCaller = ApiCaller();
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Call API when the page loads
  }

  Future<void> fetchData() async {
    try {
      // Perform API call
      var response = await _apiCaller.get('web_types');

      // Parse response data
      var jsonData = jsonDecode(response);
      
      setState(() {
        _data = List<Map<String, dynamic>>.from(jsonData);
      });
    } catch (e) {
      // Handle error
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _urlController = TextEditingController();
    TextEditingController _detailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Webby Fondue\nระบบรายงานเว็บเลวๆ',
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            Text('* ต้องกรอกข้อมูล', textAlign: TextAlign.center),
            SizedBox(height: 10),
            MyTextField(
              controller: _urlController,
              hintText: 'URL *',
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 20),
            MyTextField(
              controller: _detailController,
              hintText: 'รายละเอียด',
              keyboardType: TextInputType.multiline,
            ),
            SizedBox(height: 20),
            Text('ระบุประเภทเว็บเลว *'),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  var item = _data[index];
                  return MyListTile(
                    title: item['title'] ?? '',
                    subtitle: item['subtitle'] ?? '',
                    imageUrl: '${ApiCaller.host}${item['image']}' ?? '',
                    selected: item['selected'] ?? false, // Set selected state
                    onTap: () {
                      // Handle onTap event
                      setState(() {
                        _data[index]['selected'] = !_data[index]['selected'];
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String enteredUrl = _urlController.text;
                String enteredDetail = _detailController.text;

                if (enteredUrl.isEmpty) {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('ต้องกรอก URL และเลือกประเภทเว็บ'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Perform API call
                  var response = await _apiCaller.get(
                    'web_types',
                    params: {
                      'url': enteredUrl,
                      'detail': enteredDetail,
                    },
                  );

                  // Parse response data
                  var jsonData = jsonDecode(response);
                  setState(
                    () {
                      _data = List<Map<String, dynamic>>.from(jsonData);
                      
                    },
                  );
                }
              },
              child: Text('ส่งข้อมูล'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}
