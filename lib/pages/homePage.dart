import 'package:flutter/material.dart';
import 'package:seefood/components/homePage/canteenCard.dart';
import 'package:seefood/data/canteen_api/canteen_api.dart';
import 'package:seefood/data/canteen_api/canteen.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late final CanteenApi _api;
  late final Future<List<Canteen>> _canteensFuture;

  @override
  void initState() {
    super.initState();
    _api = CanteenApi();
    _canteensFuture = _api.fetchCanteens();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: 20,
        top: 0,
        end: 20,
        bottom: 0,
      ),
      child: FutureBuilder<List<Canteen>>(
        future: _canteensFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final canteens = snapshot.data!;
            return ListView.builder(
              itemCount: canteens.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CanteenCard(canteen: canteens[index]),
                );
              },
            );
          } else {
            return const Center(child: Text('No canteens found'));
          }
        },
      ),
    );
  }
}
