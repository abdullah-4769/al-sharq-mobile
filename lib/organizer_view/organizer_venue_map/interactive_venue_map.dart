// lib/organizer_view/interactive_venue_map.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:al_sharq_conference/app_colors/app_colors.dart';
import '../../data/response_models/organizer_response_models/organizer_venue_show_model.dart';

class VenueMapComponent extends StatefulWidget {
  final List<OrganizerVenueShowEvent>? events;
  final OrganizerVenueShowEvent? singleEvent;
  final Function(OrganizerVenueShowEvent)? onMarkerTap;
  final bool showControls;
  final bool showAttribution;
  final double? height;

  const VenueMapComponent({
    Key? key,
    this.events,
    this.singleEvent,
    this.onMarkerTap,
    this.showControls = true,
    this.showAttribution = true,
    this.height = 300,
  }) : super(key: key);

  @override
  State<VenueMapComponent> createState() => _VenueMapComponentState();
}

class _VenueMapComponentState extends State<VenueMapComponent> {
  MapboxMap? mapboxMap;
  bool _isMapLoading = true;
  bool _isMapCreated = false;
  List<OrganizerVenueShowEvent> _eventsWithLocations = [];
  PointAnnotationManager? _pointAnnotationManager;

  static const String mapStyle = 'mapbox://styles/mapbox/streets-v12';

  @override
  void initState() {
    super.initState();
    _prepareEvents();
    _initializeMap();
  }

  void _prepareEvents() {
    if (widget.singleEvent != null) {
      // Single event mode
      _eventsWithLocations = [widget.singleEvent!]
          .where((event) => event.getLatLngFromUrl() != null)
          .toList();
      print('📍 Single event mode: ${_eventsWithLocations.isNotEmpty ? 'Location available' : 'No location'}');
    } else if (widget.events != null) {
      // Multiple events mode
      _eventsWithLocations = widget.events!
          .where((event) => event.getLatLngFromUrl() != null)
          .toList();
      print('📍 Multiple events mode: Found ${_eventsWithLocations.length} events with valid locations');
    }
  }

  void _initializeMap() {
    setState(() => _isMapLoading = false);
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    // Create annotation manager
    _pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();

    setState(() => _isMapCreated = true);

    // Add markers and fit map
    _addMarkersToMap();
    _fitMapToMarkers();
  }

  Future<void> _addMarkersToMap() async {
    if (_pointAnnotationManager == null || _eventsWithLocations.isEmpty) return;

    // Clear existing markers
    await _pointAnnotationManager!.deleteAll();

    final annotations = <PointAnnotationOptions>[];

    // Load custom marker image (optional)
    Uint8List? markerImage;
    try {
      final ByteData bytes = await rootBundle.load('assets/images/map_marker.png');
      markerImage = bytes.buffer.asUint8List();
    } catch (e) {
      print('ℹ️ Using default markers - custom image not found');
    }

    // Create markers for each event
    for (var event in _eventsWithLocations) {
      final location = event.getLatLngFromUrl();
      if (location != null) {
        final annotation = PointAnnotationOptions(
          geometry: Point(coordinates: Position(location.longitude, location.latitude)),
          iconAnchor: IconAnchor.BOTTOM,
          textField: event.name,
          textSize: 12,
          textColor: Colors.white.value,
          textHaloColor: Colors.black.value,
          textHaloWidth: 2.0,
          textOffset: [0.0, -2.0],
        );

        // Add custom image if available
        if (markerImage != null) {
          annotation.image = markerImage;
        }

        annotations.add(annotation);
      }
    }

    // Add all markers to map
    if (annotations.isNotEmpty) {
      await _pointAnnotationManager!.createMulti(annotations);

      // Setup click listeners only if we have a callback
      if (widget.onMarkerTap != null) {
        _setupAnnotationListeners();
      }
    }
  }

  void _setupAnnotationListeners() {
    _pointAnnotationManager?.addOnPointAnnotationClickListener(
      _AnnotationClickListener(_onAnnotationTap),
    );
  }

  void _onAnnotationTap(PointAnnotation annotation) {
    try {
      final annotationGeometry = annotation.geometry;
      if (annotationGeometry == null) return;

      // Find the closest event to the tapped annotation
      OrganizerVenueShowEvent? closestEvent;
      double closestDistance = double.maxFinite;

      for (var event in _eventsWithLocations) {
        final eventLocation = event.getLatLngFromUrl();
        if (eventLocation != null) {
          final distance = _calculateDistance(
            annotationGeometry.coordinates.lat.toDouble(),
            annotationGeometry.coordinates.lng.toDouble(),
            eventLocation.latitude,
            eventLocation.longitude,
          );

          if (distance < closestDistance) {
            closestDistance = distance;
            closestEvent = event;
          }
        }
      }

      // If we found a reasonably close event, trigger the callback
      if (closestEvent != null && closestDistance < 0.01) {
        widget.onMarkerTap?.call(closestEvent);
      }
    } catch (e) {
      print('❌ Error handling annotation tap: $e');
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    // Simple Euclidean distance for proximity check
    return ((lat1 - lat2) * (lat1 - lat2) + (lng1 - lng2) * (lng1 - lng2)).abs();
  }

  Future<void> _fitMapToMarkers() async {
    if (mapboxMap == null || _eventsWithLocations.isEmpty) return;

    final coordinates = _eventsWithLocations
        .map((event) => event.getLatLngFromUrl())
        .where((location) => location != null)
        .map((location) => Position(location!.longitude, location.latitude))
        .toList();

    if (coordinates.isEmpty) return;

    if (widget.singleEvent != null) {
      // Single event: center on that location with good zoom
      final location = widget.singleEvent!.getLatLngFromUrl();
      if (location != null) {
        await mapboxMap!.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(location.longitude, location.latitude)),
            zoom: 15.0, // Good zoom for single location
          ),
          MapAnimationOptions(duration: 1000),
        );
      }
    } else {
      // Multiple events: fit bounds
      double minLng = coordinates.first.lng.toDouble();
      double maxLng = coordinates.first.lng.toDouble();
      double minLat = coordinates.first.lat.toDouble();
      double maxLat = coordinates.first.lat.toDouble();

      for (final coord in coordinates) {
        final lng = coord.lng.toDouble();
        final lat = coord.lat.toDouble();
        if (lng < minLng) minLng = lng;
        if (lng > maxLng) maxLng = lng;
        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
      }

      // Calculate center and appropriate zoom level
      final centerLng = (minLng + maxLng) / 2;
      final centerLat = (minLat + maxLat) / 2;

      // Simple zoom calculation based on area
      final latDiff = (maxLat - minLat).abs();
      final lngDiff = (maxLng - minLng).abs();
      final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

      double zoom = 12.0;
      if (maxDiff > 1.0) zoom = 8.0;
      else if (maxDiff > 0.5) zoom = 9.0;
      else if (maxDiff > 0.1) zoom = 11.0;
      else if (maxDiff > 0.05) zoom = 13.0;
      else zoom = 15.0;

      // Animate camera to show all markers
      await mapboxMap!.flyTo(
        CameraOptions(
          center: Point(coordinates: Position(centerLng, centerLat)),
          zoom: zoom,
        ),
        MapAnimationOptions(duration: 1500),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isMapLoading) {
      return _buildLoadingState();
    }

    if (_eventsWithLocations.isEmpty) {
      return _buildNoLocationsState();
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Main Map
            MapWidget(
              key: ValueKey('map_${widget.singleEvent != null ? 'single_${widget.singleEvent!.id}' : 'multi_${_eventsWithLocations.length}'}'),
              onMapCreated: _onMapCreated,
              styleUri: mapStyle,
              cameraOptions: CameraOptions(
                center: Point(coordinates: Position(74.3239107, 31.5188399)),
                zoom: widget.singleEvent != null ? 15.0 : 11.0,
              ),
            ),

            // Map Controls
            if (_isMapCreated && widget.showControls)
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in_${widget.key}',
                      onPressed: () async {
                        final cameraState = await mapboxMap?.getCameraState();
                        if (cameraState != null) {
                          await mapboxMap?.setCamera(CameraOptions(
                            zoom: cameraState.zoom + 1,
                          ));
                        }
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out_${widget.key}',
                      onPressed: () async {
                        final cameraState = await mapboxMap?.getCameraState();
                        if (cameraState != null && cameraState.zoom > 5) {
                          await mapboxMap?.setCamera(CameraOptions(
                            zoom: cameraState.zoom - 1,
                          ));
                        }
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.remove, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'fit_bounds_${widget.key}',
                      onPressed: _fitMapToMarkers,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.my_location, color: Colors.black),
                    ),
                  ],
                ),
              ),

            // Map Attribution
            if (_isMapCreated && widget.showAttribution)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '© Mapbox',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

            // Single event overlay
            if (widget.singleEvent != null && _isMapCreated)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.singleEvent!.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.singleEvent!.location != null)
                        const SizedBox(height: 4),
                      if (widget.singleEvent!.location != null)
                        Text(
                          widget.singleEvent!.location!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.darkgrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: 12),
            Text(
              'Loading Map...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkgrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLocationsState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              widget.singleEvent != null ? 'Location Not Available' : 'No Event Locations',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.singleEvent != null
                  ? 'This event does not have location data'
                  : 'Add location data to see events on map',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    mapboxMap?.dispose();
    super.dispose();
  }
}

class _AnnotationClickListener extends OnPointAnnotationClickListener {
  final Function(PointAnnotation) onTap;

  _AnnotationClickListener(this.onTap);

  @override
  void onPointAnnotationClick(PointAnnotation annotation) {
    onTap(annotation);
  }
}






























// // interactive_venue_map.dart
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
// import 'package:al_sharq_conference/app_colors/app_colors.dart';
// import '../../data/response_models/organizer_response_models/organizer_venue_show_model.dart';
//
// class VenueMapComponent extends StatefulWidget {
//   final List<OrganizerVenueShowEvent> events;
//   final Function(OrganizerVenueShowEvent)? onMarkerTap;
//
//   const VenueMapComponent({
//     Key? key,
//     required this.events,
//     this.onMarkerTap,
//   }) : super(key: key);
//
//   @override
//   State<VenueMapComponent> createState() => _VenueMapComponentState();
// }
//
// class _VenueMapComponentState extends State<VenueMapComponent> {
//   MapboxMap? mapboxMap;
//   bool _isMapLoading = true;
//   bool _isMapCreated = false;
//   List<OrganizerVenueShowEvent> _eventsWithLocations = [];
//   PointAnnotationManager? _pointAnnotationManager;
//
//   static const String mapStyle = 'mapbox://styles/mapbox/streets-v12';
//
//   @override
//   void initState() {
//     super.initState();
//     _filterEventsWithLocations();
//     _initializeMap();
//   }
//
//   void _filterEventsWithLocations() {
//     _eventsWithLocations = widget.events.where((event) {
//       return event.getLatLngFromUrl() != null;
//     }).toList();
//     print('📍 Found ${_eventsWithLocations.length} events with valid locations');
//   }
//
//   void _initializeMap() {
//     setState(() => _isMapLoading = false);
//   }
//
//   void _onMapCreated(MapboxMap mapboxMap) async {
//     this.mapboxMap = mapboxMap;
//
//     // Create annotation manager
//     _pointAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
//
//     setState(() => _isMapCreated = true);
//
//     // Add markers and fit map
//     _addMarkersToMap();
//     _fitMapToMarkers();
//   }
//
//   Future<void> _addMarkersToMap() async {
//     if (_pointAnnotationManager == null || _eventsWithLocations.isEmpty) return;
//
//     // Clear existing markers
//     await _pointAnnotationManager!.deleteAll();
//
//     final annotations = <PointAnnotationOptions>[];
//
//     // Load custom marker image (optional)
//     Uint8List? markerImage;
//     try {
//       final ByteData bytes = await rootBundle.load('assets/images/map_marker.png');
//       markerImage = bytes.buffer.asUint8List();
//     } catch (e) {
//       print('ℹ️ Using default markers - custom image not found');
//     }
//
//     // Create markers for each event
//     for (var event in _eventsWithLocations) {
//       final location = event.getLatLngFromUrl();
//       if (location != null) {
//         final annotation = PointAnnotationOptions(
//           geometry: Point(coordinates: Position(location.longitude, location.latitude)),
//           iconAnchor: IconAnchor.BOTTOM,
//           textField: event.name,
//           textSize: 12,
//           textColor: Colors.white.value,
//           textHaloColor: Colors.black.value,
//           textHaloWidth: 2.0,
//           textOffset: [0.0, -2.0],
//         );
//
//         // Add custom image if available
//         if (markerImage != null) {
//           annotation.image = markerImage;
//         }
//
//         annotations.add(annotation);
//       }
//     }
//
//     // Add all markers to map
//     if (annotations.isNotEmpty) {
//       await _pointAnnotationManager!.createMulti(annotations);
//
//       // Setup click listeners
//       _setupAnnotationListeners();
//     }
//   }
//   void _setupAnnotationListeners() {
//     _pointAnnotationManager?.addOnPointAnnotationClickListener(
//       _AnnotationClickListener(_onAnnotationTap),
//     );
//   }
//   void _onAnnotationTap(PointAnnotation annotation) {
//     try {
//       final annotationGeometry = annotation.geometry;
//       if (annotationGeometry == null) return;
//
//       // Find the closest event to the tapped annotation
//       OrganizerVenueShowEvent? closestEvent;
//       double closestDistance = double.maxFinite;
//
//       for (var event in _eventsWithLocations) {
//         final eventLocation = event.getLatLngFromUrl();
//         if (eventLocation != null) {
//           final distance = _calculateDistance(
//             annotationGeometry.coordinates.lat.toDouble(),
//             annotationGeometry.coordinates.lng.toDouble(),
//             eventLocation.latitude,
//             eventLocation.longitude,
//           );
//
//           if (distance < closestDistance) {
//             closestDistance = distance;
//             closestEvent = event;
//           }
//         }
//       }
//
//       // If we found a reasonably close event, trigger the callback
//       if (closestEvent != null && closestDistance < 0.01) {
//         widget.onMarkerTap?.call(closestEvent);
//       }
//     } catch (e) {
//       print('❌ Error handling annotation tap: $e');
//     }
//   }
//
//   double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
//     // Simple Euclidean distance for proximity check
//     return ((lat1 - lat2) * (lat1 - lat2) + (lng1 - lng2) * (lng1 - lng2)).abs();
//   }
//
//   Future<void> _fitMapToMarkers() async {
//     if (mapboxMap == null || _eventsWithLocations.isEmpty) return;
//
//     final coordinates = _eventsWithLocations
//         .map((event) => event.getLatLngFromUrl())
//         .where((location) => location != null)
//         .map((location) => Position(location!.longitude, location.latitude))
//         .toList();
//
//     if (coordinates.isEmpty) return;
//     double minLng = coordinates.first.lng.toDouble();
//     double maxLng = coordinates.first.lng.toDouble();
//     double minLat = coordinates.first.lat.toDouble();
//     double maxLat = coordinates.first.lat.toDouble();
//
//     for (final coord in coordinates) {
//       final lng = coord.lng.toDouble();
//       final lat = coord.lat.toDouble();
//       if (lng < minLng) minLng = lng;
//       if (lng > maxLng) maxLng = lng;
//       if (lat < minLat) minLat = lat;
//       if (lat > maxLat) maxLat = lat;
//     }
//
//     // Calculate center and appropriate zoom level
//     final centerLng = (minLng + maxLng) / 2;
//     final centerLat = (minLat + maxLat) / 2;
//
//     // Simple zoom calculation based on area
//     final latDiff = (maxLat - minLat).abs();
//     final lngDiff = (maxLng - minLng).abs();
//     final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
//
//     double zoom = 12.0;
//     if (maxDiff > 1.0) zoom = 8.0;
//     else if (maxDiff > 0.5) zoom = 9.0;
//     else if (maxDiff > 0.1) zoom = 11.0;
//     else if (maxDiff > 0.05) zoom = 13.0;
//     else zoom = 15.0;
//
//     // Animate camera to show all markers
//     await mapboxMap!.flyTo(
//       CameraOptions(
//         center: Point(coordinates: Position(centerLng, centerLat)),
//         zoom: zoom,
//       ),
//       MapAnimationOptions(duration: 1500),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isMapLoading) {
//       return _buildLoadingState();
//     }
//
//     if (_eventsWithLocations.isEmpty) {
//       return _buildNoLocationsState();
//     }
//
//     return Container(
//       height: 300,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Stack(
//           children: [
//             // Main Map
//             MapWidget(
//               key: ValueKey('map_${_eventsWithLocations.length}'),
//               onMapCreated: _onMapCreated,
//               styleUri: mapStyle,
//               cameraOptions:  CameraOptions(
//                 center: Point(coordinates: Position(74.3239107, 31.5188399)),
//                 zoom: 11.0,
//               ),
//             ),
//
//             // Map Controls
//             if (_isMapCreated)
//               Positioned(
//                 right: 16,
//                 bottom: 16,
//                 child: Column(
//                   children: [
//                     FloatingActionButton.small(
//                       heroTag: 'zoom_in',
//                       onPressed: () async {
//                         final cameraState = await mapboxMap?.getCameraState();
//                         if (cameraState != null) {
//                           await mapboxMap?.setCamera(CameraOptions(
//                             zoom: cameraState.zoom + 1,
//                           ));
//                         }
//                       },
//                       backgroundColor: Colors.white,
//                       child: const Icon(Icons.add, color: Colors.black),
//                     ),
//                     const SizedBox(height: 8),
//                     FloatingActionButton.small(
//                       heroTag: 'zoom_out',
//                       onPressed: () async {
//                         final cameraState = await mapboxMap?.getCameraState();
//                         if (cameraState != null && cameraState.zoom > 5) {
//                           await mapboxMap?.setCamera(CameraOptions(
//                             zoom: cameraState.zoom - 1,
//                           ));
//                         }
//                       },
//                       backgroundColor: Colors.white,
//                       child: const Icon(Icons.remove, color: Colors.black),
//                     ),
//                     const SizedBox(height: 8),
//                     FloatingActionButton.small(
//                       heroTag: 'fit_bounds',
//                       onPressed: _fitMapToMarkers,
//                       backgroundColor: Colors.white,
//                       child: const Icon(Icons.my_location, color: Colors.black),
//                     ),
//                   ],
//                 ),
//               ),
//
//             // Map Attribution
//             if (_isMapCreated)
//                Positioned(
//                 bottom: 8,
//                 left: 8,
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     '© Mapbox',
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Container(
//       height: 300,
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: AppColors.primaryColor),
//             SizedBox(height: 12),
//             Text(
//               'Loading Map...',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppColors.darkgrey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNoLocationsState() {
//     return Container(
//       height: 300,
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.location_off, size: 50, color: Colors.grey[400]),
//             const SizedBox(height: 12),
//             const Text(
//               'No Event Locations',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               'Add location data to see events on map',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     mapboxMap?.dispose();
//     super.dispose();
//   }
// }
//
// class _AnnotationClickListener extends OnPointAnnotationClickListener {
//   final Function(PointAnnotation) onTap;
//
//   _AnnotationClickListener(this.onTap);
//
//   @override
//   void onPointAnnotationClick(PointAnnotation annotation) {
//     onTap(annotation);
//   }
// }