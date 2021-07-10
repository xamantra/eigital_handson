import 'dart:convert';

class RoutesResponse {
  RoutesResponse({
    required this.code,
    required this.routes,
    required this.waypoints,
  });

  final String code;
  final List<Route> routes;
  final List<Waypoint> waypoints;

  RoutesResponse copyWith({
    String? code,
    List<Route>? routes,
    List<Waypoint>? waypoints,
  }) =>
      RoutesResponse(
        code: code ?? this.code,
        routes: routes ?? this.routes,
        waypoints: waypoints ?? this.waypoints,
      );

  factory RoutesResponse.fromRawJson(String str) => RoutesResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RoutesResponse.fromJson(Map<String, dynamic> json) => RoutesResponse(
        code: json["code"] == null ? '' : json["code"],
        routes: json["routes"] == null ? [] : List<Route>.from(json["routes"].map((x) => Route.fromJson(x))),
        waypoints: json["waypoints"] == null ? [] : List<Waypoint>.from(json["waypoints"].map((x) => Waypoint.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "routes": List<dynamic>.from(routes.map((x) => x.toJson())),
        "waypoints": List<dynamic>.from(waypoints.map((x) => x.toJson())),
      };
}

class Route {
  Route({
    required this.geometry,
    required this.legs,
    required this.distance,
    required this.duration,
    required this.weightName,
    required this.weight,
  });

  final String geometry;
  final List<Leg> legs;
  final double distance;
  final double duration;
  final String weightName;
  final double weight;

  Route copyWith({
    String? geometry,
    List<Leg>? legs,
    double? distance,
    double? duration,
    String? weightName,
    double? weight,
  }) =>
      Route(
        geometry: geometry ?? this.geometry,
        legs: legs ?? this.legs,
        distance: distance ?? this.distance,
        duration: duration ?? this.duration,
        weightName: weightName ?? this.weightName,
        weight: weight ?? this.weight,
      );

  factory Route.fromRawJson(String str) => Route.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Route.fromJson(Map<String, dynamic> json) => Route(
        geometry: json["geometry"] == null ? '' : json["geometry"],
        legs: json["legs"] == null ? [] : List<Leg>.from(json["legs"].map((x) => Leg.fromJson(x))),
        distance: json["distance"] == null ? 0.0 : json["distance"].toDouble(),
        duration: json["duration"] == null ? 0.0 : json["duration"].toDouble(),
        weightName: json["weight_name"] == null ? '' : json["weight_name"],
        weight: json["weight"] == null ? 0.0 : json["weight"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "geometry": geometry,
        "legs": List<dynamic>.from(legs.map((x) => x.toJson())),
        "distance": distance,
        "duration": duration,
        "weight_name": weightName,
        "weight": weight,
      };
}

class Leg {
  Leg({
    required this.steps,
    required this.distance,
    required this.duration,
    required this.summary,
    required this.weight,
  });

  final List<dynamic> steps;
  final double distance;
  final double duration;
  final String summary;
  final double weight;

  Leg copyWith({
    List<dynamic>? steps,
    double? distance,
    double? duration,
    String? summary,
    double? weight,
  }) =>
      Leg(
        steps: steps ?? this.steps,
        distance: distance ?? this.distance,
        duration: duration ?? this.duration,
        summary: summary ?? this.summary,
        weight: weight ?? this.weight,
      );

  factory Leg.fromRawJson(String str) => Leg.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Leg.fromJson(Map<String, dynamic> json) => Leg(
        steps: json["steps"] == null ? [] : List<dynamic>.from(json["steps"].map((x) => x)),
        distance: json["distance"] == null ? 0.0 : json["distance"].toDouble(),
        duration: json["duration"] == null ? 0.0 : json["duration"].toDouble(),
        summary: json["summary"] == null ? '' : json["summary"],
        weight: json["weight"] == null ? 0.0 : json["weight"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "steps": List<dynamic>.from(steps.map((x) => x)),
        "distance": distance,
        "duration": duration,
        "summary": summary,
        "weight": weight,
      };
}

class Waypoint {
  Waypoint({
    required this.hint,
    required this.distance,
    required this.name,
    required this.location,
  });

  final String hint;
  final double distance;
  final String name;
  final List<double> location;

  Waypoint copyWith({
    String? hint,
    double? distance,
    String? name,
    List<double>? location,
  }) =>
      Waypoint(
        hint: hint ?? this.hint,
        distance: distance ?? this.distance,
        name: name ?? this.name,
        location: location ?? this.location,
      );

  factory Waypoint.fromRawJson(String str) => Waypoint.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
        hint: json["hint"] == null ? '' : json["hint"],
        distance: json["distance"] == 0.0 ? null : json["distance"].toDouble(),
        name: json["name"] == null ? '' : json["name"],
        location: json["location"] == null ? [] : List<double>.from(json["location"].map((x) => x.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "hint": hint,
        "distance": distance,
        "name": name,
        "location": List<dynamic>.from(location.map((x) => x)),
      };
}
