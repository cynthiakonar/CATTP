import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

class RandomCatDetails extends StatefulWidget {
  const RandomCatDetails({Key? key}) : super(key: key);

  @override
  State<RandomCatDetails> createState() => _RandomCatDetailsState();
}

class _RandomCatDetailsState extends State<RandomCatDetails> {
  late List data = [];
  late Future<List<dynamic>?> dataFuture;

  @override
  void initState() {
    super.initState();
    dataFuture = getRandomCat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 0,
            bottom: 40,
            right: 20,
            left: 20,
          ),
          child: FutureBuilder<List<dynamic>?>(
            future: dataFuture,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return shimmer();
                case ConnectionState.done:
                default:
                  if (snapshot.hasError) {
                    return Text('Error ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return data.isEmpty
                        ? const Center(
                            child: Text("NO Data!"),
                          )
                        : details();
                  }
                  return shimmer();
              }
            },
          ),
        ),
      ),
    );
  }

  shimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: const Center(child: Text("Loading...")),
    );
  }

  details() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
      child: Column(
        children: [
          Container(
              child: Image.network(
            data[0]["url"],
          )),
          Text(
            data.toString(),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>?> getRandomCat() async {
    final url = Uri.parse("https://api.thecatapi.com/v1/images/search");

    final response = await http.get(url, headers: {
      "api_key": "25354304-e164-4e93-93a9-3f775cd8b9c0",
    });
    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        data = json.decode(response.body);
      });
      return data;
    } else {
      throw Exception("Status Code is not 200");
    }
  }
}
