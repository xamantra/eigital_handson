import 'dart:convert';

class NearbyPlacesResponse {
  NearbyPlacesResponse({
    required this.data,
  });

  final List<NearbyPlaceItem> data;

  NearbyPlacesResponse copyWith({
    List<NearbyPlaceItem>? data,
  }) =>
      NearbyPlacesResponse(
        data: data ?? this.data,
      );

  factory NearbyPlacesResponse.fromRawJson(String str) => NearbyPlacesResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NearbyPlacesResponse.fromJson(List<dynamic> json) => NearbyPlacesResponse(
        data: List<NearbyPlaceItem>.from(json.map((x) => NearbyPlaceItem.fromJson(x))),
      );

  List<dynamic> toJson() => List<dynamic>.from(data.map((x) => x.toJson()));
}

class NearbyPlaceItem {
  NearbyPlaceItem({
    required this.placeId,
    required this.osmType,
    required this.osmId,
    required this.lat,
    required this.lon,
    required this.nearbyPlacesResponseClass,
    required this.type,
    required this.tagType,
    required this.name,
    required this.displayName,
    required this.address,
    required this.boundingbox,
    required this.distance,
  });

  final String placeId;
  final String osmType;
  final String osmId;
  final String lat;
  final String lon;
  final String nearbyPlacesResponseClass;
  final String type;
  final String tagType;
  final String name;
  final String displayName;
  final Address address;
  final List<String> boundingbox;
  final int distance;

  double get latitude => double.parse(lat);
  double get longitude => double.parse(lon);

  NearbyPlaceItem copyWith({
    String? placeId,
    String? osmType,
    String? osmId,
    String? lat,
    String? lon,
    String? nearbyPlacesResponseClass,
    String? type,
    String? tagType,
    String? name,
    String? displayName,
    Address? address,
    List<String>? boundingbox,
    int? distance,
  }) =>
      NearbyPlaceItem(
        placeId: placeId ?? this.placeId,
        osmType: osmType ?? this.osmType,
        osmId: osmId ?? this.osmId,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
        nearbyPlacesResponseClass: nearbyPlacesResponseClass ?? this.nearbyPlacesResponseClass,
        type: type ?? this.type,
        tagType: tagType ?? this.tagType,
        name: name ?? this.name,
        displayName: displayName ?? this.displayName,
        address: address ?? this.address,
        boundingbox: boundingbox ?? this.boundingbox,
        distance: distance ?? this.distance,
      );

  factory NearbyPlaceItem.fromRawJson(String str) => NearbyPlaceItem.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NearbyPlaceItem.fromJson(Map<String, dynamic> json) => NearbyPlaceItem(
        placeId: json["place_id"] == null ? '' : json["place_id"],
        osmType: json["osm_type"] == null ? '' : json["osm_type"],
        osmId: json["osm_id"] == null ? '' : json["osm_id"],
        lat: json["lat"] == null ? '0.0' : json["lat"],
        lon: json["lon"] == null ? '0.0' : json["lon"],
        nearbyPlacesResponseClass: json["class"] == null ? '' : json["class"],
        type: json["type"] == null ? '' : json["type"],
        tagType: json["tag_type"] == null ? '' : json["tag_type"],
        name: json["name"] == null ? '' : json["name"],
        displayName: json["display_name"] == null ? '' : json["display_name"],
        address: json["address"] == null ? Address.empty() : Address.fromJson(json["address"]),
        boundingbox: json["boundingbox"] == null ? [] : List<String>.from(json["boundingbox"].map((x) => x)),
        distance: json["distance"] == null ? 0 : json["distance"],
      );

  Map<String, dynamic> toJson() => {
        "place_id": placeId,
        "osm_type": osmType,
        "osm_id": osmId,
        "lat": lat,
        "lon": lon,
        "class": nearbyPlacesResponseClass,
        "type": type,
        "tag_type": tagType,
        "name": name,
        "display_name": displayName,
        "address": address.toJson(),
        "boundingbox": List<dynamic>.from(boundingbox.map((x) => x)),
        "distance": distance,
      };
}

class Address {
  Address({
    required this.name,
    required this.road,
    required this.neighbourhood,
    required this.suburb,
    required this.city,
    required this.postcode,
    required this.country,
    required this.countryCode,
    required this.houseNumber,
  });

  final String name;
  final String road;
  final String neighbourhood;
  final String suburb;
  final String city;
  final String postcode;
  final String country;
  final String countryCode;
  final String houseNumber;

  factory Address.empty() {
    return Address(
      name: '',
      road: '',
      neighbourhood: '',
      suburb: '',
      city: '',
      postcode: '',
      country: '',
      countryCode: '',
      houseNumber: '',
    );
  }

  Address copyWith({
    String? name,
    String? road,
    String? neighbourhood,
    String? suburb,
    String? city,
    String? postcode,
    String? country,
    String? countryCode,
    String? houseNumber,
  }) =>
      Address(
        name: name ?? this.name,
        road: road ?? this.road,
        neighbourhood: neighbourhood ?? this.neighbourhood,
        suburb: suburb ?? this.suburb,
        city: city ?? this.city,
        postcode: postcode ?? this.postcode,
        country: country ?? this.country,
        countryCode: countryCode ?? this.countryCode,
        houseNumber: houseNumber ?? this.houseNumber,
      );

  factory Address.fromRawJson(String str) => Address.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        name: json["name"] == null ? '' : json["name"],
        road: json["road"] == null ? '' : json["road"],
        neighbourhood: json["neighbourhood"] == null ? '' : json["neighbourhood"],
        suburb: json["suburb"] == null ? '' : json["suburb"],
        city: json["city"] == null ? '' : json["city"],
        postcode: json["postcode"] == null ? '' : json["postcode"],
        country: json["country"] == null ? '' : json["country"],
        countryCode: json["country_code"] == null ? '' : json["country_code"],
        houseNumber: json["house_number"] == null ? '' : json["house_number"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "road": road,
        "neighbourhood": neighbourhood,
        "suburb": suburb,
        "city": city,
        "postcode": postcode,
        "country": country,
        "country_code": countryCode,
        "house_number": houseNumber,
      };
}
