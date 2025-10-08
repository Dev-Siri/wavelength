import "dart:async";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:geocoding/geocoding.dart";
import "package:geolocator/geolocator.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:wavelength/bloc/location/location_event.dart";
import "package:wavelength/bloc/location/location_state.dart";
import "package:wavelength/constants.dart";

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(const LocationState(countryCode: defaultLocale)) {
    on<LocationFetchEvent>(_fetchLocation);
  }

  Future<void> _fetchLocation(
    LocationFetchEvent event,
    Emitter<LocationState> emit,
  ) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final locale = sharedPrefs.getString("user_cc");

    if (locale != null) emit(LocationState(countryCode: locale));

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final countryCode = placemarks.first.isoCountryCode ?? defaultLocale;

      emit(LocationState(countryCode: countryCode));

      if (countryCode != locale) sharedPrefs.setString("user_cc", countryCode);
    } catch (_) {
      emit(const LocationState(countryCode: defaultLocale));
    }
  }
}
