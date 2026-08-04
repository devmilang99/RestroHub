// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedRestaurantsTable extends CachedRestaurants
    with TableInfo<$CachedRestaurantsTable, CachedRestaurant> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedRestaurantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoUrlMeta = const VerificationMeta(
    'logoUrl',
  );
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
    'logo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bannerUrlMeta = const VerificationMeta(
    'bannerUrl',
  );
  @override
  late final GeneratedColumn<String> bannerUrl = GeneratedColumn<String>(
    'banner_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _websiteMeta = const VerificationMeta(
    'website',
  );
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
    'website',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('closed'),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _priceRangeMeta = const VerificationMeta(
    'priceRange',
  );
  @override
  late final GeneratedColumn<String> priceRange = GeneratedColumn<String>(
    'price_range',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(r'$$'),
  );
  static const VerificationMeta _minOrderAmountMeta = const VerificationMeta(
    'minOrderAmount',
  );
  @override
  late final GeneratedColumn<double> minOrderAmount = GeneratedColumn<double>(
    'min_order_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxPercentMeta = const VerificationMeta(
    'taxPercent',
  );
  @override
  late final GeneratedColumn<double> taxPercent = GeneratedColumn<double>(
    'tax_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _locationAddressMeta = const VerificationMeta(
    'locationAddress',
  );
  @override
  late final GeneratedColumn<String> locationAddress = GeneratedColumn<String>(
    'location_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    name,
    description,
    logoUrl,
    bannerUrl,
    phone,
    email,
    website,
    status,
    rating,
    priceRange,
    minOrderAmount,
    taxPercent,
    locationAddress,
    latitude,
    longitude,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_restaurants';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedRestaurant> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('logo_url')) {
      context.handle(
        _logoUrlMeta,
        logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta),
      );
    }
    if (data.containsKey('banner_url')) {
      context.handle(
        _bannerUrlMeta,
        bannerUrl.isAcceptableOrUnknown(data['banner_url']!, _bannerUrlMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('website')) {
      context.handle(
        _websiteMeta,
        website.isAcceptableOrUnknown(data['website']!, _websiteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('price_range')) {
      context.handle(
        _priceRangeMeta,
        priceRange.isAcceptableOrUnknown(data['price_range']!, _priceRangeMeta),
      );
    }
    if (data.containsKey('min_order_amount')) {
      context.handle(
        _minOrderAmountMeta,
        minOrderAmount.isAcceptableOrUnknown(
          data['min_order_amount']!,
          _minOrderAmountMeta,
        ),
      );
    }
    if (data.containsKey('tax_percent')) {
      context.handle(
        _taxPercentMeta,
        taxPercent.isAcceptableOrUnknown(data['tax_percent']!, _taxPercentMeta),
      );
    }
    if (data.containsKey('location_address')) {
      context.handle(
        _locationAddressMeta,
        locationAddress.isAcceptableOrUnknown(
          data['location_address']!,
          _locationAddressMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedRestaurant map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedRestaurant(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      logoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_url'],
      ),
      bannerUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}banner_url'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      website: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      )!,
      priceRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price_range'],
      )!,
      minOrderAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_order_amount'],
      )!,
      taxPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_percent'],
      )!,
      locationAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_address'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $CachedRestaurantsTable createAlias(String alias) {
    return $CachedRestaurantsTable(attachedDatabase, alias);
  }
}

class CachedRestaurant extends DataClass
    implements Insertable<CachedRestaurant> {
  final String id;
  final String? ownerId;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;
  final String? phone;
  final String? email;
  final String? website;
  final String status;
  final double rating;
  final String priceRange;
  final double minOrderAmount;
  final double taxPercent;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  final DateTime lastUpdated;
  const CachedRestaurant({
    required this.id,
    this.ownerId,
    required this.name,
    this.description,
    this.logoUrl,
    this.bannerUrl,
    this.phone,
    this.email,
    this.website,
    required this.status,
    required this.rating,
    required this.priceRange,
    required this.minOrderAmount,
    required this.taxPercent,
    this.locationAddress,
    this.latitude,
    this.longitude,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || logoUrl != null) {
      map['logo_url'] = Variable<String>(logoUrl);
    }
    if (!nullToAbsent || bannerUrl != null) {
      map['banner_url'] = Variable<String>(bannerUrl);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    map['status'] = Variable<String>(status);
    map['rating'] = Variable<double>(rating);
    map['price_range'] = Variable<String>(priceRange);
    map['min_order_amount'] = Variable<double>(minOrderAmount);
    map['tax_percent'] = Variable<double>(taxPercent);
    if (!nullToAbsent || locationAddress != null) {
      map['location_address'] = Variable<String>(locationAddress);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  CachedRestaurantsCompanion toCompanion(bool nullToAbsent) {
    return CachedRestaurantsCompanion(
      id: Value(id),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      logoUrl: logoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(logoUrl),
      bannerUrl: bannerUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(bannerUrl),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      status: Value(status),
      rating: Value(rating),
      priceRange: Value(priceRange),
      minOrderAmount: Value(minOrderAmount),
      taxPercent: Value(taxPercent),
      locationAddress: locationAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(locationAddress),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory CachedRestaurant.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedRestaurant(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      logoUrl: serializer.fromJson<String?>(json['logoUrl']),
      bannerUrl: serializer.fromJson<String?>(json['bannerUrl']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      website: serializer.fromJson<String?>(json['website']),
      status: serializer.fromJson<String>(json['status']),
      rating: serializer.fromJson<double>(json['rating']),
      priceRange: serializer.fromJson<String>(json['priceRange']),
      minOrderAmount: serializer.fromJson<double>(json['minOrderAmount']),
      taxPercent: serializer.fromJson<double>(json['taxPercent']),
      locationAddress: serializer.fromJson<String?>(json['locationAddress']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String?>(ownerId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'logoUrl': serializer.toJson<String?>(logoUrl),
      'bannerUrl': serializer.toJson<String?>(bannerUrl),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'website': serializer.toJson<String?>(website),
      'status': serializer.toJson<String>(status),
      'rating': serializer.toJson<double>(rating),
      'priceRange': serializer.toJson<String>(priceRange),
      'minOrderAmount': serializer.toJson<double>(minOrderAmount),
      'taxPercent': serializer.toJson<double>(taxPercent),
      'locationAddress': serializer.toJson<String?>(locationAddress),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  CachedRestaurant copyWith({
    String? id,
    Value<String?> ownerId = const Value.absent(),
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> logoUrl = const Value.absent(),
    Value<String?> bannerUrl = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> website = const Value.absent(),
    String? status,
    double? rating,
    String? priceRange,
    double? minOrderAmount,
    double? taxPercent,
    Value<String?> locationAddress = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    DateTime? lastUpdated,
  }) => CachedRestaurant(
    id: id ?? this.id,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    logoUrl: logoUrl.present ? logoUrl.value : this.logoUrl,
    bannerUrl: bannerUrl.present ? bannerUrl.value : this.bannerUrl,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    website: website.present ? website.value : this.website,
    status: status ?? this.status,
    rating: rating ?? this.rating,
    priceRange: priceRange ?? this.priceRange,
    minOrderAmount: minOrderAmount ?? this.minOrderAmount,
    taxPercent: taxPercent ?? this.taxPercent,
    locationAddress: locationAddress.present
        ? locationAddress.value
        : this.locationAddress,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  CachedRestaurant copyWithCompanion(CachedRestaurantsCompanion data) {
    return CachedRestaurant(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      bannerUrl: data.bannerUrl.present ? data.bannerUrl.value : this.bannerUrl,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      website: data.website.present ? data.website.value : this.website,
      status: data.status.present ? data.status.value : this.status,
      rating: data.rating.present ? data.rating.value : this.rating,
      priceRange: data.priceRange.present
          ? data.priceRange.value
          : this.priceRange,
      minOrderAmount: data.minOrderAmount.present
          ? data.minOrderAmount.value
          : this.minOrderAmount,
      taxPercent: data.taxPercent.present
          ? data.taxPercent.value
          : this.taxPercent,
      locationAddress: data.locationAddress.present
          ? data.locationAddress.value
          : this.locationAddress,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedRestaurant(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('bannerUrl: $bannerUrl, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('website: $website, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('priceRange: $priceRange, ')
          ..write('minOrderAmount: $minOrderAmount, ')
          ..write('taxPercent: $taxPercent, ')
          ..write('locationAddress: $locationAddress, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    name,
    description,
    logoUrl,
    bannerUrl,
    phone,
    email,
    website,
    status,
    rating,
    priceRange,
    minOrderAmount,
    taxPercent,
    locationAddress,
    latitude,
    longitude,
    lastUpdated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedRestaurant &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.description == this.description &&
          other.logoUrl == this.logoUrl &&
          other.bannerUrl == this.bannerUrl &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.website == this.website &&
          other.status == this.status &&
          other.rating == this.rating &&
          other.priceRange == this.priceRange &&
          other.minOrderAmount == this.minOrderAmount &&
          other.taxPercent == this.taxPercent &&
          other.locationAddress == this.locationAddress &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.lastUpdated == this.lastUpdated);
}

class CachedRestaurantsCompanion extends UpdateCompanion<CachedRestaurant> {
  final Value<String> id;
  final Value<String?> ownerId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> logoUrl;
  final Value<String?> bannerUrl;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> website;
  final Value<String> status;
  final Value<double> rating;
  final Value<String> priceRange;
  final Value<double> minOrderAmount;
  final Value<double> taxPercent;
  final Value<String?> locationAddress;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const CachedRestaurantsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.bannerUrl = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.website = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.priceRange = const Value.absent(),
    this.minOrderAmount = const Value.absent(),
    this.taxPercent = const Value.absent(),
    this.locationAddress = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedRestaurantsCompanion.insert({
    required String id,
    this.ownerId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.bannerUrl = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.website = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.priceRange = const Value.absent(),
    this.minOrderAmount = const Value.absent(),
    this.taxPercent = const Value.absent(),
    this.locationAddress = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CachedRestaurant> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? logoUrl,
    Expression<String>? bannerUrl,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? website,
    Expression<String>? status,
    Expression<double>? rating,
    Expression<String>? priceRange,
    Expression<double>? minOrderAmount,
    Expression<double>? taxPercent,
    Expression<String>? locationAddress,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (bannerUrl != null) 'banner_url': bannerUrl,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      if (status != null) 'status': status,
      if (rating != null) 'rating': rating,
      if (priceRange != null) 'price_range': priceRange,
      if (minOrderAmount != null) 'min_order_amount': minOrderAmount,
      if (taxPercent != null) 'tax_percent': taxPercent,
      if (locationAddress != null) 'location_address': locationAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedRestaurantsCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerId,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? logoUrl,
    Value<String?>? bannerUrl,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? website,
    Value<String>? status,
    Value<double>? rating,
    Value<String>? priceRange,
    Value<double>? minOrderAmount,
    Value<double>? taxPercent,
    Value<String?>? locationAddress,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<DateTime>? lastUpdated,
    Value<int>? rowid,
  }) {
    return CachedRestaurantsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      priceRange: priceRange ?? this.priceRange,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      taxPercent: taxPercent ?? this.taxPercent,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (bannerUrl.present) {
      map['banner_url'] = Variable<String>(bannerUrl.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (priceRange.present) {
      map['price_range'] = Variable<String>(priceRange.value);
    }
    if (minOrderAmount.present) {
      map['min_order_amount'] = Variable<double>(minOrderAmount.value);
    }
    if (taxPercent.present) {
      map['tax_percent'] = Variable<double>(taxPercent.value);
    }
    if (locationAddress.present) {
      map['location_address'] = Variable<String>(locationAddress.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedRestaurantsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('bannerUrl: $bannerUrl, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('website: $website, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('priceRange: $priceRange, ')
          ..write('minOrderAmount: $minOrderAmount, ')
          ..write('taxPercent: $taxPercent, ')
          ..write('locationAddress: $locationAddress, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedMenuCategoriesTable extends CachedMenuCategories
    with TableInfo<$CachedMenuCategoriesTable, CachedMenuCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMenuCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_restaurants (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, restaurantId, name, priority];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_menu_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMenuCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedMenuCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMenuCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
    );
  }

  @override
  $CachedMenuCategoriesTable createAlias(String alias) {
    return $CachedMenuCategoriesTable(attachedDatabase, alias);
  }
}

class CachedMenuCategory extends DataClass
    implements Insertable<CachedMenuCategory> {
  final String id;
  final String restaurantId;
  final String name;
  final int priority;
  const CachedMenuCategory({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.priority,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['name'] = Variable<String>(name);
    map['priority'] = Variable<int>(priority);
    return map;
  }

  CachedMenuCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CachedMenuCategoriesCompanion(
      id: Value(id),
      restaurantId: Value(restaurantId),
      name: Value(name),
      priority: Value(priority),
    );
  }

  factory CachedMenuCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMenuCategory(
      id: serializer.fromJson<String>(json['id']),
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      name: serializer.fromJson<String>(json['name']),
      priority: serializer.fromJson<int>(json['priority']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restaurantId': serializer.toJson<String>(restaurantId),
      'name': serializer.toJson<String>(name),
      'priority': serializer.toJson<int>(priority),
    };
  }

  CachedMenuCategory copyWith({
    String? id,
    String? restaurantId,
    String? name,
    int? priority,
  }) => CachedMenuCategory(
    id: id ?? this.id,
    restaurantId: restaurantId ?? this.restaurantId,
    name: name ?? this.name,
    priority: priority ?? this.priority,
  );
  CachedMenuCategory copyWithCompanion(CachedMenuCategoriesCompanion data) {
    return CachedMenuCategory(
      id: data.id.present ? data.id.value : this.id,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      name: data.name.present ? data.name.value : this.name,
      priority: data.priority.present ? data.priority.value : this.priority,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMenuCategory(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('name: $name, ')
          ..write('priority: $priority')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, restaurantId, name, priority);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMenuCategory &&
          other.id == this.id &&
          other.restaurantId == this.restaurantId &&
          other.name == this.name &&
          other.priority == this.priority);
}

class CachedMenuCategoriesCompanion
    extends UpdateCompanion<CachedMenuCategory> {
  final Value<String> id;
  final Value<String> restaurantId;
  final Value<String> name;
  final Value<int> priority;
  final Value<int> rowid;
  const CachedMenuCategoriesCompanion({
    this.id = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.name = const Value.absent(),
    this.priority = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMenuCategoriesCompanion.insert({
    required String id,
    required String restaurantId,
    required String name,
    this.priority = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restaurantId = Value(restaurantId),
       name = Value(name);
  static Insertable<CachedMenuCategory> custom({
    Expression<String>? id,
    Expression<String>? restaurantId,
    Expression<String>? name,
    Expression<int>? priority,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (name != null) 'name': name,
      if (priority != null) 'priority': priority,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMenuCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? restaurantId,
    Value<String>? name,
    Value<int>? priority,
    Value<int>? rowid,
  }) {
    return CachedMenuCategoriesCompanion(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      priority: priority ?? this.priority,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMenuCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('name: $name, ')
          ..write('priority: $priority, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedMenuItemsTable extends CachedMenuItems
    with TableInfo<$CachedMenuItemsTable, CachedMenuItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMenuItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_menu_categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAvailableMeta = const VerificationMeta(
    'isAvailable',
  );
  @override
  late final GeneratedColumn<bool> isAvailable = GeneratedColumn<bool>(
    'is_available',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_available" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<int> calories = GeneratedColumn<int>(
    'calories',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  dietaryFlags = GeneratedColumn<String>(
    'dietary_flags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  ).withConverter<List<String>>($CachedMenuItemsTable.$converterdietaryFlags);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    name,
    description,
    price,
    imageUrl,
    isAvailable,
    calories,
    rating,
    dietaryFlags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_menu_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedMenuItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('is_available')) {
      context.handle(
        _isAvailableMeta,
        isAvailable.isAcceptableOrUnknown(
          data['is_available']!,
          _isAvailableMeta,
        ),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedMenuItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMenuItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      isAvailable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_available'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      dietaryFlags: $CachedMenuItemsTable.$converterdietaryFlags.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}dietary_flags'],
        )!,
      ),
    );
  }

  @override
  $CachedMenuItemsTable createAlias(String alias) {
    return $CachedMenuItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterdietaryFlags =
      const StringListConverter();
}

class CachedMenuItem extends DataClass implements Insertable<CachedMenuItem> {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int? calories;
  final double? rating;
  final List<String> dietaryFlags;
  const CachedMenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    this.calories,
    this.rating,
    required this.dietaryFlags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['is_available'] = Variable<bool>(isAvailable);
    if (!nullToAbsent || calories != null) {
      map['calories'] = Variable<int>(calories);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    {
      map['dietary_flags'] = Variable<String>(
        $CachedMenuItemsTable.$converterdietaryFlags.toSql(dietaryFlags),
      );
    }
    return map;
  }

  CachedMenuItemsCompanion toCompanion(bool nullToAbsent) {
    return CachedMenuItemsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      price: Value(price),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      isAvailable: Value(isAvailable),
      calories: calories == null && nullToAbsent
          ? const Value.absent()
          : Value(calories),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      dietaryFlags: Value(dietaryFlags),
    );
  }

  factory CachedMenuItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMenuItem(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      price: serializer.fromJson<double>(json['price']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      isAvailable: serializer.fromJson<bool>(json['isAvailable']),
      calories: serializer.fromJson<int?>(json['calories']),
      rating: serializer.fromJson<double?>(json['rating']),
      dietaryFlags: serializer.fromJson<List<String>>(json['dietaryFlags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'price': serializer.toJson<double>(price),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'isAvailable': serializer.toJson<bool>(isAvailable),
      'calories': serializer.toJson<int?>(calories),
      'rating': serializer.toJson<double?>(rating),
      'dietaryFlags': serializer.toJson<List<String>>(dietaryFlags),
    };
  }

  CachedMenuItem copyWith({
    String? id,
    String? categoryId,
    String? name,
    Value<String?> description = const Value.absent(),
    double? price,
    Value<String?> imageUrl = const Value.absent(),
    bool? isAvailable,
    Value<int?> calories = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    List<String>? dietaryFlags,
  }) => CachedMenuItem(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    price: price ?? this.price,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    isAvailable: isAvailable ?? this.isAvailable,
    calories: calories.present ? calories.value : this.calories,
    rating: rating.present ? rating.value : this.rating,
    dietaryFlags: dietaryFlags ?? this.dietaryFlags,
  );
  CachedMenuItem copyWithCompanion(CachedMenuItemsCompanion data) {
    return CachedMenuItem(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      price: data.price.present ? data.price.value : this.price,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      isAvailable: data.isAvailable.present
          ? data.isAvailable.value
          : this.isAvailable,
      calories: data.calories.present ? data.calories.value : this.calories,
      rating: data.rating.present ? data.rating.value : this.rating,
      dietaryFlags: data.dietaryFlags.present
          ? data.dietaryFlags.value
          : this.dietaryFlags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMenuItem(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('calories: $calories, ')
          ..write('rating: $rating, ')
          ..write('dietaryFlags: $dietaryFlags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    name,
    description,
    price,
    imageUrl,
    isAvailable,
    calories,
    rating,
    dietaryFlags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMenuItem &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.description == this.description &&
          other.price == this.price &&
          other.imageUrl == this.imageUrl &&
          other.isAvailable == this.isAvailable &&
          other.calories == this.calories &&
          other.rating == this.rating &&
          other.dietaryFlags == this.dietaryFlags);
}

class CachedMenuItemsCompanion extends UpdateCompanion<CachedMenuItem> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> price;
  final Value<String?> imageUrl;
  final Value<bool> isAvailable;
  final Value<int?> calories;
  final Value<double?> rating;
  final Value<List<String>> dietaryFlags;
  final Value<int> rowid;
  const CachedMenuItemsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.calories = const Value.absent(),
    this.rating = const Value.absent(),
    this.dietaryFlags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMenuItemsCompanion.insert({
    required String id,
    required String categoryId,
    required String name,
    this.description = const Value.absent(),
    required double price,
    this.imageUrl = const Value.absent(),
    this.isAvailable = const Value.absent(),
    this.calories = const Value.absent(),
    this.rating = const Value.absent(),
    this.dietaryFlags = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       name = Value(name),
       price = Value(price);
  static Insertable<CachedMenuItem> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? price,
    Expression<String>? imageUrl,
    Expression<bool>? isAvailable,
    Expression<int>? calories,
    Expression<double>? rating,
    Expression<String>? dietaryFlags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (imageUrl != null) 'image_url': imageUrl,
      if (isAvailable != null) 'is_available': isAvailable,
      if (calories != null) 'calories': calories,
      if (rating != null) 'rating': rating,
      if (dietaryFlags != null) 'dietary_flags': dietaryFlags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMenuItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<String>? name,
    Value<String?>? description,
    Value<double>? price,
    Value<String?>? imageUrl,
    Value<bool>? isAvailable,
    Value<int?>? calories,
    Value<double?>? rating,
    Value<List<String>>? dietaryFlags,
    Value<int>? rowid,
  }) {
    return CachedMenuItemsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      calories: calories ?? this.calories,
      rating: rating ?? this.rating,
      dietaryFlags: dietaryFlags ?? this.dietaryFlags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (isAvailable.present) {
      map['is_available'] = Variable<bool>(isAvailable.value);
    }
    if (calories.present) {
      map['calories'] = Variable<int>(calories.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (dietaryFlags.present) {
      map['dietary_flags'] = Variable<String>(
        $CachedMenuItemsTable.$converterdietaryFlags.toSql(dietaryFlags.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMenuItemsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('isAvailable: $isAvailable, ')
          ..write('calories: $calories, ')
          ..write('rating: $rating, ')
          ..write('dietaryFlags: $dietaryFlags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedUserAddressesTable extends CachedUserAddresses
    with TableInfo<$CachedUserAddressesTable, CachedUserAddressesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedUserAddressesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Home'),
  );
  static const VerificationMeta _addressLine1Meta = const VerificationMeta(
    'addressLine1',
  );
  @override
  late final GeneratedColumn<String> addressLine1 = GeneratedColumn<String>(
    'address_line1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressLine2Meta = const VerificationMeta(
    'addressLine2',
  );
  @override
  late final GeneratedColumn<String> addressLine2 = GeneratedColumn<String>(
    'address_line2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postalCodeMeta = const VerificationMeta(
    'postalCode',
  );
  @override
  late final GeneratedColumn<String> postalCode = GeneratedColumn<String>(
    'postal_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    addressLine1,
    addressLine2,
    city,
    state,
    postalCode,
    latitude,
    longitude,
    isDefault,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_user_addresses';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedUserAddressesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('address_line1')) {
      context.handle(
        _addressLine1Meta,
        addressLine1.isAcceptableOrUnknown(
          data['address_line1']!,
          _addressLine1Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_addressLine1Meta);
    }
    if (data.containsKey('address_line2')) {
      context.handle(
        _addressLine2Meta,
        addressLine2.isAcceptableOrUnknown(
          data['address_line2']!,
          _addressLine2Meta,
        ),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('postal_code')) {
      context.handle(
        _postalCodeMeta,
        postalCode.isAcceptableOrUnknown(data['postal_code']!, _postalCodeMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedUserAddressesData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedUserAddressesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      addressLine1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_line1'],
      )!,
      addressLine2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_line2'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      postalCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postal_code'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
    );
  }

  @override
  $CachedUserAddressesTable createAlias(String alias) {
    return $CachedUserAddressesTable(attachedDatabase, alias);
  }
}

class CachedUserAddressesData extends DataClass
    implements Insertable<CachedUserAddressesData> {
  final String id;
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  const CachedUserAddressesData({
    required this.id,
    required this.label,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    this.postalCode,
    this.latitude,
    this.longitude,
    required this.isDefault,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    map['address_line1'] = Variable<String>(addressLine1);
    if (!nullToAbsent || addressLine2 != null) {
      map['address_line2'] = Variable<String>(addressLine2);
    }
    map['city'] = Variable<String>(city);
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || postalCode != null) {
      map['postal_code'] = Variable<String>(postalCode);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['is_default'] = Variable<bool>(isDefault);
    return map;
  }

  CachedUserAddressesCompanion toCompanion(bool nullToAbsent) {
    return CachedUserAddressesCompanion(
      id: Value(id),
      label: Value(label),
      addressLine1: Value(addressLine1),
      addressLine2: addressLine2 == null && nullToAbsent
          ? const Value.absent()
          : Value(addressLine2),
      city: Value(city),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      postalCode: postalCode == null && nullToAbsent
          ? const Value.absent()
          : Value(postalCode),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      isDefault: Value(isDefault),
    );
  }

  factory CachedUserAddressesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedUserAddressesData(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      addressLine1: serializer.fromJson<String>(json['addressLine1']),
      addressLine2: serializer.fromJson<String?>(json['addressLine2']),
      city: serializer.fromJson<String>(json['city']),
      state: serializer.fromJson<String?>(json['state']),
      postalCode: serializer.fromJson<String?>(json['postalCode']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'addressLine1': serializer.toJson<String>(addressLine1),
      'addressLine2': serializer.toJson<String?>(addressLine2),
      'city': serializer.toJson<String>(city),
      'state': serializer.toJson<String?>(state),
      'postalCode': serializer.toJson<String?>(postalCode),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'isDefault': serializer.toJson<bool>(isDefault),
    };
  }

  CachedUserAddressesData copyWith({
    String? id,
    String? label,
    String? addressLine1,
    Value<String?> addressLine2 = const Value.absent(),
    String? city,
    Value<String?> state = const Value.absent(),
    Value<String?> postalCode = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    bool? isDefault,
  }) => CachedUserAddressesData(
    id: id ?? this.id,
    label: label ?? this.label,
    addressLine1: addressLine1 ?? this.addressLine1,
    addressLine2: addressLine2.present ? addressLine2.value : this.addressLine2,
    city: city ?? this.city,
    state: state.present ? state.value : this.state,
    postalCode: postalCode.present ? postalCode.value : this.postalCode,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    isDefault: isDefault ?? this.isDefault,
  );
  CachedUserAddressesData copyWithCompanion(CachedUserAddressesCompanion data) {
    return CachedUserAddressesData(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      addressLine1: data.addressLine1.present
          ? data.addressLine1.value
          : this.addressLine1,
      addressLine2: data.addressLine2.present
          ? data.addressLine2.value
          : this.addressLine2,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      postalCode: data.postalCode.present
          ? data.postalCode.value
          : this.postalCode,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedUserAddressesData(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('addressLine1: $addressLine1, ')
          ..write('addressLine2: $addressLine2, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('postalCode: $postalCode, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isDefault: $isDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    label,
    addressLine1,
    addressLine2,
    city,
    state,
    postalCode,
    latitude,
    longitude,
    isDefault,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedUserAddressesData &&
          other.id == this.id &&
          other.label == this.label &&
          other.addressLine1 == this.addressLine1 &&
          other.addressLine2 == this.addressLine2 &&
          other.city == this.city &&
          other.state == this.state &&
          other.postalCode == this.postalCode &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.isDefault == this.isDefault);
}

class CachedUserAddressesCompanion
    extends UpdateCompanion<CachedUserAddressesData> {
  final Value<String> id;
  final Value<String> label;
  final Value<String> addressLine1;
  final Value<String?> addressLine2;
  final Value<String> city;
  final Value<String?> state;
  final Value<String?> postalCode;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<bool> isDefault;
  final Value<int> rowid;
  const CachedUserAddressesCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.addressLine1 = const Value.absent(),
    this.addressLine2 = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedUserAddressesCompanion.insert({
    required String id,
    this.label = const Value.absent(),
    required String addressLine1,
    this.addressLine2 = const Value.absent(),
    required String city,
    this.state = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       addressLine1 = Value(addressLine1),
       city = Value(city);
  static Insertable<CachedUserAddressesData> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? addressLine1,
    Expression<String>? addressLine2,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? postalCode,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<bool>? isDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postal_code': postalCode,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isDefault != null) 'is_default': isDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedUserAddressesCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String>? addressLine1,
    Value<String?>? addressLine2,
    Value<String>? city,
    Value<String?>? state,
    Value<String?>? postalCode,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<bool>? isDefault,
    Value<int>? rowid,
  }) {
    return CachedUserAddressesCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (addressLine1.present) {
      map['address_line1'] = Variable<String>(addressLine1.value);
    }
    if (addressLine2.present) {
      map['address_line2'] = Variable<String>(addressLine2.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (postalCode.present) {
      map['postal_code'] = Variable<String>(postalCode.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedUserAddressesCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('addressLine1: $addressLine1, ')
          ..write('addressLine2: $addressLine2, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('postalCode: $postalCode, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('isDefault: $isDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedOrdersTable extends CachedOrders
    with TableInfo<$CachedOrdersTable, CachedOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryFeeMeta = const VerificationMeta(
    'deliveryFee',
  );
  @override
  late final GeneratedColumn<double> deliveryFee = GeneratedColumn<double>(
    'delivery_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxAmountMeta = const VerificationMeta(
    'taxAmount',
  );
  @override
  late final GeneratedColumn<double> taxAmount = GeneratedColumn<double>(
    'tax_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    restaurantId,
    status,
    paymentStatus,
    subtotal,
    deliveryFee,
    taxAmount,
    discountAmount,
    totalAmount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restaurantIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentStatusMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('delivery_fee')) {
      context.handle(
        _deliveryFeeMeta,
        deliveryFee.isAcceptableOrUnknown(
          data['delivery_fee']!,
          _deliveryFeeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deliveryFeeMeta);
    }
    if (data.containsKey('tax_amount')) {
      context.handle(
        _taxAmountMeta,
        taxAmount.isAcceptableOrUnknown(data['tax_amount']!, _taxAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_taxAmountMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discountAmountMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedOrder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      deliveryFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delivery_fee'],
      )!,
      taxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_amount'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CachedOrdersTable createAlias(String alias) {
    return $CachedOrdersTable(attachedDatabase, alias);
  }
}

class CachedOrder extends DataClass implements Insertable<CachedOrder> {
  final String id;
  final String restaurantId;
  final String status;
  final String paymentStatus;
  final double subtotal;
  final double deliveryFee;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final DateTime createdAt;
  const CachedOrder({
    required this.id,
    required this.restaurantId,
    required this.status,
    required this.paymentStatus,
    required this.subtotal,
    required this.deliveryFee,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['restaurant_id'] = Variable<String>(restaurantId);
    map['status'] = Variable<String>(status);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['subtotal'] = Variable<double>(subtotal);
    map['delivery_fee'] = Variable<double>(deliveryFee);
    map['tax_amount'] = Variable<double>(taxAmount);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['total_amount'] = Variable<double>(totalAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CachedOrdersCompanion toCompanion(bool nullToAbsent) {
    return CachedOrdersCompanion(
      id: Value(id),
      restaurantId: Value(restaurantId),
      status: Value(status),
      paymentStatus: Value(paymentStatus),
      subtotal: Value(subtotal),
      deliveryFee: Value(deliveryFee),
      taxAmount: Value(taxAmount),
      discountAmount: Value(discountAmount),
      totalAmount: Value(totalAmount),
      createdAt: Value(createdAt),
    );
  }

  factory CachedOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedOrder(
      id: serializer.fromJson<String>(json['id']),
      restaurantId: serializer.fromJson<String>(json['restaurantId']),
      status: serializer.fromJson<String>(json['status']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      deliveryFee: serializer.fromJson<double>(json['deliveryFee']),
      taxAmount: serializer.fromJson<double>(json['taxAmount']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'restaurantId': serializer.toJson<String>(restaurantId),
      'status': serializer.toJson<String>(status),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'subtotal': serializer.toJson<double>(subtotal),
      'deliveryFee': serializer.toJson<double>(deliveryFee),
      'taxAmount': serializer.toJson<double>(taxAmount),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedOrder copyWith({
    String? id,
    String? restaurantId,
    String? status,
    String? paymentStatus,
    double? subtotal,
    double? deliveryFee,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    DateTime? createdAt,
  }) => CachedOrder(
    id: id ?? this.id,
    restaurantId: restaurantId ?? this.restaurantId,
    status: status ?? this.status,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    subtotal: subtotal ?? this.subtotal,
    deliveryFee: deliveryFee ?? this.deliveryFee,
    taxAmount: taxAmount ?? this.taxAmount,
    discountAmount: discountAmount ?? this.discountAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    createdAt: createdAt ?? this.createdAt,
  );
  CachedOrder copyWithCompanion(CachedOrdersCompanion data) {
    return CachedOrder(
      id: data.id.present ? data.id.value : this.id,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      status: data.status.present ? data.status.value : this.status,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      deliveryFee: data.deliveryFee.present
          ? data.deliveryFee.value
          : this.deliveryFee,
      taxAmount: data.taxAmount.present ? data.taxAmount.value : this.taxAmount,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedOrder(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('status: $status, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('subtotal: $subtotal, ')
          ..write('deliveryFee: $deliveryFee, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    restaurantId,
    status,
    paymentStatus,
    subtotal,
    deliveryFee,
    taxAmount,
    discountAmount,
    totalAmount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedOrder &&
          other.id == this.id &&
          other.restaurantId == this.restaurantId &&
          other.status == this.status &&
          other.paymentStatus == this.paymentStatus &&
          other.subtotal == this.subtotal &&
          other.deliveryFee == this.deliveryFee &&
          other.taxAmount == this.taxAmount &&
          other.discountAmount == this.discountAmount &&
          other.totalAmount == this.totalAmount &&
          other.createdAt == this.createdAt);
}

class CachedOrdersCompanion extends UpdateCompanion<CachedOrder> {
  final Value<String> id;
  final Value<String> restaurantId;
  final Value<String> status;
  final Value<String> paymentStatus;
  final Value<double> subtotal;
  final Value<double> deliveryFee;
  final Value<double> taxAmount;
  final Value<double> discountAmount;
  final Value<double> totalAmount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CachedOrdersCompanion({
    this.id = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.status = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.deliveryFee = const Value.absent(),
    this.taxAmount = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedOrdersCompanion.insert({
    required String id,
    required String restaurantId,
    required String status,
    required String paymentStatus,
    required double subtotal,
    required double deliveryFee,
    required double taxAmount,
    required double discountAmount,
    required double totalAmount,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       restaurantId = Value(restaurantId),
       status = Value(status),
       paymentStatus = Value(paymentStatus),
       subtotal = Value(subtotal),
       deliveryFee = Value(deliveryFee),
       taxAmount = Value(taxAmount),
       discountAmount = Value(discountAmount),
       totalAmount = Value(totalAmount),
       createdAt = Value(createdAt);
  static Insertable<CachedOrder> custom({
    Expression<String>? id,
    Expression<String>? restaurantId,
    Expression<String>? status,
    Expression<String>? paymentStatus,
    Expression<double>? subtotal,
    Expression<double>? deliveryFee,
    Expression<double>? taxAmount,
    Expression<double>? discountAmount,
    Expression<double>? totalAmount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (status != null) 'status': status,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (subtotal != null) 'subtotal': subtotal,
      if (deliveryFee != null) 'delivery_fee': deliveryFee,
      if (taxAmount != null) 'tax_amount': taxAmount,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedOrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? restaurantId,
    Value<String>? status,
    Value<String>? paymentStatus,
    Value<double>? subtotal,
    Value<double>? deliveryFee,
    Value<double>? taxAmount,
    Value<double>? discountAmount,
    Value<double>? totalAmount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CachedOrdersCompanion(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (deliveryFee.present) {
      map['delivery_fee'] = Variable<double>(deliveryFee.value);
    }
    if (taxAmount.present) {
      map['tax_amount'] = Variable<double>(taxAmount.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedOrdersCompanion(')
          ..write('id: $id, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('status: $status, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('subtotal: $subtotal, ')
          ..write('deliveryFee: $deliveryFee, ')
          ..write('taxAmount: $taxAmount, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedOrderItemsTable extends CachedOrderItems
    with TableInfo<$CachedOrderItemsTable, CachedOrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedOrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cached_orders (id)',
    ),
  );
  static const VerificationMeta _menuItemIdMeta = const VerificationMeta(
    'menuItemId',
  );
  @override
  late final GeneratedColumn<String> menuItemId = GeneratedColumn<String>(
    'menu_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPriceMeta = const VerificationMeta(
    'totalPrice',
  );
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
    'total_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orderId,
    menuItemId,
    name,
    quantity,
    unitPrice,
    totalPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_order_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedOrderItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('menu_item_id')) {
      context.handle(
        _menuItemIdMeta,
        menuItemId.isAcceptableOrUnknown(
          data['menu_item_id']!,
          _menuItemIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total_price')) {
      context.handle(
        _totalPriceMeta,
        totalPrice.isAcceptableOrUnknown(data['total_price']!, _totalPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_totalPriceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedOrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedOrderItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      menuItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}menu_item_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      totalPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_price'],
      )!,
    );
  }

  @override
  $CachedOrderItemsTable createAlias(String alias) {
    return $CachedOrderItemsTable(attachedDatabase, alias);
  }
}

class CachedOrderItem extends DataClass implements Insertable<CachedOrderItem> {
  final String id;
  final String orderId;
  final String? menuItemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  const CachedOrderItem({
    required this.id,
    required this.orderId,
    this.menuItemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['order_id'] = Variable<String>(orderId);
    if (!nullToAbsent || menuItemId != null) {
      map['menu_item_id'] = Variable<String>(menuItemId);
    }
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_price'] = Variable<double>(totalPrice);
    return map;
  }

  CachedOrderItemsCompanion toCompanion(bool nullToAbsent) {
    return CachedOrderItemsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      menuItemId: menuItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(menuItemId),
      name: Value(name),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      totalPrice: Value(totalPrice),
    );
  }

  factory CachedOrderItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedOrderItem(
      id: serializer.fromJson<String>(json['id']),
      orderId: serializer.fromJson<String>(json['orderId']),
      menuItemId: serializer.fromJson<String?>(json['menuItemId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'orderId': serializer.toJson<String>(orderId),
      'menuItemId': serializer.toJson<String?>(menuItemId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalPrice': serializer.toJson<double>(totalPrice),
    };
  }

  CachedOrderItem copyWith({
    String? id,
    String? orderId,
    Value<String?> menuItemId = const Value.absent(),
    String? name,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
  }) => CachedOrderItem(
    id: id ?? this.id,
    orderId: orderId ?? this.orderId,
    menuItemId: menuItemId.present ? menuItemId.value : this.menuItemId,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    totalPrice: totalPrice ?? this.totalPrice,
  );
  CachedOrderItem copyWithCompanion(CachedOrderItemsCompanion data) {
    return CachedOrderItem(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      menuItemId: data.menuItemId.present
          ? data.menuItemId.value
          : this.menuItemId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalPrice: data.totalPrice.present
          ? data.totalPrice.value
          : this.totalPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedOrderItem(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('menuItemId: $menuItemId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orderId,
    menuItemId,
    name,
    quantity,
    unitPrice,
    totalPrice,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedOrderItem &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.menuItemId == this.menuItemId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.totalPrice == this.totalPrice);
}

class CachedOrderItemsCompanion extends UpdateCompanion<CachedOrderItem> {
  final Value<String> id;
  final Value<String> orderId;
  final Value<String?> menuItemId;
  final Value<String> name;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> totalPrice;
  final Value<int> rowid;
  const CachedOrderItemsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.menuItemId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedOrderItemsCompanion.insert({
    required String id,
    required String orderId,
    this.menuItemId = const Value.absent(),
    required String name,
    required int quantity,
    required double unitPrice,
    required double totalPrice,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderId = Value(orderId),
       name = Value(name),
       quantity = Value(quantity),
       unitPrice = Value(unitPrice),
       totalPrice = Value(totalPrice);
  static Insertable<CachedOrderItem> custom({
    Expression<String>? id,
    Expression<String>? orderId,
    Expression<String>? menuItemId,
    Expression<String>? name,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? totalPrice,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (menuItemId != null) 'menu_item_id': menuItemId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalPrice != null) 'total_price': totalPrice,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedOrderItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? orderId,
    Value<String?>? menuItemId,
    Value<String>? name,
    Value<int>? quantity,
    Value<double>? unitPrice,
    Value<double>? totalPrice,
    Value<int>? rowid,
  }) {
    return CachedOrderItemsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (menuItemId.present) {
      map['menu_item_id'] = Variable<String>(menuItemId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedOrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('menuItemId: $menuItemId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedFavouritesTable extends CachedFavourites
    with TableInfo<$CachedFavouritesTable, CachedFavourite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedFavouritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_favourites';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedFavourite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedFavourite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedFavourite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $CachedFavouritesTable createAlias(String alias) {
    return $CachedFavouritesTable(attachedDatabase, alias);
  }
}

class CachedFavourite extends DataClass implements Insertable<CachedFavourite> {
  final String id;
  final String type;
  final DateTime addedAt;
  const CachedFavourite({
    required this.id,
    required this.type,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CachedFavouritesCompanion toCompanion(bool nullToAbsent) {
    return CachedFavouritesCompanion(
      id: Value(id),
      type: Value(type),
      addedAt: Value(addedAt),
    );
  }

  factory CachedFavourite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedFavourite(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CachedFavourite copyWith({String? id, String? type, DateTime? addedAt}) =>
      CachedFavourite(
        id: id ?? this.id,
        type: type ?? this.type,
        addedAt: addedAt ?? this.addedAt,
      );
  CachedFavourite copyWithCompanion(CachedFavouritesCompanion data) {
    return CachedFavourite(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedFavourite(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedFavourite &&
          other.id == this.id &&
          other.type == this.type &&
          other.addedAt == this.addedAt);
}

class CachedFavouritesCompanion extends UpdateCompanion<CachedFavourite> {
  final Value<String> id;
  final Value<String> type;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const CachedFavouritesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedFavouritesCompanion.insert({
    required String id,
    required String type,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type);
  static Insertable<CachedFavourite> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedFavouritesCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return CachedFavouritesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedFavouritesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedCartItemsTable extends CachedCartItems
    with TableInfo<$CachedCartItemsTable, CachedCartItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedCartItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _menuItemIdMeta = const VerificationMeta(
    'menuItemId',
  );
  @override
  late final GeneratedColumn<String> menuItemId = GeneratedColumn<String>(
    'menu_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restaurantIdMeta = const VerificationMeta(
    'restaurantId',
  );
  @override
  late final GeneratedColumn<String> restaurantId = GeneratedColumn<String>(
    'restaurant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    menuItemId,
    restaurantId,
    name,
    imageUrl,
    price,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_cart_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedCartItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('menu_item_id')) {
      context.handle(
        _menuItemIdMeta,
        menuItemId.isAcceptableOrUnknown(
          data['menu_item_id']!,
          _menuItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_menuItemIdMeta);
    }
    if (data.containsKey('restaurant_id')) {
      context.handle(
        _restaurantIdMeta,
        restaurantId.isAcceptableOrUnknown(
          data['restaurant_id']!,
          _restaurantIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {menuItemId};
  @override
  CachedCartItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCartItem(
      menuItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}menu_item_id'],
      )!,
      restaurantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restaurant_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $CachedCartItemsTable createAlias(String alias) {
    return $CachedCartItemsTable(attachedDatabase, alias);
  }
}

class CachedCartItem extends DataClass implements Insertable<CachedCartItem> {
  final String menuItemId;
  final String? restaurantId;
  final String name;
  final String? imageUrl;
  final double price;
  final int quantity;
  const CachedCartItem({
    required this.menuItemId,
    this.restaurantId,
    required this.name,
    this.imageUrl,
    required this.price,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['menu_item_id'] = Variable<String>(menuItemId);
    if (!nullToAbsent || restaurantId != null) {
      map['restaurant_id'] = Variable<String>(restaurantId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['price'] = Variable<double>(price);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  CachedCartItemsCompanion toCompanion(bool nullToAbsent) {
    return CachedCartItemsCompanion(
      menuItemId: Value(menuItemId),
      restaurantId: restaurantId == null && nullToAbsent
          ? const Value.absent()
          : Value(restaurantId),
      name: Value(name),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      price: Value(price),
      quantity: Value(quantity),
    );
  }

  factory CachedCartItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCartItem(
      menuItemId: serializer.fromJson<String>(json['menuItemId']),
      restaurantId: serializer.fromJson<String?>(json['restaurantId']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      price: serializer.fromJson<double>(json['price']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'menuItemId': serializer.toJson<String>(menuItemId),
      'restaurantId': serializer.toJson<String?>(restaurantId),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'price': serializer.toJson<double>(price),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  CachedCartItem copyWith({
    String? menuItemId,
    Value<String?> restaurantId = const Value.absent(),
    String? name,
    Value<String?> imageUrl = const Value.absent(),
    double? price,
    int? quantity,
  }) => CachedCartItem(
    menuItemId: menuItemId ?? this.menuItemId,
    restaurantId: restaurantId.present ? restaurantId.value : this.restaurantId,
    name: name ?? this.name,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    price: price ?? this.price,
    quantity: quantity ?? this.quantity,
  );
  CachedCartItem copyWithCompanion(CachedCartItemsCompanion data) {
    return CachedCartItem(
      menuItemId: data.menuItemId.present
          ? data.menuItemId.value
          : this.menuItemId,
      restaurantId: data.restaurantId.present
          ? data.restaurantId.value
          : this.restaurantId,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      price: data.price.present ? data.price.value : this.price,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCartItem(')
          ..write('menuItemId: $menuItemId, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('price: $price, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(menuItemId, restaurantId, name, imageUrl, price, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCartItem &&
          other.menuItemId == this.menuItemId &&
          other.restaurantId == this.restaurantId &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.price == this.price &&
          other.quantity == this.quantity);
}

class CachedCartItemsCompanion extends UpdateCompanion<CachedCartItem> {
  final Value<String> menuItemId;
  final Value<String?> restaurantId;
  final Value<String> name;
  final Value<String?> imageUrl;
  final Value<double> price;
  final Value<int> quantity;
  final Value<int> rowid;
  const CachedCartItemsCompanion({
    this.menuItemId = const Value.absent(),
    this.restaurantId = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.price = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCartItemsCompanion.insert({
    required String menuItemId,
    this.restaurantId = const Value.absent(),
    required String name,
    this.imageUrl = const Value.absent(),
    required double price,
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : menuItemId = Value(menuItemId),
       name = Value(name),
       price = Value(price);
  static Insertable<CachedCartItem> custom({
    Expression<String>? menuItemId,
    Expression<String>? restaurantId,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<double>? price,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (menuItemId != null) 'menu_item_id': menuItemId,
      if (restaurantId != null) 'restaurant_id': restaurantId,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (price != null) 'price': price,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCartItemsCompanion copyWith({
    Value<String>? menuItemId,
    Value<String?>? restaurantId,
    Value<String>? name,
    Value<String?>? imageUrl,
    Value<double>? price,
    Value<int>? quantity,
    Value<int>? rowid,
  }) {
    return CachedCartItemsCompanion(
      menuItemId: menuItemId ?? this.menuItemId,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (menuItemId.present) {
      map['menu_item_id'] = Variable<String>(menuItemId.value);
    }
    if (restaurantId.present) {
      map['restaurant_id'] = Variable<String>(restaurantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCartItemsCompanion(')
          ..write('menuItemId: $menuItemId, ')
          ..write('restaurantId: $restaurantId, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('price: $price, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tableIdentifierMeta = const VerificationMeta(
    'tableIdentifier',
  );
  @override
  late final GeneratedColumn<String> tableIdentifier = GeneratedColumn<String>(
    'table_identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncMeta = const VerificationMeta(
    'lastSync',
  );
  @override
  late final GeneratedColumn<DateTime> lastSync = GeneratedColumn<DateTime>(
    'last_sync',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tableIdentifier, lastSync];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('table_identifier')) {
      context.handle(
        _tableIdentifierMeta,
        tableIdentifier.isAcceptableOrUnknown(
          data['table_identifier']!,
          _tableIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_tableIdentifierMeta);
    }
    if (data.containsKey('last_sync')) {
      context.handle(
        _lastSyncMeta,
        lastSync.isAcceptableOrUnknown(data['last_sync']!, _lastSyncMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSyncMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tableIdentifier};
  @override
  SyncMetadataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataData(
      tableIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_identifier'],
      )!,
      lastSync: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync'],
      )!,
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataData extends DataClass
    implements Insertable<SyncMetadataData> {
  final String tableIdentifier;
  final DateTime lastSync;
  const SyncMetadataData({
    required this.tableIdentifier,
    required this.lastSync,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['table_identifier'] = Variable<String>(tableIdentifier);
    map['last_sync'] = Variable<DateTime>(lastSync);
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      tableIdentifier: Value(tableIdentifier),
      lastSync: Value(lastSync),
    );
  }

  factory SyncMetadataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataData(
      tableIdentifier: serializer.fromJson<String>(json['tableIdentifier']),
      lastSync: serializer.fromJson<DateTime>(json['lastSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tableIdentifier': serializer.toJson<String>(tableIdentifier),
      'lastSync': serializer.toJson<DateTime>(lastSync),
    };
  }

  SyncMetadataData copyWith({String? tableIdentifier, DateTime? lastSync}) =>
      SyncMetadataData(
        tableIdentifier: tableIdentifier ?? this.tableIdentifier,
        lastSync: lastSync ?? this.lastSync,
      );
  SyncMetadataData copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataData(
      tableIdentifier: data.tableIdentifier.present
          ? data.tableIdentifier.value
          : this.tableIdentifier,
      lastSync: data.lastSync.present ? data.lastSync.value : this.lastSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataData(')
          ..write('tableIdentifier: $tableIdentifier, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tableIdentifier, lastSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataData &&
          other.tableIdentifier == this.tableIdentifier &&
          other.lastSync == this.lastSync);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataData> {
  final Value<String> tableIdentifier;
  final Value<DateTime> lastSync;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.tableIdentifier = const Value.absent(),
    this.lastSync = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String tableIdentifier,
    required DateTime lastSync,
    this.rowid = const Value.absent(),
  }) : tableIdentifier = Value(tableIdentifier),
       lastSync = Value(lastSync);
  static Insertable<SyncMetadataData> custom({
    Expression<String>? tableIdentifier,
    Expression<DateTime>? lastSync,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tableIdentifier != null) 'table_identifier': tableIdentifier,
      if (lastSync != null) 'last_sync': lastSync,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? tableIdentifier,
    Value<DateTime>? lastSync,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      tableIdentifier: tableIdentifier ?? this.tableIdentifier,
      lastSync: lastSync ?? this.lastSync,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tableIdentifier.present) {
      map['table_identifier'] = Variable<String>(tableIdentifier.value);
    }
    if (lastSync.present) {
      map['last_sync'] = Variable<DateTime>(lastSync.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('tableIdentifier: $tableIdentifier, ')
          ..write('lastSync: $lastSync, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedRestaurantsTable cachedRestaurants =
      $CachedRestaurantsTable(this);
  late final $CachedMenuCategoriesTable cachedMenuCategories =
      $CachedMenuCategoriesTable(this);
  late final $CachedMenuItemsTable cachedMenuItems = $CachedMenuItemsTable(
    this,
  );
  late final $CachedUserAddressesTable cachedUserAddresses =
      $CachedUserAddressesTable(this);
  late final $CachedOrdersTable cachedOrders = $CachedOrdersTable(this);
  late final $CachedOrderItemsTable cachedOrderItems = $CachedOrderItemsTable(
    this,
  );
  late final $CachedFavouritesTable cachedFavourites = $CachedFavouritesTable(
    this,
  );
  late final $CachedCartItemsTable cachedCartItems = $CachedCartItemsTable(
    this,
  );
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedRestaurants,
    cachedMenuCategories,
    cachedMenuItems,
    cachedUserAddresses,
    cachedOrders,
    cachedOrderItems,
    cachedFavourites,
    cachedCartItems,
    syncMetadata,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cached_restaurants',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cached_menu_categories', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cached_menu_categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cached_menu_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CachedRestaurantsTableCreateCompanionBuilder =
    CachedRestaurantsCompanion Function({
      required String id,
      Value<String?> ownerId,
      required String name,
      Value<String?> description,
      Value<String?> logoUrl,
      Value<String?> bannerUrl,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> website,
      Value<String> status,
      Value<double> rating,
      Value<String> priceRange,
      Value<double> minOrderAmount,
      Value<double> taxPercent,
      Value<String?> locationAddress,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });
typedef $$CachedRestaurantsTableUpdateCompanionBuilder =
    CachedRestaurantsCompanion Function({
      Value<String> id,
      Value<String?> ownerId,
      Value<String> name,
      Value<String?> description,
      Value<String?> logoUrl,
      Value<String?> bannerUrl,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> website,
      Value<String> status,
      Value<double> rating,
      Value<String> priceRange,
      Value<double> minOrderAmount,
      Value<double> taxPercent,
      Value<String?> locationAddress,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });

final class $$CachedRestaurantsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CachedRestaurantsTable,
          CachedRestaurant
        > {
  $$CachedRestaurantsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $CachedMenuCategoriesTable,
    List<CachedMenuCategory>
  >
  _cachedMenuCategoriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cachedMenuCategories,
        aliasName: $_aliasNameGenerator(
          db.cachedRestaurants.id,
          db.cachedMenuCategories.restaurantId,
        ),
      );

  $$CachedMenuCategoriesTableProcessedTableManager
  get cachedMenuCategoriesRefs {
    final manager = $$CachedMenuCategoriesTableTableManager(
      $_db,
      $_db.cachedMenuCategories,
    ).filter((f) => f.restaurantId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cachedMenuCategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CachedRestaurantsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedRestaurantsTable> {
  $$CachedRestaurantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bannerUrl => $composableBuilder(
    column: $table.bannerUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priceRange => $composableBuilder(
    column: $table.priceRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minOrderAmount => $composableBuilder(
    column: $table.minOrderAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxPercent => $composableBuilder(
    column: $table.taxPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cachedMenuCategoriesRefs(
    Expression<bool> Function($$CachedMenuCategoriesTableFilterComposer f) f,
  ) {
    final $$CachedMenuCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cachedMenuCategories,
      getReferencedColumn: (t) => t.restaurantId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedMenuCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.cachedMenuCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CachedRestaurantsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedRestaurantsTable> {
  $$CachedRestaurantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoUrl => $composableBuilder(
    column: $table.logoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bannerUrl => $composableBuilder(
    column: $table.bannerUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priceRange => $composableBuilder(
    column: $table.priceRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minOrderAmount => $composableBuilder(
    column: $table.minOrderAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxPercent => $composableBuilder(
    column: $table.taxPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedRestaurantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedRestaurantsTable> {
  $$CachedRestaurantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<String> get bannerUrl =>
      $composableBuilder(column: $table.bannerUrl, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get priceRange => $composableBuilder(
    column: $table.priceRange,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minOrderAmount => $composableBuilder(
    column: $table.minOrderAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxPercent => $composableBuilder(
    column: $table.taxPercent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationAddress => $composableBuilder(
    column: $table.locationAddress,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  Expression<T> cachedMenuCategoriesRefs<T extends Object>(
    Expression<T> Function($$CachedMenuCategoriesTableAnnotationComposer a) f,
  ) {
    final $$CachedMenuCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cachedMenuCategories,
          getReferencedColumn: (t) => t.restaurantId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CachedMenuCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.cachedMenuCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CachedRestaurantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedRestaurantsTable,
          CachedRestaurant,
          $$CachedRestaurantsTableFilterComposer,
          $$CachedRestaurantsTableOrderingComposer,
          $$CachedRestaurantsTableAnnotationComposer,
          $$CachedRestaurantsTableCreateCompanionBuilder,
          $$CachedRestaurantsTableUpdateCompanionBuilder,
          (CachedRestaurant, $$CachedRestaurantsTableReferences),
          CachedRestaurant,
          PrefetchHooks Function({bool cachedMenuCategoriesRefs})
        > {
  $$CachedRestaurantsTableTableManager(
    _$AppDatabase db,
    $CachedRestaurantsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedRestaurantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedRestaurantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedRestaurantsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> bannerUrl = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> rating = const Value.absent(),
                Value<String> priceRange = const Value.absent(),
                Value<double> minOrderAmount = const Value.absent(),
                Value<double> taxPercent = const Value.absent(),
                Value<String?> locationAddress = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRestaurantsCompanion(
                id: id,
                ownerId: ownerId,
                name: name,
                description: description,
                logoUrl: logoUrl,
                bannerUrl: bannerUrl,
                phone: phone,
                email: email,
                website: website,
                status: status,
                rating: rating,
                priceRange: priceRange,
                minOrderAmount: minOrderAmount,
                taxPercent: taxPercent,
                locationAddress: locationAddress,
                latitude: latitude,
                longitude: longitude,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ownerId = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> logoUrl = const Value.absent(),
                Value<String?> bannerUrl = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> website = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> rating = const Value.absent(),
                Value<String> priceRange = const Value.absent(),
                Value<double> minOrderAmount = const Value.absent(),
                Value<double> taxPercent = const Value.absent(),
                Value<String?> locationAddress = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedRestaurantsCompanion.insert(
                id: id,
                ownerId: ownerId,
                name: name,
                description: description,
                logoUrl: logoUrl,
                bannerUrl: bannerUrl,
                phone: phone,
                email: email,
                website: website,
                status: status,
                rating: rating,
                priceRange: priceRange,
                minOrderAmount: minOrderAmount,
                taxPercent: taxPercent,
                locationAddress: locationAddress,
                latitude: latitude,
                longitude: longitude,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CachedRestaurantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cachedMenuCategoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cachedMenuCategoriesRefs) db.cachedMenuCategories,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cachedMenuCategoriesRefs)
                    await $_getPrefetchedData<
                      CachedRestaurant,
                      $CachedRestaurantsTable,
                      CachedMenuCategory
                    >(
                      currentTable: table,
                      referencedTable: $$CachedRestaurantsTableReferences
                          ._cachedMenuCategoriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CachedRestaurantsTableReferences(
                            db,
                            table,
                            p0,
                          ).cachedMenuCategoriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.restaurantId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CachedRestaurantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedRestaurantsTable,
      CachedRestaurant,
      $$CachedRestaurantsTableFilterComposer,
      $$CachedRestaurantsTableOrderingComposer,
      $$CachedRestaurantsTableAnnotationComposer,
      $$CachedRestaurantsTableCreateCompanionBuilder,
      $$CachedRestaurantsTableUpdateCompanionBuilder,
      (CachedRestaurant, $$CachedRestaurantsTableReferences),
      CachedRestaurant,
      PrefetchHooks Function({bool cachedMenuCategoriesRefs})
    >;
typedef $$CachedMenuCategoriesTableCreateCompanionBuilder =
    CachedMenuCategoriesCompanion Function({
      required String id,
      required String restaurantId,
      required String name,
      Value<int> priority,
      Value<int> rowid,
    });
typedef $$CachedMenuCategoriesTableUpdateCompanionBuilder =
    CachedMenuCategoriesCompanion Function({
      Value<String> id,
      Value<String> restaurantId,
      Value<String> name,
      Value<int> priority,
      Value<int> rowid,
    });

final class $$CachedMenuCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CachedMenuCategoriesTable,
          CachedMenuCategory
        > {
  $$CachedMenuCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CachedRestaurantsTable _restaurantIdTable(_$AppDatabase db) =>
      db.cachedRestaurants.createAlias(
        $_aliasNameGenerator(
          db.cachedMenuCategories.restaurantId,
          db.cachedRestaurants.id,
        ),
      );

  $$CachedRestaurantsTableProcessedTableManager get restaurantId {
    final $_column = $_itemColumn<String>('restaurant_id')!;

    final manager = $$CachedRestaurantsTableTableManager(
      $_db,
      $_db.cachedRestaurants,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_restaurantIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CachedMenuItemsTable, List<CachedMenuItem>>
  _cachedMenuItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cachedMenuItems,
    aliasName: $_aliasNameGenerator(
      db.cachedMenuCategories.id,
      db.cachedMenuItems.categoryId,
    ),
  );

  $$CachedMenuItemsTableProcessedTableManager get cachedMenuItemsRefs {
    final manager = $$CachedMenuItemsTableTableManager(
      $_db,
      $_db.cachedMenuItems,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cachedMenuItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CachedMenuCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedMenuCategoriesTable> {
  $$CachedMenuCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  $$CachedRestaurantsTableFilterComposer get restaurantId {
    final $$CachedRestaurantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restaurantId,
      referencedTable: $db.cachedRestaurants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedRestaurantsTableFilterComposer(
            $db: $db,
            $table: $db.cachedRestaurants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cachedMenuItemsRefs(
    Expression<bool> Function($$CachedMenuItemsTableFilterComposer f) f,
  ) {
    final $$CachedMenuItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cachedMenuItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedMenuItemsTableFilterComposer(
            $db: $db,
            $table: $db.cachedMenuItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CachedMenuCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedMenuCategoriesTable> {
  $$CachedMenuCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  $$CachedRestaurantsTableOrderingComposer get restaurantId {
    final $$CachedRestaurantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.restaurantId,
      referencedTable: $db.cachedRestaurants,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedRestaurantsTableOrderingComposer(
            $db: $db,
            $table: $db.cachedRestaurants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CachedMenuCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedMenuCategoriesTable> {
  $$CachedMenuCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  $$CachedRestaurantsTableAnnotationComposer get restaurantId {
    final $$CachedRestaurantsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.restaurantId,
          referencedTable: $db.cachedRestaurants,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CachedRestaurantsTableAnnotationComposer(
                $db: $db,
                $table: $db.cachedRestaurants,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> cachedMenuItemsRefs<T extends Object>(
    Expression<T> Function($$CachedMenuItemsTableAnnotationComposer a) f,
  ) {
    final $$CachedMenuItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cachedMenuItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedMenuItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedMenuItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CachedMenuCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedMenuCategoriesTable,
          CachedMenuCategory,
          $$CachedMenuCategoriesTableFilterComposer,
          $$CachedMenuCategoriesTableOrderingComposer,
          $$CachedMenuCategoriesTableAnnotationComposer,
          $$CachedMenuCategoriesTableCreateCompanionBuilder,
          $$CachedMenuCategoriesTableUpdateCompanionBuilder,
          (CachedMenuCategory, $$CachedMenuCategoriesTableReferences),
          CachedMenuCategory,
          PrefetchHooks Function({bool restaurantId, bool cachedMenuItemsRefs})
        > {
  $$CachedMenuCategoriesTableTableManager(
    _$AppDatabase db,
    $CachedMenuCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMenuCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMenuCategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedMenuCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restaurantId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMenuCategoriesCompanion(
                id: id,
                restaurantId: restaurantId,
                name: name,
                priority: priority,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restaurantId,
                required String name,
                Value<int> priority = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMenuCategoriesCompanion.insert(
                id: id,
                restaurantId: restaurantId,
                name: name,
                priority: priority,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CachedMenuCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({restaurantId = false, cachedMenuItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cachedMenuItemsRefs) db.cachedMenuItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (restaurantId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.restaurantId,
                                    referencedTable:
                                        $$CachedMenuCategoriesTableReferences
                                            ._restaurantIdTable(db),
                                    referencedColumn:
                                        $$CachedMenuCategoriesTableReferences
                                            ._restaurantIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cachedMenuItemsRefs)
                        await $_getPrefetchedData<
                          CachedMenuCategory,
                          $CachedMenuCategoriesTable,
                          CachedMenuItem
                        >(
                          currentTable: table,
                          referencedTable: $$CachedMenuCategoriesTableReferences
                              ._cachedMenuItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CachedMenuCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).cachedMenuItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CachedMenuCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedMenuCategoriesTable,
      CachedMenuCategory,
      $$CachedMenuCategoriesTableFilterComposer,
      $$CachedMenuCategoriesTableOrderingComposer,
      $$CachedMenuCategoriesTableAnnotationComposer,
      $$CachedMenuCategoriesTableCreateCompanionBuilder,
      $$CachedMenuCategoriesTableUpdateCompanionBuilder,
      (CachedMenuCategory, $$CachedMenuCategoriesTableReferences),
      CachedMenuCategory,
      PrefetchHooks Function({bool restaurantId, bool cachedMenuItemsRefs})
    >;
typedef $$CachedMenuItemsTableCreateCompanionBuilder =
    CachedMenuItemsCompanion Function({
      required String id,
      required String categoryId,
      required String name,
      Value<String?> description,
      required double price,
      Value<String?> imageUrl,
      Value<bool> isAvailable,
      Value<int?> calories,
      Value<double?> rating,
      Value<List<String>> dietaryFlags,
      Value<int> rowid,
    });
typedef $$CachedMenuItemsTableUpdateCompanionBuilder =
    CachedMenuItemsCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<String> name,
      Value<String?> description,
      Value<double> price,
      Value<String?> imageUrl,
      Value<bool> isAvailable,
      Value<int?> calories,
      Value<double?> rating,
      Value<List<String>> dietaryFlags,
      Value<int> rowid,
    });

final class $$CachedMenuItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CachedMenuItemsTable, CachedMenuItem> {
  $$CachedMenuItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CachedMenuCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.cachedMenuCategories.createAlias(
        $_aliasNameGenerator(
          db.cachedMenuItems.categoryId,
          db.cachedMenuCategories.id,
        ),
      );

  $$CachedMenuCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CachedMenuCategoriesTableTableManager(
      $_db,
      $_db.cachedMenuCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CachedMenuItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedMenuItemsTable> {
  $$CachedMenuItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get dietaryFlags => $composableBuilder(
    column: $table.dietaryFlags,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$CachedMenuCategoriesTableFilterComposer get categoryId {
    final $$CachedMenuCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.cachedMenuCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedMenuCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.cachedMenuCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CachedMenuItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedMenuItemsTable> {
  $$CachedMenuItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dietaryFlags => $composableBuilder(
    column: $table.dietaryFlags,
    builder: (column) => ColumnOrderings(column),
  );

  $$CachedMenuCategoriesTableOrderingComposer get categoryId {
    final $$CachedMenuCategoriesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.cachedMenuCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CachedMenuCategoriesTableOrderingComposer(
                $db: $db,
                $table: $db.cachedMenuCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CachedMenuItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedMenuItemsTable> {
  $$CachedMenuItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<bool> get isAvailable => $composableBuilder(
    column: $table.isAvailable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get dietaryFlags =>
      $composableBuilder(
        column: $table.dietaryFlags,
        builder: (column) => column,
      );

  $$CachedMenuCategoriesTableAnnotationComposer get categoryId {
    final $$CachedMenuCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.cachedMenuCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CachedMenuCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.cachedMenuCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CachedMenuItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedMenuItemsTable,
          CachedMenuItem,
          $$CachedMenuItemsTableFilterComposer,
          $$CachedMenuItemsTableOrderingComposer,
          $$CachedMenuItemsTableAnnotationComposer,
          $$CachedMenuItemsTableCreateCompanionBuilder,
          $$CachedMenuItemsTableUpdateCompanionBuilder,
          (CachedMenuItem, $$CachedMenuItemsTableReferences),
          CachedMenuItem,
          PrefetchHooks Function({bool categoryId})
        > {
  $$CachedMenuItemsTableTableManager(
    _$AppDatabase db,
    $CachedMenuItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMenuItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMenuItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedMenuItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<bool> isAvailable = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<List<String>> dietaryFlags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMenuItemsCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                description: description,
                price: price,
                imageUrl: imageUrl,
                isAvailable: isAvailable,
                calories: calories,
                rating: rating,
                dietaryFlags: dietaryFlags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required String name,
                Value<String?> description = const Value.absent(),
                required double price,
                Value<String?> imageUrl = const Value.absent(),
                Value<bool> isAvailable = const Value.absent(),
                Value<int?> calories = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<List<String>> dietaryFlags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedMenuItemsCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                description: description,
                price: price,
                imageUrl: imageUrl,
                isAvailable: isAvailable,
                calories: calories,
                rating: rating,
                dietaryFlags: dietaryFlags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CachedMenuItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$CachedMenuItemsTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$CachedMenuItemsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CachedMenuItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedMenuItemsTable,
      CachedMenuItem,
      $$CachedMenuItemsTableFilterComposer,
      $$CachedMenuItemsTableOrderingComposer,
      $$CachedMenuItemsTableAnnotationComposer,
      $$CachedMenuItemsTableCreateCompanionBuilder,
      $$CachedMenuItemsTableUpdateCompanionBuilder,
      (CachedMenuItem, $$CachedMenuItemsTableReferences),
      CachedMenuItem,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$CachedUserAddressesTableCreateCompanionBuilder =
    CachedUserAddressesCompanion Function({
      required String id,
      Value<String> label,
      required String addressLine1,
      Value<String?> addressLine2,
      required String city,
      Value<String?> state,
      Value<String?> postalCode,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<bool> isDefault,
      Value<int> rowid,
    });
typedef $$CachedUserAddressesTableUpdateCompanionBuilder =
    CachedUserAddressesCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String> addressLine1,
      Value<String?> addressLine2,
      Value<String> city,
      Value<String?> state,
      Value<String?> postalCode,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<bool> isDefault,
      Value<int> rowid,
    });

class $$CachedUserAddressesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedUserAddressesTable> {
  $$CachedUserAddressesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedUserAddressesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedUserAddressesTable> {
  $$CachedUserAddressesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedUserAddressesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedUserAddressesTable> {
  $$CachedUserAddressesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);
}

class $$CachedUserAddressesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedUserAddressesTable,
          CachedUserAddressesData,
          $$CachedUserAddressesTableFilterComposer,
          $$CachedUserAddressesTableOrderingComposer,
          $$CachedUserAddressesTableAnnotationComposer,
          $$CachedUserAddressesTableCreateCompanionBuilder,
          $$CachedUserAddressesTableUpdateCompanionBuilder,
          (
            CachedUserAddressesData,
            BaseReferences<
              _$AppDatabase,
              $CachedUserAddressesTable,
              CachedUserAddressesData
            >,
          ),
          CachedUserAddressesData,
          PrefetchHooks Function()
        > {
  $$CachedUserAddressesTableTableManager(
    _$AppDatabase db,
    $CachedUserAddressesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedUserAddressesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedUserAddressesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedUserAddressesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> addressLine1 = const Value.absent(),
                Value<String?> addressLine2 = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> postalCode = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedUserAddressesCompanion(
                id: id,
                label: label,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                city: city,
                state: state,
                postalCode: postalCode,
                latitude: latitude,
                longitude: longitude,
                isDefault: isDefault,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> label = const Value.absent(),
                required String addressLine1,
                Value<String?> addressLine2 = const Value.absent(),
                required String city,
                Value<String?> state = const Value.absent(),
                Value<String?> postalCode = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedUserAddressesCompanion.insert(
                id: id,
                label: label,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                city: city,
                state: state,
                postalCode: postalCode,
                latitude: latitude,
                longitude: longitude,
                isDefault: isDefault,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedUserAddressesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedUserAddressesTable,
      CachedUserAddressesData,
      $$CachedUserAddressesTableFilterComposer,
      $$CachedUserAddressesTableOrderingComposer,
      $$CachedUserAddressesTableAnnotationComposer,
      $$CachedUserAddressesTableCreateCompanionBuilder,
      $$CachedUserAddressesTableUpdateCompanionBuilder,
      (
        CachedUserAddressesData,
        BaseReferences<
          _$AppDatabase,
          $CachedUserAddressesTable,
          CachedUserAddressesData
        >,
      ),
      CachedUserAddressesData,
      PrefetchHooks Function()
    >;
typedef $$CachedOrdersTableCreateCompanionBuilder =
    CachedOrdersCompanion Function({
      required String id,
      required String restaurantId,
      required String status,
      required String paymentStatus,
      required double subtotal,
      required double deliveryFee,
      required double taxAmount,
      required double discountAmount,
      required double totalAmount,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CachedOrdersTableUpdateCompanionBuilder =
    CachedOrdersCompanion Function({
      Value<String> id,
      Value<String> restaurantId,
      Value<String> status,
      Value<String> paymentStatus,
      Value<double> subtotal,
      Value<double> deliveryFee,
      Value<double> taxAmount,
      Value<double> discountAmount,
      Value<double> totalAmount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CachedOrdersTableReferences
    extends BaseReferences<_$AppDatabase, $CachedOrdersTable, CachedOrder> {
  $$CachedOrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CachedOrderItemsTable, List<CachedOrderItem>>
  _cachedOrderItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cachedOrderItems,
    aliasName: $_aliasNameGenerator(
      db.cachedOrders.id,
      db.cachedOrderItems.orderId,
    ),
  );

  $$CachedOrderItemsTableProcessedTableManager get cachedOrderItemsRefs {
    final manager = $$CachedOrderItemsTableTableManager(
      $_db,
      $_db.cachedOrderItems,
    ).filter((f) => f.orderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cachedOrderItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CachedOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedOrdersTable> {
  $$CachedOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get deliveryFee => $composableBuilder(
    column: $table.deliveryFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cachedOrderItemsRefs(
    Expression<bool> Function($$CachedOrderItemsTableFilterComposer f) f,
  ) {
    final $$CachedOrderItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cachedOrderItems,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedOrderItemsTableFilterComposer(
            $db: $db,
            $table: $db.cachedOrderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CachedOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedOrdersTable> {
  $$CachedOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get deliveryFee => $composableBuilder(
    column: $table.deliveryFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxAmount => $composableBuilder(
    column: $table.taxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedOrdersTable> {
  $$CachedOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get deliveryFee => $composableBuilder(
    column: $table.deliveryFee,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxAmount =>
      $composableBuilder(column: $table.taxAmount, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> cachedOrderItemsRefs<T extends Object>(
    Expression<T> Function($$CachedOrderItemsTableAnnotationComposer a) f,
  ) {
    final $$CachedOrderItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cachedOrderItems,
      getReferencedColumn: (t) => t.orderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedOrderItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedOrderItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CachedOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedOrdersTable,
          CachedOrder,
          $$CachedOrdersTableFilterComposer,
          $$CachedOrdersTableOrderingComposer,
          $$CachedOrdersTableAnnotationComposer,
          $$CachedOrdersTableCreateCompanionBuilder,
          $$CachedOrdersTableUpdateCompanionBuilder,
          (CachedOrder, $$CachedOrdersTableReferences),
          CachedOrder,
          PrefetchHooks Function({bool cachedOrderItemsRefs})
        > {
  $$CachedOrdersTableTableManager(_$AppDatabase db, $CachedOrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> restaurantId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> deliveryFee = const Value.absent(),
                Value<double> taxAmount = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedOrdersCompanion(
                id: id,
                restaurantId: restaurantId,
                status: status,
                paymentStatus: paymentStatus,
                subtotal: subtotal,
                deliveryFee: deliveryFee,
                taxAmount: taxAmount,
                discountAmount: discountAmount,
                totalAmount: totalAmount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String restaurantId,
                required String status,
                required String paymentStatus,
                required double subtotal,
                required double deliveryFee,
                required double taxAmount,
                required double discountAmount,
                required double totalAmount,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedOrdersCompanion.insert(
                id: id,
                restaurantId: restaurantId,
                status: status,
                paymentStatus: paymentStatus,
                subtotal: subtotal,
                deliveryFee: deliveryFee,
                taxAmount: taxAmount,
                discountAmount: discountAmount,
                totalAmount: totalAmount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CachedOrdersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cachedOrderItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cachedOrderItemsRefs) db.cachedOrderItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cachedOrderItemsRefs)
                    await $_getPrefetchedData<
                      CachedOrder,
                      $CachedOrdersTable,
                      CachedOrderItem
                    >(
                      currentTable: table,
                      referencedTable: $$CachedOrdersTableReferences
                          ._cachedOrderItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CachedOrdersTableReferences(
                            db,
                            table,
                            p0,
                          ).cachedOrderItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.orderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CachedOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedOrdersTable,
      CachedOrder,
      $$CachedOrdersTableFilterComposer,
      $$CachedOrdersTableOrderingComposer,
      $$CachedOrdersTableAnnotationComposer,
      $$CachedOrdersTableCreateCompanionBuilder,
      $$CachedOrdersTableUpdateCompanionBuilder,
      (CachedOrder, $$CachedOrdersTableReferences),
      CachedOrder,
      PrefetchHooks Function({bool cachedOrderItemsRefs})
    >;
typedef $$CachedOrderItemsTableCreateCompanionBuilder =
    CachedOrderItemsCompanion Function({
      required String id,
      required String orderId,
      Value<String?> menuItemId,
      required String name,
      required int quantity,
      required double unitPrice,
      required double totalPrice,
      Value<int> rowid,
    });
typedef $$CachedOrderItemsTableUpdateCompanionBuilder =
    CachedOrderItemsCompanion Function({
      Value<String> id,
      Value<String> orderId,
      Value<String?> menuItemId,
      Value<String> name,
      Value<int> quantity,
      Value<double> unitPrice,
      Value<double> totalPrice,
      Value<int> rowid,
    });

final class $$CachedOrderItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CachedOrderItemsTable, CachedOrderItem> {
  $$CachedOrderItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CachedOrdersTable _orderIdTable(_$AppDatabase db) =>
      db.cachedOrders.createAlias(
        $_aliasNameGenerator(db.cachedOrderItems.orderId, db.cachedOrders.id),
      );

  $$CachedOrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<String>('order_id')!;

    final manager = $$CachedOrdersTableTableManager(
      $_db,
      $_db.cachedOrders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CachedOrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedOrderItemsTable> {
  $$CachedOrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnFilters(column),
  );

  $$CachedOrdersTableFilterComposer get orderId {
    final $$CachedOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.cachedOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedOrdersTableFilterComposer(
            $db: $db,
            $table: $db.cachedOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CachedOrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedOrderItemsTable> {
  $$CachedOrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnOrderings(column),
  );

  $$CachedOrdersTableOrderingComposer get orderId {
    final $$CachedOrdersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.cachedOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedOrdersTableOrderingComposer(
            $db: $db,
            $table: $db.cachedOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CachedOrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedOrderItemsTable> {
  $$CachedOrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => column,
  );

  $$CachedOrdersTableAnnotationComposer get orderId {
    final $$CachedOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orderId,
      referencedTable: $db.cachedOrders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CachedOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.cachedOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CachedOrderItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedOrderItemsTable,
          CachedOrderItem,
          $$CachedOrderItemsTableFilterComposer,
          $$CachedOrderItemsTableOrderingComposer,
          $$CachedOrderItemsTableAnnotationComposer,
          $$CachedOrderItemsTableCreateCompanionBuilder,
          $$CachedOrderItemsTableUpdateCompanionBuilder,
          (CachedOrderItem, $$CachedOrderItemsTableReferences),
          CachedOrderItem,
          PrefetchHooks Function({bool orderId})
        > {
  $$CachedOrderItemsTableTableManager(
    _$AppDatabase db,
    $CachedOrderItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedOrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedOrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedOrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String?> menuItemId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> totalPrice = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedOrderItemsCompanion(
                id: id,
                orderId: orderId,
                menuItemId: menuItemId,
                name: name,
                quantity: quantity,
                unitPrice: unitPrice,
                totalPrice: totalPrice,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String orderId,
                Value<String?> menuItemId = const Value.absent(),
                required String name,
                required int quantity,
                required double unitPrice,
                required double totalPrice,
                Value<int> rowid = const Value.absent(),
              }) => CachedOrderItemsCompanion.insert(
                id: id,
                orderId: orderId,
                menuItemId: menuItemId,
                name: name,
                quantity: quantity,
                unitPrice: unitPrice,
                totalPrice: totalPrice,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CachedOrderItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (orderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.orderId,
                                referencedTable:
                                    $$CachedOrderItemsTableReferences
                                        ._orderIdTable(db),
                                referencedColumn:
                                    $$CachedOrderItemsTableReferences
                                        ._orderIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CachedOrderItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedOrderItemsTable,
      CachedOrderItem,
      $$CachedOrderItemsTableFilterComposer,
      $$CachedOrderItemsTableOrderingComposer,
      $$CachedOrderItemsTableAnnotationComposer,
      $$CachedOrderItemsTableCreateCompanionBuilder,
      $$CachedOrderItemsTableUpdateCompanionBuilder,
      (CachedOrderItem, $$CachedOrderItemsTableReferences),
      CachedOrderItem,
      PrefetchHooks Function({bool orderId})
    >;
typedef $$CachedFavouritesTableCreateCompanionBuilder =
    CachedFavouritesCompanion Function({
      required String id,
      required String type,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });
typedef $$CachedFavouritesTableUpdateCompanionBuilder =
    CachedFavouritesCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

class $$CachedFavouritesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedFavouritesTable> {
  $$CachedFavouritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedFavouritesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedFavouritesTable> {
  $$CachedFavouritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedFavouritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedFavouritesTable> {
  $$CachedFavouritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$CachedFavouritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedFavouritesTable,
          CachedFavourite,
          $$CachedFavouritesTableFilterComposer,
          $$CachedFavouritesTableOrderingComposer,
          $$CachedFavouritesTableAnnotationComposer,
          $$CachedFavouritesTableCreateCompanionBuilder,
          $$CachedFavouritesTableUpdateCompanionBuilder,
          (
            CachedFavourite,
            BaseReferences<
              _$AppDatabase,
              $CachedFavouritesTable,
              CachedFavourite
            >,
          ),
          CachedFavourite,
          PrefetchHooks Function()
        > {
  $$CachedFavouritesTableTableManager(
    _$AppDatabase db,
    $CachedFavouritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedFavouritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedFavouritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedFavouritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedFavouritesCompanion(
                id: id,
                type: type,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedFavouritesCompanion.insert(
                id: id,
                type: type,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedFavouritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedFavouritesTable,
      CachedFavourite,
      $$CachedFavouritesTableFilterComposer,
      $$CachedFavouritesTableOrderingComposer,
      $$CachedFavouritesTableAnnotationComposer,
      $$CachedFavouritesTableCreateCompanionBuilder,
      $$CachedFavouritesTableUpdateCompanionBuilder,
      (
        CachedFavourite,
        BaseReferences<_$AppDatabase, $CachedFavouritesTable, CachedFavourite>,
      ),
      CachedFavourite,
      PrefetchHooks Function()
    >;
typedef $$CachedCartItemsTableCreateCompanionBuilder =
    CachedCartItemsCompanion Function({
      required String menuItemId,
      Value<String?> restaurantId,
      required String name,
      Value<String?> imageUrl,
      required double price,
      Value<int> quantity,
      Value<int> rowid,
    });
typedef $$CachedCartItemsTableUpdateCompanionBuilder =
    CachedCartItemsCompanion Function({
      Value<String> menuItemId,
      Value<String?> restaurantId,
      Value<String> name,
      Value<String?> imageUrl,
      Value<double> price,
      Value<int> quantity,
      Value<int> rowid,
    });

class $$CachedCartItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedCartItemsTable> {
  $$CachedCartItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedCartItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedCartItemsTable> {
  $$CachedCartItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedCartItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedCartItemsTable> {
  $$CachedCartItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get menuItemId => $composableBuilder(
    column: $table.menuItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get restaurantId => $composableBuilder(
    column: $table.restaurantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$CachedCartItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedCartItemsTable,
          CachedCartItem,
          $$CachedCartItemsTableFilterComposer,
          $$CachedCartItemsTableOrderingComposer,
          $$CachedCartItemsTableAnnotationComposer,
          $$CachedCartItemsTableCreateCompanionBuilder,
          $$CachedCartItemsTableUpdateCompanionBuilder,
          (
            CachedCartItem,
            BaseReferences<
              _$AppDatabase,
              $CachedCartItemsTable,
              CachedCartItem
            >,
          ),
          CachedCartItem,
          PrefetchHooks Function()
        > {
  $$CachedCartItemsTableTableManager(
    _$AppDatabase db,
    $CachedCartItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedCartItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedCartItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedCartItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> menuItemId = const Value.absent(),
                Value<String?> restaurantId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedCartItemsCompanion(
                menuItemId: menuItemId,
                restaurantId: restaurantId,
                name: name,
                imageUrl: imageUrl,
                price: price,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String menuItemId,
                Value<String?> restaurantId = const Value.absent(),
                required String name,
                Value<String?> imageUrl = const Value.absent(),
                required double price,
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedCartItemsCompanion.insert(
                menuItemId: menuItemId,
                restaurantId: restaurantId,
                name: name,
                imageUrl: imageUrl,
                price: price,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedCartItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedCartItemsTable,
      CachedCartItem,
      $$CachedCartItemsTableFilterComposer,
      $$CachedCartItemsTableOrderingComposer,
      $$CachedCartItemsTableAnnotationComposer,
      $$CachedCartItemsTableCreateCompanionBuilder,
      $$CachedCartItemsTableUpdateCompanionBuilder,
      (
        CachedCartItem,
        BaseReferences<_$AppDatabase, $CachedCartItemsTable, CachedCartItem>,
      ),
      CachedCartItem,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String tableIdentifier,
      required DateTime lastSync,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> tableIdentifier,
      Value<DateTime> lastSync,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tableIdentifier => $composableBuilder(
    column: $table.tableIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSync => $composableBuilder(
    column: $table.lastSync,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tableIdentifier => $composableBuilder(
    column: $table.tableIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSync => $composableBuilder(
    column: $table.lastSync,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tableIdentifier => $composableBuilder(
    column: $table.tableIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSync =>
      $composableBuilder(column: $table.lastSync, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataData,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataData,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
          ),
          SyncMetadataData,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tableIdentifier = const Value.absent(),
                Value<DateTime> lastSync = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                tableIdentifier: tableIdentifier,
                lastSync: lastSync,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tableIdentifier,
                required DateTime lastSync,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                tableIdentifier: tableIdentifier,
                lastSync: lastSync,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataData,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataData,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataData>,
      ),
      SyncMetadataData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedRestaurantsTableTableManager get cachedRestaurants =>
      $$CachedRestaurantsTableTableManager(_db, _db.cachedRestaurants);
  $$CachedMenuCategoriesTableTableManager get cachedMenuCategories =>
      $$CachedMenuCategoriesTableTableManager(_db, _db.cachedMenuCategories);
  $$CachedMenuItemsTableTableManager get cachedMenuItems =>
      $$CachedMenuItemsTableTableManager(_db, _db.cachedMenuItems);
  $$CachedUserAddressesTableTableManager get cachedUserAddresses =>
      $$CachedUserAddressesTableTableManager(_db, _db.cachedUserAddresses);
  $$CachedOrdersTableTableManager get cachedOrders =>
      $$CachedOrdersTableTableManager(_db, _db.cachedOrders);
  $$CachedOrderItemsTableTableManager get cachedOrderItems =>
      $$CachedOrderItemsTableTableManager(_db, _db.cachedOrderItems);
  $$CachedFavouritesTableTableManager get cachedFavourites =>
      $$CachedFavouritesTableTableManager(_db, _db.cachedFavourites);
  $$CachedCartItemsTableTableManager get cachedCartItems =>
      $$CachedCartItemsTableTableManager(_db, _db.cachedCartItems);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
}
