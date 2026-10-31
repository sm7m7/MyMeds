import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_meds/core/widgets/medical_disclaimer.dart';
import 'package:my_meds/features/locator/domain/models/healthcare_place.dart';
import 'package:my_meds/features/locator/presentation/providers/locator_providers.dart';
import 'package:my_meds/features/locator/presentation/widgets/healthcare_place_card.dart';

/// Full interactive Pharmacy & Healthcare Locator screen.
///
/// Features:
/// - Filter chips: All, Pharmacies, Hospitals, Clinics
/// - Map View (OpenStreetMap via flutter_map) & List View toggle
/// - Sorted by distance
/// - Direct actions to call and launch native directions in Google/Apple Maps
/// - Graceful handling of location permissions, loading, empty, and offline states
class LocatorScreen extends ConsumerStatefulWidget {
  const LocatorScreen({super.key});

  @override
  ConsumerState<LocatorScreen> createState() => _LocatorScreenState();
}

class _LocatorScreenState extends ConsumerState<LocatorScreen> {
  final MapController _mapController = MapController();

  Color _pinColor(HealthcarePlaceType type) {
    switch (type) {
      case HealthcarePlaceType.pharmacy:
        return Colors.green.shade700;
      case HealthcarePlaceType.hospital:
        return Colors.red.shade700;
      case HealthcarePlaceType.clinic:
        return Colors.blue.shade700;
    }
  }

  IconData _pinIcon(HealthcarePlaceType type) {
    switch (type) {
      case HealthcarePlaceType.pharmacy:
        return Icons.local_pharmacy_rounded;
      case HealthcarePlaceType.hospital:
        return Icons.local_hospital_rounded;
      case HealthcarePlaceType.clinic:
        return Icons.medical_services_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMapView = ref.watch(locatorViewModeProvider);
    final activeFilter = ref.watch(healthcareTypeFilterProvider);
    final placesAsync = ref.watch(nearbyPlacesProvider);
    final userPosAsync = ref.watch(userPositionProvider);
    final selectedPlace = ref.watch(selectedPlaceProvider);

    final userPosition = userPosAsync.valueOrNull;
    final defaultCenter = LatLng(
      userPosition?.latitude ?? 48.8566,
      userPosition?.longitude ?? 2.3522,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacies & Clinics'),
        actions: [
          // Toggle Map vs List View
          IconButton(
            tooltip: isMapView ? 'Switch to List View' : 'Switch to Map View',
            icon: Icon(isMapView ? Icons.view_list_rounded : Icons.map_outlined),
            onPressed: () {
              ref.read(locatorViewModeProvider.notifier).state = !isMapView;
            },
          ),
          // Refresh Button
          IconButton(
            tooltip: 'Refresh Nearby Places',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(userPositionProvider);
              ref.invalidate(nearbyPlacesProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mandatory Medical Disclaimer
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: MedicalDisclaimer(),
          ),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Nearby'),
                  selected: activeFilter == null,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(healthcareTypeFilterProvider.notifier).state = null;
                      ref.read(selectedPlaceProvider.notifier).state = null;
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.local_pharmacy_rounded, size: 16),
                  label: const Text('Pharmacies'),
                  selected: activeFilter == HealthcarePlaceType.pharmacy,
                  onSelected: (selected) {
                    ref.read(healthcareTypeFilterProvider.notifier).state =
                        selected ? HealthcarePlaceType.pharmacy : null;
                    ref.read(selectedPlaceProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.local_hospital_rounded, size: 16),
                  label: const Text('Hospitals'),
                  selected: activeFilter == HealthcarePlaceType.hospital,
                  onSelected: (selected) {
                    ref.read(healthcareTypeFilterProvider.notifier).state =
                        selected ? HealthcarePlaceType.hospital : null;
                    ref.read(selectedPlaceProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.medical_services_rounded, size: 16),
                  label: const Text('Clinics'),
                  selected: activeFilter == HealthcarePlaceType.clinic,
                  onSelected: (selected) {
                    ref.read(healthcareTypeFilterProvider.notifier).state =
                        selected ? HealthcarePlaceType.clinic : null;
                    ref.read(selectedPlaceProvider.notifier).state = null;
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main View (Map or List)
          Expanded(
            child: placesAsync.when(
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Finding nearby healthcare facilities…'),
                  ],
                ),
              ),
              error: (err, _) => _buildErrorState(context, err),
              data: (places) {
                if (places.isEmpty) {
                  return _buildEmptyState(context);
                }

                if (!isMapView) {
                  return _buildListView(places);
                }

                return _buildMapView(
                  context,
                  places,
                  defaultCenter,
                  selectedPlace,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(
    BuildContext context,
    List<HealthcarePlace> places,
    LatLng center,
    HealthcarePlace? selectedPlace,
  ) {
    final markers = <Marker>[];

    // User position marker
    markers.add(
      Marker(
        point: center,
        width: 32,
        height: 32,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(50),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.my_location, color: Colors.blue, size: 18),
          ),
        ),
      ),
    );

    // Facilities markers
    for (final place in places) {
      final isSelected = selectedPlace?.id == place.id;
      final color = _pinColor(place.type);

      markers.add(
        Marker(
          point: LatLng(place.latitude, place.longitude),
          width: isSelected ? 44 : 36,
          height: isSelected ? 44 : 36,
          child: GestureDetector(
            onTap: () {
              ref.read(selectedPlaceProvider.notifier).state = place;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withAlpha(220),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _pinIcon(place.type),
                  color: Colors.white,
                  size: isSelected ? 22 : 18,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 14.0,
            onTap: (_, _) {
              if (selectedPlace != null) {
                ref.read(selectedPlaceProvider.notifier).state = null;
              }
            },
          ),
          children: [
            // OpenStreetMap tile layer (free and open standard)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mymeds.app',
            ),
            MarkerLayer(markers: markers),
          ],
        ),

        // Floating Recentering Button
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'recenter_map',
            backgroundColor: Theme.of(context).colorScheme.surface,
            onPressed: () {
              _mapController.move(center, 14.5);
            },
            child: const Icon(Icons.my_location_rounded),
          ),
        ),

        // Selected Place Bottom Card Overlay
        if (selectedPlace != null)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: HealthcarePlaceCard(
              place: selectedPlace,
              isSelected: true,
            ),
          ),
      ],
    );
  }

  Widget _buildListView(List<HealthcarePlace> places) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: places.length,
      itemBuilder: (context, index) {
        return HealthcarePlaceCard(place: places[index]);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No healthcare facilities found nearby',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing the category filter or searching in a wider area.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded, size: 56, color: Colors.amber.shade700),
            const SizedBox(height: 16),
            const Text(
              'Location Access Needed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Enable device location to automatically find pharmacies and clinics closest to you.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.settings_outlined),
              label: const Text('Open Settings'),
              onPressed: () {
                ref.read(locationServiceProvider).openAppSettings();
              },
            ),
          ],
        ),
      ),
    );
  }
}
