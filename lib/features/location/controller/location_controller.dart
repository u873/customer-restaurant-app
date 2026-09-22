import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

const String kPlacesApiKey = 'AIzaSyBqgE_Gu8x26dFBZBcZvprKOef-X_aiAX4';

class PlaceSuggestion {
  final String placeId;
  final String description;

  PlaceSuggestion({required this.placeId, required this.description});
}

class LocationController extends ChangeNotifier {
  GoogleMapController? mapController;
  LatLng currentLatLng = const LatLng(31.5204, 74.3587);
  String address = "Finding location";
  bool isLoading = false;
  bool isSearching = false;
  List<PlaceSuggestion> suggestions = [];

  Timer? _debounceTimer;
  int _searchRequestId = 0;

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> getCurrentLocation() async {
    isLoading = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        address = "Location service is disabled";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        address = "Location permission denied";
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        address = "Location permission permanently denied";
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      currentLatLng = LatLng(position.latitude, position.longitude);

      await getAddress(position.latitude, position.longitude);

      await _animateToCurrentLocation();
    } catch (_) {
      address = "Location not found";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setInitialLocation({
    required double latitude,
    required double longitude,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      currentLatLng = LatLng(latitude, longitude);

      await getAddress(latitude, longitude);
      await _animateToCurrentLocation();
    } catch (e) {
      address = "Location not found";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAddress(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) {
        address = "Location not found";
        return;
      }

      final place = placemarks.first;

      final parts = <String>[
        if ((place.street ?? '').trim().isNotEmpty) place.street!.trim(),
        if ((place.subLocality ?? '').trim().isNotEmpty)
          place.subLocality!.trim(),
        if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
        if ((place.administrativeArea ?? '').trim().isNotEmpty)
          place.administrativeArea!.trim(),
        if ((place.country ?? '').trim().isNotEmpty) place.country!.trim(),
      ];

      final uniqueParts = <String>[];

      for (final part in parts) {
        final normalized = part.toLowerCase();

        final alreadyExists = uniqueParts.any(
          (existing) => existing.toLowerCase() == normalized,
        );

        if (!alreadyExists) {
          uniqueParts.add(part);
        }
      }

      address = uniqueParts.join(", ");

      if (address.isEmpty) {
        address = "Location not found";
      }
    } catch (_) {
      address = "Location not found";
    }

    notifyListeners();
  }

  void searchPlaces(String query) {
    final trimmedQuery = query.trim();

    _debounceTimer?.cancel();

    if (trimmedQuery.isEmpty) {
      clearSuggestions();
      return;
    }

    final int requestId = ++_searchRequestId;

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      await _fetchPlaceSuggestions(trimmedQuery, requestId);
    });
  }

  Future<void> _fetchPlaceSuggestions(String query, int requestId) async {
    if (requestId != _searchRequestId) {
      return;
    }

    isSearching = true;
    notifyListeners();

    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/autocomplete/json',
        {
          'input': query,
          'key': kPlacesApiKey,
          'components': 'country:pk',
          'language': 'en',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return;
      }

      final Map<String, dynamic> json = jsonDecode(response.body);

      if (requestId != _searchRequestId) {
        return;
      }

      final status = json['status'];

      if (status != 'OK' && status != 'ZERO_RESULTS') {
        suggestions = [];
        return;
      }

      final predictions = json['predictions'] as List<dynamic>? ?? [];

      suggestions = predictions
          .map((item) {
            return PlaceSuggestion(
              placeId: item['place_id']?.toString() ?? '',
              description: item['description']?.toString() ?? '',
            );
          })
          .where((item) {
            return item.placeId.isNotEmpty && item.description.isNotEmpty;
          })
          .toList();
    } catch (_) {
      if (requestId == _searchRequestId) {
        suggestions = [];
      }
    } finally {
      if (requestId == _searchRequestId) {
        isSearching = false;
        notifyListeners();
      }
    }
  }

  Future<void> selectPlace(PlaceSuggestion suggestion) async {
    try {
      isSearching = true;
      notifyListeners();

      final uri =
          Uri.https('maps.googleapis.com', '/maps/api/place/details/json', {
            'place_id': suggestion.placeId,
            'key': kPlacesApiKey,
            'fields': 'geometry,formatted_address,name',
          });

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return;
      }

      final Map<String, dynamic> json = jsonDecode(response.body);

      if (json['status'] != 'OK') {
        return;
      }

      final result = json['result'] as Map<String, dynamic>?;

      if (result == null) {
        return;
      }

      final geometry = result['geometry'] as Map<String, dynamic>?;

      final location = geometry?['location'] as Map<String, dynamic>?;

      if (location == null) {
        return;
      }

      final lat = (location['lat'] as num).toDouble();

      final lng = (location['lng'] as num).toDouble();

      currentLatLng = LatLng(lat, lng);

      final formattedAddress = result['formatted_address']?.toString();

      if (formattedAddress != null && formattedAddress.trim().isNotEmpty) {
        address = formattedAddress.trim();
      } else {
        await getAddress(lat, lng);
      }

      suggestions = [];

      await _animateToCurrentLocation();
    } catch (e) {
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final locations = await locationFromAddress("${query.trim()}, Pakistan");

      if (locations.isEmpty) {
        address = "Location not found";
        return;
      }

      final location = locations.first;

      currentLatLng = LatLng(location.latitude, location.longitude);

      await getAddress(location.latitude, location.longitude);

      await _animateToCurrentLocation();
    } catch (_) {
      address = "Location not found";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onCameraMove(CameraPosition position) {
    currentLatLng = position.target;
  }

  Future<void> onCameraIdle() async {
    await getAddress(currentLatLng.latitude, currentLatLng.longitude);
  }

  Future<void> _animateToCurrentLocation() async {
    if (mapController == null) {
      return;
    }

    try {
      await mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng, zoom: 16),
        ),
      );
    } catch (_) {}
  }

  void clearSuggestions() {
    _debounceTimer?.cancel();

    // Invalidate all previous requests.
    _searchRequestId++;

    suggestions = [];
    isSearching = false;

    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    mapController = null;
    super.dispose();
  }
}
