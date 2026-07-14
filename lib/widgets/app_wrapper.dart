import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youbike_android/screens/home_screen.dart';
import 'package:youbike_android/viewmodels/loading_view_model.dart';
import 'package:youbike_android/viewmodels/station_view_model.dart';
import 'package:youbike_android/viewmodels/map_view_model.dart';
import 'package:youbike_android/widgets/loading_overlay.dart';
import 'package:youbike_android/services/log_service.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loadingVm = Provider.of<LoadingViewModel>(context, listen: false);
      final stationVm = Provider.of<StationViewModel>(context, listen: false);
      final mapVm = Provider.of<MapViewModel>(context, listen: false);
      
      loadingVm.setLoading(true);
      loadingVm.simulatePercentage();
      
      try {
        await mapVm.requestAndCenterLocation();
        await stationVm.fetchBaseData();
        await stationVm.refreshStations(isInitial: true);
      } catch (e) {
        LogService().e('APP_INIT', 'Initial data fetch failed', error: e);
      } finally {
        loadingVm.setFinished();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loadingVm = Provider.of<LoadingViewModel>(context);
    return Stack(
      children: [
        const HomeScreen(),
        if (loadingVm.isLoading) const LoadingOverlay(),
      ],
    );
  }
}
