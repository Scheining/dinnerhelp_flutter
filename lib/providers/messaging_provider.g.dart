// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$inquiryMessagesNotifierHash() =>
    r'cdff19b1d69f132b2d1083e2e230e26048e04cf5';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$InquiryMessagesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<InquiryMessage>> {
  late final String inquiryId;

  FutureOr<List<InquiryMessage>> build(
    String inquiryId,
  );
}

/// See also [InquiryMessagesNotifier].
@ProviderFor(InquiryMessagesNotifier)
const inquiryMessagesNotifierProvider = InquiryMessagesNotifierFamily();

/// See also [InquiryMessagesNotifier].
class InquiryMessagesNotifierFamily
    extends Family<AsyncValue<List<InquiryMessage>>> {
  /// See also [InquiryMessagesNotifier].
  const InquiryMessagesNotifierFamily();

  /// See also [InquiryMessagesNotifier].
  InquiryMessagesNotifierProvider call(
    String inquiryId,
  ) {
    return InquiryMessagesNotifierProvider(
      inquiryId,
    );
  }

  @override
  InquiryMessagesNotifierProvider getProviderOverride(
    covariant InquiryMessagesNotifierProvider provider,
  ) {
    return call(
      provider.inquiryId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'inquiryMessagesNotifierProvider';
}

/// See also [InquiryMessagesNotifier].
class InquiryMessagesNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<InquiryMessagesNotifier,
        List<InquiryMessage>> {
  /// See also [InquiryMessagesNotifier].
  InquiryMessagesNotifierProvider(
    String inquiryId,
  ) : this._internal(
          () => InquiryMessagesNotifier()..inquiryId = inquiryId,
          from: inquiryMessagesNotifierProvider,
          name: r'inquiryMessagesNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$inquiryMessagesNotifierHash,
          dependencies: InquiryMessagesNotifierFamily._dependencies,
          allTransitiveDependencies:
              InquiryMessagesNotifierFamily._allTransitiveDependencies,
          inquiryId: inquiryId,
        );

  InquiryMessagesNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.inquiryId,
  }) : super.internal();

  final String inquiryId;

  @override
  FutureOr<List<InquiryMessage>> runNotifierBuild(
    covariant InquiryMessagesNotifier notifier,
  ) {
    return notifier.build(
      inquiryId,
    );
  }

  @override
  Override overrideWith(InquiryMessagesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: InquiryMessagesNotifierProvider._internal(
        () => create()..inquiryId = inquiryId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        inquiryId: inquiryId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<InquiryMessagesNotifier,
      List<InquiryMessage>> createElement() {
    return _InquiryMessagesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InquiryMessagesNotifierProvider &&
        other.inquiryId == inquiryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, inquiryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InquiryMessagesNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<InquiryMessage>> {
  /// The parameter `inquiryId` of this provider.
  String get inquiryId;
}

class _InquiryMessagesNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<InquiryMessagesNotifier,
        List<InquiryMessage>> with InquiryMessagesNotifierRef {
  _InquiryMessagesNotifierProviderElement(super.provider);

  @override
  String get inquiryId => (origin as InquiryMessagesNotifierProvider).inquiryId;
}

String _$bookingMessagesNotifierHash() =>
    r'7453e6ffe3577ad3f315711dfb183b3aed34f428';

abstract class _$BookingMessagesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Map<String, dynamic>>> {
  late final String bookingId;

  FutureOr<List<Map<String, dynamic>>> build(
    String bookingId,
  );
}

/// See also [BookingMessagesNotifier].
@ProviderFor(BookingMessagesNotifier)
const bookingMessagesNotifierProvider = BookingMessagesNotifierFamily();

/// See also [BookingMessagesNotifier].
class BookingMessagesNotifierFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [BookingMessagesNotifier].
  const BookingMessagesNotifierFamily();

  /// See also [BookingMessagesNotifier].
  BookingMessagesNotifierProvider call(
    String bookingId,
  ) {
    return BookingMessagesNotifierProvider(
      bookingId,
    );
  }

  @override
  BookingMessagesNotifierProvider getProviderOverride(
    covariant BookingMessagesNotifierProvider provider,
  ) {
    return call(
      provider.bookingId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'bookingMessagesNotifierProvider';
}

/// See also [BookingMessagesNotifier].
class BookingMessagesNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<BookingMessagesNotifier,
        List<Map<String, dynamic>>> {
  /// See also [BookingMessagesNotifier].
  BookingMessagesNotifierProvider(
    String bookingId,
  ) : this._internal(
          () => BookingMessagesNotifier()..bookingId = bookingId,
          from: bookingMessagesNotifierProvider,
          name: r'bookingMessagesNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bookingMessagesNotifierHash,
          dependencies: BookingMessagesNotifierFamily._dependencies,
          allTransitiveDependencies:
              BookingMessagesNotifierFamily._allTransitiveDependencies,
          bookingId: bookingId,
        );

  BookingMessagesNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.bookingId,
  }) : super.internal();

  final String bookingId;

  @override
  FutureOr<List<Map<String, dynamic>>> runNotifierBuild(
    covariant BookingMessagesNotifier notifier,
  ) {
    return notifier.build(
      bookingId,
    );
  }

  @override
  Override overrideWith(BookingMessagesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: BookingMessagesNotifierProvider._internal(
        () => create()..bookingId = bookingId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        bookingId: bookingId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<BookingMessagesNotifier,
      List<Map<String, dynamic>>> createElement() {
    return _BookingMessagesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingMessagesNotifierProvider &&
        other.bookingId == bookingId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, bookingId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BookingMessagesNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `bookingId` of this provider.
  String get bookingId;
}

class _BookingMessagesNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<BookingMessagesNotifier,
        List<Map<String, dynamic>>> with BookingMessagesNotifierRef {
  _BookingMessagesNotifierProviderElement(super.provider);

  @override
  String get bookingId => (origin as BookingMessagesNotifierProvider).bookingId;
}

String _$unifiedConversationsNotifierHash() =>
    r'664494626fbd03f6db554d2ed4b7a5721dd72699';

/// See also [UnifiedConversationsNotifier].
@ProviderFor(UnifiedConversationsNotifier)
final unifiedConversationsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    UnifiedConversationsNotifier, List<UnifiedConversation>>.internal(
  UnifiedConversationsNotifier.new,
  name: r'unifiedConversationsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unifiedConversationsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnifiedConversationsNotifier
    = AutoDisposeAsyncNotifier<List<UnifiedConversation>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
