import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text("Destruct"),
          ),
          body: PacksPage(),
        ));
  }
}

class PacksPage extends StatefulWidget {
  @override
  _PacksPageState createState() => _PacksPageState();
}

class _PacksPageState extends State<PacksPage> {
  Future<PackResp> futurePacks;

  @override
  void initState() {
    super.initState();
    futurePacks = fetchPacks();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackResp>(
        future: futurePacks,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 100,
                    runSpacing: 100,
                    children: snapshot.data.packs
                        .map<Widget>((pack) => PackPreviewWidget(pack: pack))
                        .toList(),
                  )
                ),
              )
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner.
          return Center(child: CircularProgressIndicator());
        });
  }

  Future<PackResp> fetchPacks() async {
    final response = await http
        .get('https://cors-anywhere.herokuapp.com/api.abstruct.co/api/packs');

    print(response.body);

    if (response.statusCode == 200) {
      return PackResp.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load album');
    }
  }
}

class PackPreviewWidget extends StatelessWidget {
  const PackPreviewWidget({Key key, this.pack}) : super(key: key);

  final PackPreview pack;

  @override
  Widget build(BuildContext context) {
    return Image.network(this.pack.coverUrl, width: 200);
  }
}

class PackResp {
  final List<PackPreview> packs;

  PackResp({this.packs});

  factory PackResp.fromJson(Map<String, dynamic> json) {
    return PackResp(
        packs: json['data']
            .map<PackPreview>((pack) => PackPreview.fromJson(pack))
            .toList());
  }
}

class PackPreview {
  final int id;
  final String name;
  final String desc;
  final String coverUrl;
  final String iconUrl;

  PackPreview({this.id, this.name, this.desc, this.coverUrl, this.iconUrl});

  factory PackPreview.fromJson(Map<String, dynamic> json) {
    return PackPreview(
        id: json['id'],
        name: json['name'],
        desc: json['description'],
        coverUrl: json['cover_image_url'],
        iconUrl: json['icon_image_url']);
  }
}
