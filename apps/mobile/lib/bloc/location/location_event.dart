import "package:flutter/foundation.dart";

@immutable
sealed class LocationEvent {}

class LocationFetchEvent extends LocationEvent {}
