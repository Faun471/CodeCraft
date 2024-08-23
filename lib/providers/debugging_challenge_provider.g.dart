// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debugging_challenge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$debuggingChallengeNotifierHash() =>
    r'bc6172454d5c705e9475b1e9a9b2b7df6744c49e';

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

abstract class _$DebuggingChallengeNotifier
    extends BuildlessAutoDisposeAsyncNotifier<DebuggingChallengeState> {
  late final String organizationId;
  late final String challengeId;

  FutureOr<DebuggingChallengeState> build(
    String organizationId,
    String challengeId,
  );
}

/// See also [DebuggingChallengeNotifier].
@ProviderFor(DebuggingChallengeNotifier)
const debuggingChallengeNotifierProvider = DebuggingChallengeNotifierFamily();

/// See also [DebuggingChallengeNotifier].
class DebuggingChallengeNotifierFamily
    extends Family<AsyncValue<DebuggingChallengeState>> {
  /// See also [DebuggingChallengeNotifier].
  const DebuggingChallengeNotifierFamily();

  /// See also [DebuggingChallengeNotifier].
  DebuggingChallengeNotifierProvider call(
    String organizationId,
    String challengeId,
  ) {
    return DebuggingChallengeNotifierProvider(
      organizationId,
      challengeId,
    );
  }

  @override
  DebuggingChallengeNotifierProvider getProviderOverride(
    covariant DebuggingChallengeNotifierProvider provider,
  ) {
    return call(
      provider.organizationId,
      provider.challengeId,
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
  String? get name => r'debuggingChallengeNotifierProvider';
}

/// See also [DebuggingChallengeNotifier].
class DebuggingChallengeNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<DebuggingChallengeNotifier,
        DebuggingChallengeState> {
  /// See also [DebuggingChallengeNotifier].
  DebuggingChallengeNotifierProvider(
    String organizationId,
    String challengeId,
  ) : this._internal(
          () => DebuggingChallengeNotifier()
            ..organizationId = organizationId
            ..challengeId = challengeId,
          from: debuggingChallengeNotifierProvider,
          name: r'debuggingChallengeNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$debuggingChallengeNotifierHash,
          dependencies: DebuggingChallengeNotifierFamily._dependencies,
          allTransitiveDependencies:
              DebuggingChallengeNotifierFamily._allTransitiveDependencies,
          organizationId: organizationId,
          challengeId: challengeId,
        );

  DebuggingChallengeNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.organizationId,
    required this.challengeId,
  }) : super.internal();

  final String organizationId;
  final String challengeId;

  @override
  FutureOr<DebuggingChallengeState> runNotifierBuild(
    covariant DebuggingChallengeNotifier notifier,
  ) {
    return notifier.build(
      organizationId,
      challengeId,
    );
  }

  @override
  Override overrideWith(DebuggingChallengeNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DebuggingChallengeNotifierProvider._internal(
        () => create()
          ..organizationId = organizationId
          ..challengeId = challengeId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        organizationId: organizationId,
        challengeId: challengeId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<DebuggingChallengeNotifier,
      DebuggingChallengeState> createElement() {
    return _DebuggingChallengeNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DebuggingChallengeNotifierProvider &&
        other.organizationId == organizationId &&
        other.challengeId == challengeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, organizationId.hashCode);
    hash = _SystemHash.combine(hash, challengeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DebuggingChallengeNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<DebuggingChallengeState> {
  /// The parameter `organizationId` of this provider.
  String get organizationId;

  /// The parameter `challengeId` of this provider.
  String get challengeId;
}

class _DebuggingChallengeNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<DebuggingChallengeNotifier,
        DebuggingChallengeState> with DebuggingChallengeNotifierRef {
  _DebuggingChallengeNotifierProviderElement(super.provider);

  @override
  String get organizationId =>
      (origin as DebuggingChallengeNotifierProvider).organizationId;
  @override
  String get challengeId =>
      (origin as DebuggingChallengeNotifierProvider).challengeId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
