// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/plugins/src/types/heatmap.dart';

/// [Heatmap] update events to be applied to the [GoogleMap].
///
/// Used in [GoogleMapController] when the map is updated.
class HeatmapUpdates {
  /// Computes [HeatmapUpdates] given previous and current [Heatmap]s.
  HeatmapUpdates.from(Set<Heatmap> previous, Set<Heatmap> current) {
    if (previous == null) {
      previous = Set<Heatmap>.identity();
    }

    if (current == null) {
      current = Set<Heatmap>.identity();
    }

    late final Map<HeatmapId, Heatmap> previousHeatmaps =
        keyByHeatmapId(previous);
    late final Map<HeatmapId, Heatmap> currentHeatmaps =
        keyByHeatmapId(current);

    late final Set<HeatmapId> prevHeatmapIds = previousHeatmaps.keys.toSet();
    late final Set<HeatmapId> currentHeatmapIds = currentHeatmaps.keys.toSet();

    Heatmap idToCurrentHeatmap(HeatmapId id) {
      return currentHeatmaps[id]!;
    }

    late final Set<HeatmapId> _heatmapIdsToRemove =
        prevHeatmapIds.difference(currentHeatmapIds);

    late final Set<Heatmap> _heatmapsToAdd = currentHeatmapIds
        .difference(prevHeatmapIds)
        .map(idToCurrentHeatmap)
        .toSet();

    /// Returns `true` if [current] is not equals to previous one with the
    /// same id.
    bool hasChanged(Heatmap current) {
      late final Heatmap previous = previousHeatmaps[current.heatmapId]!;
      return current != previous;
    }

    late final Set<Heatmap> _heatmapsToChange = currentHeatmapIds
        .intersection(prevHeatmapIds)
        .map(idToCurrentHeatmap)
        .where(hasChanged)
        .toSet();

    heatmapsToAdd = _heatmapsToAdd;
    heatmapIdsToRemove = _heatmapIdsToRemove;
    heatmapsToChange = _heatmapsToChange;
  }

  late Set<Heatmap> heatmapsToAdd;
  late Set<HeatmapId> heatmapIdsToRemove;
  late Set<Heatmap> heatmapsToChange;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> updateMap = <String, dynamic>{};

    void addIfNonNull(String fieldName, dynamic value) {
      if (value != null) {
        updateMap[fieldName] = value;
      }
    }

    addIfNonNull('heatmapsToAdd', serializeHeatmapSet(heatmapsToAdd));
    addIfNonNull('heatmapsToChange', serializeHeatmapSet(heatmapsToChange));
    addIfNonNull('heatmapIdsToRemove',
        heatmapIdsToRemove.map<dynamic>((HeatmapId m) => m.value).toList());

    return updateMap;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    late final HeatmapUpdates typedOther = other as HeatmapUpdates;
    return setEquals(heatmapsToAdd, typedOther.heatmapsToAdd) &&
        setEquals(heatmapIdsToRemove, typedOther.heatmapIdsToRemove) &&
        setEquals(heatmapsToChange, typedOther.heatmapsToChange);
  }

  @override
  int get hashCode =>
      hashValues(heatmapsToAdd, heatmapIdsToRemove, heatmapsToChange);

  @override
  String toString() {
    return 'HeatmapUpdates{heatmapsToAdd: $heatmapsToAdd, '
        'heatmapIdsToRemove: $heatmapIdsToRemove, '
        'heatmapsToChange: $heatmapsToChange}';
  }
}
