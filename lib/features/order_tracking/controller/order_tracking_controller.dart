import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../model/order_tracking_model.dart';
import '../repository/order_tracking_repository.dart';

class OrderTrackingController extends ChangeNotifier {
  OrderTrackingController();

  final OrderTrackingRepository _repository = OrderTrackingRepository();

  static const Duration pollInterval = Duration(seconds: 5);
  static const Duration _legDuration = Duration(milliseconds: 4500);
  static const Duration _frame = Duration(milliseconds: 40);
  static const double _offRouteMeters = 50;
  static const Duration _minRerouteGap = Duration(seconds: 20);
  static const double _nearDestinationMeters = 150;
  static const double _jitterMeters = 2;
  static const double _teleportMeters = 1500;

  bool _isLoading = true;
  bool _isOrderTrackingAvailable = false;
  String _timeToDeliver = '';
  String _riderName = '';
  String _riderPhoneNumber = '';
  bool _hasArrived = false;
  bool _showArrivalDialog = false;

  LatLng? _startLatLng;
  LatLng? _currentLatLng;
  LatLng? _endLatLng;
  LatLng? _displayedLatLng;

  bool _facingEast = true;

  GoogleMapController? _mapController;

  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  final ValueNotifier<int> mapRevision = ValueNotifier<int>(0);

  List<LatLng> _route = [];

  bool _bootstrapped = false;
  bool _bootstrapping = false;
  bool _routeInFlight = false;

  DateTime? _lastRouteFetch;

  Timer? _apiRefreshTimer;
  Timer? _animTimer;

  List<LatLng> _legPath = [];
  List<double> _legCumulative = [];
  double _legTotal = 0;
  DateTime? _legStart;
  int _legTicks = 0;

  bool _disposed = false;

  bool get isLoading => _isLoading;

  bool get isOrderTrackingAvailable => _isOrderTrackingAvailable;

  String get timeToDeliver => _timeToDeliver;

  String get riderName => _riderName;

  String get riderPhoneNumber => _riderPhoneNumber;

  bool get showArrivalDialog => _showArrivalDialog;

  bool get hasArrived => _hasArrived;

  LatLng? get riderLatLng => _currentLatLng;

  LatLng? get displayedRiderLatLng => _displayedLatLng;

  LatLng? get startLatLng => _startLatLng;

  LatLng? get endLatLng => _endLatLng;

  Set<Polyline> get polylines => _polylines;

  Set<Marker> get markers => _markers;

  Set<Circle> get circles => _circles;

  void initialize(String orderId) {
    _fetchOrderTrackingData(orderId);

    _apiRefreshTimer?.cancel();

    _apiRefreshTimer = Timer.periodic(pollInterval, (_) {
      _fetchOrderTrackingData(orderId);
    });
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;

    if (_bootstrapped) {
      _fitCamera(force: true);
      mapRevision.value++;
    }
  }

  void dialogShown() {
    _showArrivalDialog = false;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _apiRefreshTimer?.cancel();
    _animTimer?.cancel();
    mapRevision.dispose();
    super.dispose();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  Future<void> _fetchOrderTrackingData(String orderId) async {
    try {
      final response = await _repository.getOrderTracking(orderId);

      if (_disposed) return;

      if (response != null && response.data != null) {
        final trackingResponse = OrderTrackingResponse.fromJson(
          Map<String, dynamic>.from(response.data),
        );

        if (trackingResponse.success == true && trackingResponse.data != null) {
          await _applyApiData(trackingResponse.data!);
        } else {
          _setUnavailable();
        }
      } else {
        _setUnavailable();
      }
    } catch (_) {

      if (!_bootstrapped) {
        _setUnavailable();
      }
    }
  }

  void _setUnavailable() {
    _isLoading = false;
    _isOrderTrackingAvailable = false;
    _notify();
  }

  Future<void> _applyApiData(Data data) async {
    final double? startLat = double.tryParse(data.startLatitude ?? '');

    final double? startLng = double.tryParse(data.startLongitude ?? '');

    final double? currentLat = double.tryParse(data.currentLatitude ?? '');

    final double? currentLng = double.tryParse(data.currentLongitude ?? '');

    final double? endLat = double.tryParse(data.endLatitude ?? '');

    final double? endLng = double.tryParse(data.endLongitude ?? '');

    if (startLat == null ||
        startLng == null ||
        currentLat == null ||
        currentLng == null ||
        endLat == null ||
        endLng == null) {
      _setUnavailable();
      return;
    }

    final LatLng start = LatLng(startLat, startLng);
    final LatLng reported = LatLng(currentLat, currentLng);
    final LatLng end = LatLng(endLat, endLng);

    _riderName = data.riderName ?? '';
    _riderPhoneNumber = data.riderContactno ?? '';

    if (!_bootstrapped) {
      if (_bootstrapping) return;

      _bootstrapping = true;

      _startLatLng = start;
      _endLatLng = end;
      _currentLatLng = reported;

      await _loadInitialRoute(reported, end);

      if (_disposed) return;

      final _RouteFix? fix = _project(reported, _route);

      _displayedLatLng = fix != null && fix.offsetMeters <= _offRouteMeters
          ? fix.point
          : reported;

      _updateFacing(_displayedLatLng!, end);

      _bootstrapped = true;
      _bootstrapping = false;

      _isOrderTrackingAvailable = true;
      _isLoading = false;

      _updateArrivalStatus(reported, end);

      _rebuildLayers();
      _fitCamera(force: true);

      _notify();

      return;
    }

    _currentLatLng = reported;
    _endLatLng = end;

    _isOrderTrackingAvailable = true;
    _isLoading = false;

    _updateArrivalStatus(reported, end);

    _notify();

    _onNewFix(reported);
  }

  Future<void> _loadInitialRoute(LatLng rider, LatLng end) async {
    _routeInFlight = true;

    _route =
        await _routeBetween(origin: rider, destination: end) ??
        <LatLng>[rider, end];

    _routeInFlight = false;
    _lastRouteFetch = DateTime.now();
  }

  Future<void> _maybeReroute(LatLng reported) async {
    if (_routeInFlight) return;

    final DateTime? last = _lastRouteFetch;

    if (last != null && DateTime.now().difference(last) < _minRerouteGap) {
      return;
    }

    final LatLng? end = _endLatLng;

    if (end == null) return;

    final LatLng origin = _displayedLatLng ?? reported;

    _routeInFlight = true;

    final List<LatLng>? fresh = await _routeBetween(
      origin: origin,
      via: reported,
      destination: end,
    );

    _routeInFlight = false;
    _lastRouteFetch = DateTime.now();

    if (_disposed || fresh == null) return;

    _route = fresh;

    _rebuildLayers();

    final LatLng? latest = _currentLatLng;

    if (latest != null) {
      _onNewFix(latest);
    }
  }

  Future<List<LatLng>?> _routeBetween({
    required LatLng origin,
    required LatLng destination,
    LatLng? via,
  }) async {
    try {
      final polylinePoints = PolylinePoints();
      final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: AppConstants.kPlacesApiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
          wayPoints: [
            if (via != null)
              PolylineWayPoint(
                location: '${via.latitude},${via.longitude}',
                stopOver: false,
              ),
          ],
        ),
      );

      if (result.points.isNotEmpty) {
        return result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      }
    } catch (_) {

    }

    return null;
  }

  void _onNewFix(LatLng reported) {
    final LatLng? end = _endLatLng;

    final LatLng from = _displayedLatLng ?? reported;

    final _RouteFix? fix = _project(reported, _route);

    if (fix == null) return;

    final bool nearDestination =
        end != null && _meters(reported, end) <= _nearDestinationMeters;

    if (fix.offsetMeters > _offRouteMeters && !nearDestination) {
      _maybeReroute(reported);
      return;
    }

    final LatLng target = fix.point;

    if (_meters(from, target) < _jitterMeters) {
      return;
    }

    final _RouteFix? fromFix = _project(from, _route);

    final List<LatLng> path;

    if (fromFix == null || fromFix.offsetMeters > _offRouteMeters) {
      path = [from, target];
    } else if (fix.index >= fromFix.index) {
      path = [
        from,
        ..._route.sublist(fromFix.index + 1, fix.index + 1),
        target,
      ];
    } else {
      path = [
        from,
        ..._route.sublist(fix.index + 1, fromFix.index + 1).reversed,
        target,
      ];
    }

    _startLeg(path);
  }

  void _startLeg(List<LatLng> path) {
    _animTimer?.cancel();
    _animTimer = null;

    _legPath = path;
    _legCumulative = [0];

    for (int i = 1; i < path.length; i++) {
      _legCumulative.add(_legCumulative.last + _meters(path[i - 1], path[i]));
    }

    _legTotal = _legCumulative.last;

    if (_legTotal > _teleportMeters) {
      _updateFacing(path.first, path.last);

      _displayedLatLng = path.last;

      _rebuildLayers();
      _fitCamera();

      return;
    }

    _legStart = DateTime.now();
    _legTicks = 0;

    _animTimer = Timer.periodic(_frame, _tick);
  }

  void _tick(Timer timer) {
    if (_disposed) {
      timer.cancel();
      return;
    }

    final DateTime? started = _legStart;

    if (started == null || _legPath.length < 2) {
      timer.cancel();
      return;
    }

    final int elapsedMs = DateTime.now().difference(started).inMilliseconds;

    final double fraction = (elapsedMs / _legDuration.inMilliseconds).clamp(
      0.0,
      1.0,
    );

    final double travelled = _legTotal * fraction;

    int seg = 1;

    while (seg < _legCumulative.length - 1 && _legCumulative[seg] < travelled) {
      seg++;
    }

    final LatLng a = _legPath[seg - 1];
    final LatLng b = _legPath[seg];

    final double segLen = _legCumulative[seg] - _legCumulative[seg - 1];

    final double t = segLen == 0
        ? 1.0
        : ((travelled - _legCumulative[seg - 1]) / segLen).clamp(0.0, 1.0);

    _displayedLatLng = LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );

    _updateFacing(a, b);

    _legTicks++;

    final bool done = fraction >= 1;

    _rebuildLayers(polylines: done || _legTicks % 4 == 0);

    if (done) {
      timer.cancel();
      _animTimer = null;
      _fitCamera();
    }
  }

  void _updateFacing(LatLng from, LatLng to) {
    final double dLng = to.longitude - from.longitude;

    if (dLng.abs() < 1e-6) return;

    _facingEast = dLng > 0;
  }

  void _rebuildLayers({bool polylines = true}) {
    final LatLng? start = _startLatLng;
    final LatLng? pos = _displayedLatLng;
    final LatLng? end = _endLatLng;

    if (start == null || pos == null || end == null) {
      return;
    }

    _markers = {
      Marker(
        markerId: const MarkerId('Start'),
        position: start,
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
      Marker(
        markerId: const MarkerId('Current'),
        position: pos,
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _facingEast ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueBlue,
        ),
      ),
      Marker(
        markerId: const MarkerId('End'),
        position: end,
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    _circles = {
      Circle(
        circleId: const CircleId('riderHalo'),
        center: pos,
        radius: 45,
        fillColor: AppColors.primary.withValues(alpha: 0.16),
        strokeColor: AppColors.primary.withValues(alpha: 0.4),
        strokeWidth: 1,
      ),
    };

    if (polylines) {
      _rebuildPolylines(pos);
    }

    if (!_disposed) {
      mapRevision.value++;
    }
  }

  void _rebuildPolylines(LatLng pos) {
    final _RouteFix? fix = _project(pos, _route);

    final List<LatLng> remaining = fix == null
        ? [pos, if (_endLatLng != null) _endLatLng!]
        : [pos, ..._route.sublist(fix.index + 1)];

    _polylines = {
      Polyline(
        polylineId: const PolylineId('remaining'),
        color: AppColors.primary,
        width: 6,
        points: remaining,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  Future<void> _fitCamera({bool force = false}) async {
    final GoogleMapController? map = _mapController;

    final LatLng? pos = _displayedLatLng;

    final LatLng? end = _endLatLng;

    if (map == null || pos == null || end == null) {
      return;
    }

    if (!force) {
      try {
        final LatLngBounds visible = await map.getVisibleRegion();

        if (visible.contains(pos)) {
          return;
        }
      } catch (_) {}
    }

    if (_disposed) return;

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(pos.latitude, end.latitude),
        min(pos.longitude, end.longitude),
      ),
      northeast: LatLng(
        max(pos.latitude, end.latitude),
        max(pos.longitude, end.longitude),
      ),
    );

    try {
      await map.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } catch (_) {

    }
  }

  void _updateArrivalStatus(LatLng rider, LatLng destination) {
    final double distance = _meters(rider, destination);

    if (distance <= _nearDestinationMeters) {
      if (!_hasArrived) {
        _hasArrived = true;
        _showArrivalDialog = true;
      }
    } else {
      _hasArrived = false;
    }
  }

  _RouteFix? _project(LatLng p, List<LatLng> route) {
    if (route.isEmpty) return null;

    if (route.length == 1) {
      return _RouteFix(0, route.first, _meters(p, route.first));
    }

    final double k = cos(_deg2rad(p.latitude));

    final double px = p.longitude * k;

    final double py = p.latitude;

    double bestOffset = double.infinity;

    int bestIndex = 0;

    LatLng bestPoint = route.first;

    for (int i = 0; i < route.length - 1; i++) {
      final LatLng a = route[i];

      final LatLng b = route[i + 1];

      final double ax = a.longitude * k;

      final double ay = a.latitude;

      final double bx = b.longitude * k;

      final double by = b.latitude;

      final double dx = bx - ax;

      final double dy = by - ay;

      final double len2 = dx * dx + dy * dy;

      double t = len2 == 0 ? 0 : ((px - ax) * dx + (py - ay) * dy) / len2;

      t = t.clamp(0.0, 1.0);

      final LatLng q = LatLng(
        a.latitude + (b.latitude - a.latitude) * t,
        a.longitude + (b.longitude - a.longitude) * t,
      );

      final double d = _meters(p, q);

      if (d < bestOffset) {
        bestOffset = d;
        bestIndex = i;
        bestPoint = q;
      }
    }

    return _RouteFix(bestIndex, bestPoint, bestOffset);
  }

  double _meters(LatLng a, LatLng b) {
    const double earthRadius = 6371000;

    final double dLat = _deg2rad(b.latitude - a.latitude);

    final double dLon = _deg2rad(b.longitude - a.longitude);

    final double h =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(a.latitude)) *
            cos(_deg2rad(b.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return earthRadius * 2 * asin(sqrt(h));
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }
}

class _RouteFix {
  const _RouteFix(this.index, this.point, this.offsetMeters);

  final int index;
  final LatLng point;
  final double offsetMeters;
}
