// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SearchFilters {
// Date and time filters
  DateTime? get date => throw _privateConstructorUsedError;
  String? get startTime => throw _privateConstructorUsedError;
  Duration? get duration => throw _privateConstructorUsedError;
  int? get numberOfGuests => throw _privateConstructorUsedError; // Text search
  String? get searchText =>
      throw _privateConstructorUsedError; // Category filters
  List<String>? get cuisineTypes => throw _privateConstructorUsedError;
  List<String>? get dietarySpecialties =>
      throw _privateConstructorUsedError; // Price filters
  double? get minPrice => throw _privateConstructorUsedError;
  double? get maxPrice => throw _privateConstructorUsedError; // Rating filter
  double? get minRating =>
      throw _privateConstructorUsedError; // Availability filters
  bool get availableOnly => throw _privateConstructorUsedError;
  bool get verifiedOnly =>
      throw _privateConstructorUsedError; // Location filters
  String? get postalCode => throw _privateConstructorUsedError;
  double? get maxDistanceKm => throw _privateConstructorUsedError; // Sorting
  String get sortBy =>
      throw _privateConstructorUsedError; // 'rating', 'distance', 'price', 'availability'
  bool get sortAscending => throw _privateConstructorUsedError;

  /// Create a copy of SearchFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchFiltersCopyWith<SearchFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchFiltersCopyWith<$Res> {
  factory $SearchFiltersCopyWith(
          SearchFilters value, $Res Function(SearchFilters) then) =
      _$SearchFiltersCopyWithImpl<$Res, SearchFilters>;
  @useResult
  $Res call(
      {DateTime? date,
      String? startTime,
      Duration? duration,
      int? numberOfGuests,
      String? searchText,
      List<String>? cuisineTypes,
      List<String>? dietarySpecialties,
      double? minPrice,
      double? maxPrice,
      double? minRating,
      bool availableOnly,
      bool verifiedOnly,
      String? postalCode,
      double? maxDistanceKm,
      String sortBy,
      bool sortAscending});
}

/// @nodoc
class _$SearchFiltersCopyWithImpl<$Res, $Val extends SearchFilters>
    implements $SearchFiltersCopyWith<$Res> {
  _$SearchFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = freezed,
    Object? startTime = freezed,
    Object? duration = freezed,
    Object? numberOfGuests = freezed,
    Object? searchText = freezed,
    Object? cuisineTypes = freezed,
    Object? dietarySpecialties = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? minRating = freezed,
    Object? availableOnly = null,
    Object? verifiedOnly = null,
    Object? postalCode = freezed,
    Object? maxDistanceKm = freezed,
    Object? sortBy = null,
    Object? sortAscending = null,
  }) {
    return _then(_value.copyWith(
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      numberOfGuests: freezed == numberOfGuests
          ? _value.numberOfGuests
          : numberOfGuests // ignore: cast_nullable_to_non_nullable
              as int?,
      searchText: freezed == searchText
          ? _value.searchText
          : searchText // ignore: cast_nullable_to_non_nullable
              as String?,
      cuisineTypes: freezed == cuisineTypes
          ? _value.cuisineTypes
          : cuisineTypes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      dietarySpecialties: freezed == dietarySpecialties
          ? _value.dietarySpecialties
          : dietarySpecialties // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minRating: freezed == minRating
          ? _value.minRating
          : minRating // ignore: cast_nullable_to_non_nullable
              as double?,
      availableOnly: null == availableOnly
          ? _value.availableOnly
          : availableOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      verifiedOnly: null == verifiedOnly
          ? _value.verifiedOnly
          : verifiedOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      maxDistanceKm: freezed == maxDistanceKm
          ? _value.maxDistanceKm
          : maxDistanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
      sortAscending: null == sortAscending
          ? _value.sortAscending
          : sortAscending // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchFiltersImplCopyWith<$Res>
    implements $SearchFiltersCopyWith<$Res> {
  factory _$$SearchFiltersImplCopyWith(
          _$SearchFiltersImpl value, $Res Function(_$SearchFiltersImpl) then) =
      __$$SearchFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? date,
      String? startTime,
      Duration? duration,
      int? numberOfGuests,
      String? searchText,
      List<String>? cuisineTypes,
      List<String>? dietarySpecialties,
      double? minPrice,
      double? maxPrice,
      double? minRating,
      bool availableOnly,
      bool verifiedOnly,
      String? postalCode,
      double? maxDistanceKm,
      String sortBy,
      bool sortAscending});
}

/// @nodoc
class __$$SearchFiltersImplCopyWithImpl<$Res>
    extends _$SearchFiltersCopyWithImpl<$Res, _$SearchFiltersImpl>
    implements _$$SearchFiltersImplCopyWith<$Res> {
  __$$SearchFiltersImplCopyWithImpl(
      _$SearchFiltersImpl _value, $Res Function(_$SearchFiltersImpl) _then)
      : super(_value, _then);

  /// Create a copy of SearchFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = freezed,
    Object? startTime = freezed,
    Object? duration = freezed,
    Object? numberOfGuests = freezed,
    Object? searchText = freezed,
    Object? cuisineTypes = freezed,
    Object? dietarySpecialties = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? minRating = freezed,
    Object? availableOnly = null,
    Object? verifiedOnly = null,
    Object? postalCode = freezed,
    Object? maxDistanceKm = freezed,
    Object? sortBy = null,
    Object? sortAscending = null,
  }) {
    return _then(_$SearchFiltersImpl(
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration?,
      numberOfGuests: freezed == numberOfGuests
          ? _value.numberOfGuests
          : numberOfGuests // ignore: cast_nullable_to_non_nullable
              as int?,
      searchText: freezed == searchText
          ? _value.searchText
          : searchText // ignore: cast_nullable_to_non_nullable
              as String?,
      cuisineTypes: freezed == cuisineTypes
          ? _value._cuisineTypes
          : cuisineTypes // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      dietarySpecialties: freezed == dietarySpecialties
          ? _value._dietarySpecialties
          : dietarySpecialties // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minRating: freezed == minRating
          ? _value.minRating
          : minRating // ignore: cast_nullable_to_non_nullable
              as double?,
      availableOnly: null == availableOnly
          ? _value.availableOnly
          : availableOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      verifiedOnly: null == verifiedOnly
          ? _value.verifiedOnly
          : verifiedOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      maxDistanceKm: freezed == maxDistanceKm
          ? _value.maxDistanceKm
          : maxDistanceKm // ignore: cast_nullable_to_non_nullable
              as double?,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
      sortAscending: null == sortAscending
          ? _value.sortAscending
          : sortAscending // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SearchFiltersImpl extends _SearchFilters {
  const _$SearchFiltersImpl(
      {this.date,
      this.startTime,
      this.duration,
      this.numberOfGuests,
      this.searchText,
      final List<String>? cuisineTypes,
      final List<String>? dietarySpecialties,
      this.minPrice,
      this.maxPrice,
      this.minRating,
      this.availableOnly = false,
      this.verifiedOnly = false,
      this.postalCode,
      this.maxDistanceKm,
      this.sortBy = 'rating',
      this.sortAscending = false})
      : _cuisineTypes = cuisineTypes,
        _dietarySpecialties = dietarySpecialties,
        super._();

// Date and time filters
  @override
  final DateTime? date;
  @override
  final String? startTime;
  @override
  final Duration? duration;
  @override
  final int? numberOfGuests;
// Text search
  @override
  final String? searchText;
// Category filters
  final List<String>? _cuisineTypes;
// Category filters
  @override
  List<String>? get cuisineTypes {
    final value = _cuisineTypes;
    if (value == null) return null;
    if (_cuisineTypes is EqualUnmodifiableListView) return _cuisineTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _dietarySpecialties;
  @override
  List<String>? get dietarySpecialties {
    final value = _dietarySpecialties;
    if (value == null) return null;
    if (_dietarySpecialties is EqualUnmodifiableListView)
      return _dietarySpecialties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// Price filters
  @override
  final double? minPrice;
  @override
  final double? maxPrice;
// Rating filter
  @override
  final double? minRating;
// Availability filters
  @override
  @JsonKey()
  final bool availableOnly;
  @override
  @JsonKey()
  final bool verifiedOnly;
// Location filters
  @override
  final String? postalCode;
  @override
  final double? maxDistanceKm;
// Sorting
  @override
  @JsonKey()
  final String sortBy;
// 'rating', 'distance', 'price', 'availability'
  @override
  @JsonKey()
  final bool sortAscending;

  @override
  String toString() {
    return 'SearchFilters(date: $date, startTime: $startTime, duration: $duration, numberOfGuests: $numberOfGuests, searchText: $searchText, cuisineTypes: $cuisineTypes, dietarySpecialties: $dietarySpecialties, minPrice: $minPrice, maxPrice: $maxPrice, minRating: $minRating, availableOnly: $availableOnly, verifiedOnly: $verifiedOnly, postalCode: $postalCode, maxDistanceKm: $maxDistanceKm, sortBy: $sortBy, sortAscending: $sortAscending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchFiltersImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.numberOfGuests, numberOfGuests) ||
                other.numberOfGuests == numberOfGuests) &&
            (identical(other.searchText, searchText) ||
                other.searchText == searchText) &&
            const DeepCollectionEquality()
                .equals(other._cuisineTypes, _cuisineTypes) &&
            const DeepCollectionEquality()
                .equals(other._dietarySpecialties, _dietarySpecialties) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.minRating, minRating) ||
                other.minRating == minRating) &&
            (identical(other.availableOnly, availableOnly) ||
                other.availableOnly == availableOnly) &&
            (identical(other.verifiedOnly, verifiedOnly) ||
                other.verifiedOnly == verifiedOnly) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.maxDistanceKm, maxDistanceKm) ||
                other.maxDistanceKm == maxDistanceKm) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.sortAscending, sortAscending) ||
                other.sortAscending == sortAscending));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      startTime,
      duration,
      numberOfGuests,
      searchText,
      const DeepCollectionEquality().hash(_cuisineTypes),
      const DeepCollectionEquality().hash(_dietarySpecialties),
      minPrice,
      maxPrice,
      minRating,
      availableOnly,
      verifiedOnly,
      postalCode,
      maxDistanceKm,
      sortBy,
      sortAscending);

  /// Create a copy of SearchFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchFiltersImplCopyWith<_$SearchFiltersImpl> get copyWith =>
      __$$SearchFiltersImplCopyWithImpl<_$SearchFiltersImpl>(this, _$identity);
}

abstract class _SearchFilters extends SearchFilters {
  const factory _SearchFilters(
      {final DateTime? date,
      final String? startTime,
      final Duration? duration,
      final int? numberOfGuests,
      final String? searchText,
      final List<String>? cuisineTypes,
      final List<String>? dietarySpecialties,
      final double? minPrice,
      final double? maxPrice,
      final double? minRating,
      final bool availableOnly,
      final bool verifiedOnly,
      final String? postalCode,
      final double? maxDistanceKm,
      final String sortBy,
      final bool sortAscending}) = _$SearchFiltersImpl;
  const _SearchFilters._() : super._();

// Date and time filters
  @override
  DateTime? get date;
  @override
  String? get startTime;
  @override
  Duration? get duration;
  @override
  int? get numberOfGuests; // Text search
  @override
  String? get searchText; // Category filters
  @override
  List<String>? get cuisineTypes;
  @override
  List<String>? get dietarySpecialties; // Price filters
  @override
  double? get minPrice;
  @override
  double? get maxPrice; // Rating filter
  @override
  double? get minRating; // Availability filters
  @override
  bool get availableOnly;
  @override
  bool get verifiedOnly; // Location filters
  @override
  String? get postalCode;
  @override
  double? get maxDistanceKm; // Sorting
  @override
  String get sortBy; // 'rating', 'distance', 'price', 'availability'
  @override
  bool get sortAscending;

  /// Create a copy of SearchFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchFiltersImplCopyWith<_$SearchFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
