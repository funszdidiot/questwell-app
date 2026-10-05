import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/questwell_cosmetic_models.dart';
import '../widgets/questwell_pixel_art.dart';

class QuestwellSeasonalGalleryReviewApp extends StatelessWidget {
  const QuestwellSeasonalGalleryReviewApp({
    super.key,
    this.manifestAsset = 'assets/jsons/seasonal_review_fixture.json',
    this.initialSlug,
  });

  final String manifestAsset;
  final String? initialSlug;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Questwell Seasonal Review',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF9F8157),
          scaffoldBackgroundColor: const Color(0xFF15100F),
        ),
        home: _SeasonalGalleryScreen(
          manifestAsset: manifestAsset,
          initialSlug: initialSlug,
        ),
      );
}

Map<String, dynamic> _jsonMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

class _SeasonalReleaseManifest {
  const _SeasonalReleaseManifest({
    required this.releaseId,
    required this.displayName,
    required this.releaseType,
    required this.collectionKey,
    required this.availabilityStatus,
    required this.visualStatus,
    required this.economyStatus,
    required this.activationStatus,
    required this.items,
  });

  final String releaseId;
  final String displayName;
  final String releaseType;
  final String collectionKey;
  final String availabilityStatus;
  final String visualStatus;
  final String economyStatus;
  final String activationStatus;
  final List<_SeasonalReleaseItem> items;

  factory _SeasonalReleaseManifest.fromJson(Map<String, dynamic> json) {
    final availability = _jsonMap(json['availability']);
    final approval = _jsonMap(json['approval']);
    final rawItems = json['items'] is List ? json['items'] as List : const [];
    return _SeasonalReleaseManifest(
      releaseId: json['release_id']?.toString() ?? 'release',
      displayName: json['display_name']?.toString() ?? 'Seasonal Review',
      releaseType: json['release_type']?.toString() ?? 'seasonal',
      collectionKey: json['collection_key']?.toString() ?? '',
      availabilityStatus: availability['status']?.toString() ?? 'planned',
      visualStatus: approval['visual_status']?.toString() ?? 'candidate',
      economyStatus: approval['economy_status']?.toString() ?? 'pending',
      activationStatus:
          approval['activation_status']?.toString() ?? 'not_authorized',
      items: rawItems
          .whereType<Map>()
          .map((raw) => _SeasonalReleaseItem.fromJson(
                Map<String, dynamic>.from(raw),
              ))
          .toList(growable: false),
    );
  }

  static Future<_SeasonalReleaseManifest> load(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return _SeasonalReleaseManifest.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }
}

class _SeasonalWearableSpec {
  const _SeasonalWearableSpec({
    required this.templateId,
    required this.assetsByBody,
    required this.supportedBodies,
  });

  final String? templateId;
  final Map<String, String> assetsByBody;
  final Set<String> supportedBodies;

  factory _SeasonalWearableSpec.fromJson(Map<String, dynamic> json) {
    final assets = _jsonMap(json['assets_by_body']);
    final supported = json['supported_bodies'] is List
        ? (json['supported_bodies'] as List)
            .map((value) => value.toString())
            .toSet()
        : assets.keys.toSet();
    return _SeasonalWearableSpec(
      templateId: json['template_id']?.toString(),
      assetsByBody: {
        for (final entry in assets.entries)
          if (entry.value != null) entry.key: entry.value.toString(),
      },
      supportedBodies: supported,
    );
  }
}

class _SeasonalReleaseItem {
  const _SeasonalReleaseItem({
    required this.slug,
    required this.name,
    required this.category,
    required this.rarity,
    required this.description,
    required this.visualFamily,
    required this.assetState,
    required this.profileKey,
    required this.renderSpec,
    required this.wearable,
    required this.requiredArchetype,
    required this.preflight,
    required this.runtimeQa,
    required this.visualQa,
  });

  final String slug;
  final String name;
  final String category;
  final String rarity;
  final String description;
  final String visualFamily;
  final String assetState;
  final String? profileKey;
  final QuestwellHearthRenderSpec? renderSpec;
  final _SeasonalWearableSpec? wearable;
  final String? requiredArchetype;
  final String preflight;
  final String runtimeQa;
  final String visualQa;

  bool get isHearth => profileKey != null && renderSpec != null;
  bool get isWearable => wearable != null;

  factory _SeasonalReleaseItem.fromJson(Map<String, dynamic> json) {
    final hearth = _jsonMap(json['hearth']);
    final render = _jsonMap(hearth['render']);
    final wearableJson = _jsonMap(json['wearable']);
    final qa = _jsonMap(json['qa']);
    return _SeasonalReleaseItem(
      slug: json['slug']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Item',
      category: json['category']?.toString() ?? '',
      rarity: json['rarity']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      visualFamily: json['visual_family']?.toString() ?? '',
      assetState: json['asset_state']?.toString() ?? 'candidate',
      profileKey: hearth['profile_key']?.toString(),
      renderSpec:
          render.isEmpty ? null : QuestwellHearthRenderSpec.fromJson(render),
      wearable: wearableJson.isEmpty
          ? null
          : _SeasonalWearableSpec.fromJson(wearableJson),
      requiredArchetype: json['required_archetype']?.toString(),
      preflight: qa['preflight']?.toString() ?? 'not_run',
      runtimeQa: qa['runtime']?.toString() ?? 'not_run',
      visualQa: qa['visual']?.toString() ?? 'not_run',
    );
  }
}

class _SeasonalGalleryScreen extends StatefulWidget {
  const _SeasonalGalleryScreen({
    required this.manifestAsset,
    this.initialSlug,
  });
  final String manifestAsset;
  final String? initialSlug;

  @override
  State<_SeasonalGalleryScreen> createState() => _SeasonalGalleryScreenState();
}

class _SeasonalGalleryScreenState extends State<_SeasonalGalleryScreen> {
  late final Future<_SeasonalReleaseManifest> _manifest =
      _SeasonalReleaseManifest.load(widget.manifestAsset);

  String? _selectedSlug;
  String _body = 'neutral';
  String _archetype = 'scout';
  String _viewport = 'standard';
  bool _showAvatar = true;
  bool _compareBenchmark = true;
  final Map<String, String> _slotBySlug = {};

  @override
  void initState() {
    super.initState();
    _selectedSlug = widget.initialSlug;
  }

  double get _sceneWidth => switch (_viewport) {
        'compact' => 320,
        'wide' => 680,
        _ => 390,
      };

  double get _sceneHeight => switch (_viewport) {
        'compact' => 330,
        'wide' => 430,
        _ => 380,
      };

  Map<String, String> _slotOptions(String? profile) => switch (profile) {
        'large_furniture' => const {
            'left': 'Back left',
            'right': 'Back right',
          },
        'pedestal_light' => const {
            'left': 'Back left',
            'right': 'Back right',
          },
        'seating' => const {
            'front': 'Left floor',
            'right': 'Right floor',
          },
        'plant' => const {
            'left': 'Back left',
            'right': 'Back right',
            'front': 'Foreground',
          },
        'side_table' => const {'side': 'Beside the chair'},
        'floor_rug' => const {'floor': 'Floor'},
        'wall_art_side' => const {
            'wall_left': 'Left wall',
            'wall_right': 'Right wall',
          },
        'wall_art_center' => const {'wall_center': 'Center wall'},
        _ => const {},
      };

  String _defaultSlot(String? profile) => switch (profile) {
        'pedestal_light' => 'right',
        'large_furniture' => 'left',
        'seating' => 'front',
        'plant' => 'right',
        'side_table' => 'side',
        'floor_rug' => 'floor',
        'wall_art_side' => 'wall_left',
        'wall_art_center' => 'wall_center',
        _ => 'right',
      };

  String? _benchmarkSlug(String? profile) => switch (profile) {
        'pedestal_light' => 'autumn-ember-lantern',
        'large_furniture' => 'walnut-bookshelf',
        'seating' => 'burgundy-reading-chair',
        _ => null,
      };

  String? _benchmarkName(String? profile) => switch (profile) {
        'pedestal_light' => 'Autumn Ember Lantern',
        'large_furniture' => 'Walnut Bookshelf',
        'seating' => 'Burgundy Reading Chair',
        _ => null,
      };

  String _equipmentKey(String profile, String slot) => switch (profile) {
        'floor_rug' => 'room:floor',
        'wall_art_center' => 'wall_art',
        'wall_art_side' => 'wall_art:$slot',
        _ => 'room:$slot',
      };

  Map<String, String> _baseEquipment() => {
        'room:left': 'walnut-bookshelf',
        'room:front': 'burgundy-reading-chair',
        'wall_art': 'moonlit-woodland',
        'wall_art:wall_right': 'celestial-study',
      };

  Map<String, String> _equipmentFor({
    required _SeasonalReleaseItem item,
    required String slug,
    required String slot,
  }) {
    final equipment = _baseEquipment();
    final profile = item.profileKey!;
    equipment[_equipmentKey(profile, slot)] = slug;
    return equipment;
  }

  Widget _statusChip(String label, String value) => Chip(
        label: Text('$label: $value'),
        visualDensity: VisualDensity.compact,
      );

  Widget _reviewControls(_SeasonalReleaseItem item) {
    final slotOptions = _slotOptions(item.profileKey);
    final slot = _slotBySlug[item.slug] ?? _defaultSlot(item.profileKey);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 14,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Body'),
            for (final body in const ['female', 'neutral', 'male'])
              ChoiceChip(
                key: ValueKey('seasonal-body-$body'),
                label: Text(body),
                selected: _body == body,
                onSelected: (_) => setState(() => _body = body),
              ),
            const SizedBox(width: 8),
            const Text('Class'),
            DropdownButton<String>(
              value: _archetype,
              items: const [
                'scholar',
                'scout',
                'alchemist',
                'guardian',
                'wanderer'
              ]
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _archetype = value);
              },
            ),
            FilterChip(
              label: const Text('Show avatar/body'),
              selected: _showAvatar,
              onSelected: (value) => setState(() => _showAvatar = value),
            ),
            FilterChip(
              label: const Text('Compare benchmark'),
              selected: _compareBenchmark,
              onSelected: (value) =>
                  setState(() => _compareBenchmark = value),
            ),
            const Text('Viewport'),
            for (final viewport in const ['compact', 'standard', 'wide'])
              ChoiceChip(
                label: Text(viewport),
                selected: _viewport == viewport,
                onSelected: (_) => setState(() => _viewport = viewport),
              ),
            if (slotOptions.isNotEmpty) ...[
              const SizedBox(width: 8),
              const Text('Placement'),
              for (final entry in slotOptions.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: slot == entry.key,
                  onSelected: (_) => setState(
                    () => _slotBySlug[item.slug] = entry.key,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _itemSelector(
    _SeasonalReleaseManifest manifest,
    _SeasonalReleaseItem selected,
  ) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in manifest.items)
                ChoiceChip(
                  key: ValueKey('seasonal-item-${item.slug}'),
                  label: Text(item.name),
                  selected: item.slug == selected.slug,
                  onSelected: (_) => setState(() {
                    _selectedSlug = item.slug;
                    if (item.requiredArchetype != null) {
                      _archetype = item.requiredArchetype!;
                    }
                  }),
                ),
            ],
          ),
        ),
      );

  Widget _itemMetadata(
    _SeasonalReleaseManifest manifest,
    _SeasonalReleaseItem item,
  ) =>
      Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(item.description),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _statusChip('family', item.visualFamily),
                  _statusChip('asset', item.assetState),
                  _statusChip('rarity', item.rarity),
                  if (item.profileKey != null)
                    _statusChip('Hearth profile', item.profileKey!),
                  if (item.renderSpec != null)
                    _statusChip('render', item.renderSpec!.renderKind),
                  if (item.wearable?.templateId != null)
                    _statusChip('template', item.wearable!.templateId!),
                  _statusChip('preflight', item.preflight),
                  _statusChip('runtime QA', item.runtimeQa),
                  _statusChip('visual QA', item.visualQa),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Release ${manifest.releaseId} • ${manifest.releaseType} • '
                '${manifest.availabilityStatus} • visual ${manifest.visualStatus} • '
                'economy ${manifest.economyStatus} • activation ${manifest.activationStatus}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );

  Widget _hearthPanel({
    required String title,
    required _SeasonalReleaseItem item,
    required String slug,
    QuestwellHearthRenderSpec? renderSpec,
    String? profileKey,
  }) {
    final slot = _slotBySlug[item.slug] ?? _defaultSlot(item.profileKey);
    final equipment = _equipmentFor(item: item, slug: slug, slot: slot);
    return SizedBox(
      width: _sceneWidth,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              QuestwellHearthPixelScene(
                height: _sceneHeight,
                archetype: _archetype,
                avatarBodyType: _body,
                showAvatar: _showAvatar,
                equippedSlugs: equipment,
                hearthProfileBySlug: {
                  if (profileKey != null) slug: profileKey,
                },
                hearthRenderBySlug: {
                  if (renderSpec != null) slug: renderSpec,
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hearthReview(_SeasonalReleaseItem item) {
    final benchmarkSlug = _benchmarkSlug(item.profileKey);
    final benchmarkName = _benchmarkName(item.profileKey);
    final children = <Widget>[
      _hearthPanel(
        title: 'Candidate • ${item.name}',
        item: item,
        slug: item.slug,
        renderSpec: item.renderSpec,
        profileKey: item.profileKey,
      ),
    ];
    if (_compareBenchmark) {
      if (benchmarkSlug != null && benchmarkName != null) {
        children.add(_hearthPanel(
          title: 'Locked benchmark • $benchmarkName',
          item: item,
          slug: benchmarkSlug,
        ));
      } else {
        children.add(SizedBox(
          width: _sceneWidth,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No locked visual benchmark is registered for '
                '${item.profileKey}. Review against the 64-bit family rules '
                'without inventing a comparison standard.',
              ),
            ),
          ),
        ));
      }
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            children[i],
          ],
        ],
      ),
    );
  }

  String _baseAsset(String body) => switch (body) {
        'female' => 'assets/images/questwell/avatar/base/base_female.webp',
        'male' => 'assets/images/questwell/avatar/base/base_male.webp',
        _ => 'assets/images/questwell/avatar/base/base_neutral.webp',
      };

  Widget _avatarCanvas({
    required String title,
    required _SeasonalReleaseItem item,
    String? overlay,
  }) {
    final supported = item.wearable?.supportedBodies.contains(_body) ?? false;
    return SizedBox(
      width: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 3 / 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF201A18),
                  ),
                  child: supported
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_showAvatar)
                              Image.asset(
                                _baseAsset(_body),
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            if (overlay != null)
                              Image.asset(
                                overlay,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                          ],
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Text(
                              '${item.name} does not support the $_body body.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wearableReview(_SeasonalReleaseItem item) {
    final wearable = item.wearable!;
    final overlay = wearable.assetsByBody[_body];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatarCanvas(
            title: 'Candidate • ${item.name}',
            item: item,
            overlay: overlay,
          ),
          if (_compareBenchmark) ...[
            const SizedBox(width: 14),
            _avatarCanvas(
              title: 'Locked body baseline • $_body',
              item: item,
            ),
          ],
        ],
      ),
    );
  }

  Widget _unsupportedReview(_SeasonalReleaseItem item) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '${item.name} has no review renderer in this manifest. '
            'Add a Hearth render block or body-specific wearable preview assets.',
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Questwell Seasonal Review Gallery'),
        ),
        body: FutureBuilder<_SeasonalReleaseManifest>(
          future: _manifest,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Could not load ${widget.manifestAsset}\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final manifest = snapshot.data!;
            if (manifest.items.isEmpty) {
              return const Center(child: Text('This release has no items.'));
            }
            final selected = manifest.items.firstWhere(
              (item) => item.slug == _selectedSlug,
              orElse: () => manifest.items.first,
            );
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      manifest.displayName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Collection ${manifest.collectionKey} • account-free development review',
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Nothing on this screen activates, purchases, grants, or locks an item.',
                    ),
                    const SizedBox(height: 14),
                    _itemSelector(manifest, selected),
                    _reviewControls(selected),
                    _itemMetadata(manifest, selected),
                    const SizedBox(height: 4),
                    if (selected.isHearth)
                      _hearthReview(selected)
                    else if (selected.isWearable)
                      _wearableReview(selected)
                    else
                      _unsupportedReview(selected),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
