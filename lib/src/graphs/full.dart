part of meowtype.graph;

Map<dynamic, _Node> _create_InnerMap() => Map<dynamic, _Node>();

/// Basic graph node collection
class FullGraph implements Graph {
  /// space -> node -> _Node
  final Map<dynamic, Map<dynamic, _Node>> _map = {};

  full.Add get add => full.Add(this);
  full.Has get has => full.Has(this);
  full.Remove get remove => full.Remove(this);
  full.Find get find => full.Find(this);

  bool to_add<T>(T node, [space = NoneSpace]) {
    final map = _add_or_get(_map, space, _create_InnerMap);
    return _try_add(map, node, () => _Node(node, space));
  }

  bool set_link<A, B>(A nodeA, B nodeB, {spaceA = NoneSpace, spaceB = NoneSpace, spaceLink = NoneSpace}) {
    return _Tuple2(_Tuple2(nodeA, spaceA), _Tuple2(nodeB, spaceB))
        .map((t) {
          final map = _add_or_get(_map, t.b, _create_InnerMap);
          return _add_or_get(map, t.a, () => _Node(t.a, t.b));
        })
        .mutual((f, t) => f.setTo(t, spaceLink) || t.setFrom(f))
        .toDo((a, b) => a || b);
  }

  bool set_linkTo<F, T>(F from, T to, {spaceFrom = NoneSpace, spaceTo = NoneSpace, spaceLink = NoneSpace}) {
    return _Tuple2(_Tuple2(from, spaceFrom), _Tuple2(to, spaceTo)).map((t) {
      final map = _add_or_get(_map, t.b, _create_InnerMap);
      return _add_or_get(map, t.a, () => _Node(t.a, t.b));
    }).toDo((f, t) => f.setTo(t, spaceLink) || t.setFrom(f));
  }

  bool set_link_with_val<A, B, V>(A nodeA, B nodeB, V val, {spaceA = NoneSpace, spaceB = NoneSpace, spaceLink = NoneSpace}) {
    return _Tuple2(_Tuple2(nodeA, spaceA), _Tuple2(nodeB, spaceB))
        .map((t) {
          final map = _add_or_get(_map, t.b, _create_InnerMap);
          return _add_or_get(map, t.a, () => _Node(t.a, t.b));
        })
        .mutual((f, t) => f.setToV(t, val, spaceLink) || t.setFrom(f))
        .toDo((a, b) => a || b);
  }

  bool set_linkTo_with_val<F, T, V>(F from, T to, V val, {spaceFrom = NoneSpace, spaceTo = NoneSpace, spaceLink = NoneSpace}) {
    return _Tuple2(_Tuple2(from, spaceFrom), _Tuple2(to, spaceTo)).map((t) {
      final map = _add_or_get(_map, t.b, _create_InnerMap);
      return _add_or_get(map, t.a, () => _Node(t.a, t.b));
    }).toDo((f, t) => f.setToV(t, val, spaceLink) || t.setFrom(f));
  }

  bool check_has<T>(T node, [space = NoneSpace]) {
    final smap = _try_get(_map, space);
    if (smap is None) return false;
    if (smap.val.containsKey(node)) {
      return smap.val[node] is T;
    }
    return false;
  }

  bool check_has_link<F, T>(F from, Maybe<T> to, {spaceFrom = NoneSpace, spaceTo = NoneSpace, spaceLink = NoneSpace, LinkDirection direct = LinkDirection.Mutual}) {
    if (direct == null || direct == LinkDirection.Mutual) {
      return check_has_link(from, to, spaceFrom: spaceFrom, spaceTo: spaceTo, spaceLink: spaceLink, direct: LinkDirection.To) ||
          check_has_link(from, to, spaceFrom: spaceFrom, spaceTo: spaceTo, spaceLink: spaceLink, direct: LinkDirection.From);
    }

    final smap = _try_get(_map, spaceFrom);
    if (smap is Some && smap.val.containsKey(from) && smap.val[from] is F) {
      final _n = smap.val[from];
      if (to is Some) {
        final smap = _try_get(_map, spaceFrom);
        if (smap is Some && smap.val.containsKey(to.val) && smap.val[to.val] is T) {
          if (direct == LinkDirection.To) {
            return _n.hasTo(smap.val[to.val], spaceLink);
          } else {
            return smap.val[to.val].hasTo(_n, spaceLink);
          }
        }
        return false;
      } else {
        if (direct == LinkDirection.To) {
          return _n._to.values.any((_m) => _m.containsKey(spaceLink));
        } else {
          return _n._from.any((_f) => _f.hasTo(_n, spaceLink));
        }
      }
    }
    return false;
  }

  bool try_remove<T>(T node, [space = NoneSpace, Out<Maybe<T>> removed_value]) {
    final smap = _try_get(_map, space);
    if (smap is None) return false;
    if (smap.val.containsKey(node) && smap.val[node] is T) {
      final rv = smap.val.remove(node);
      // todo unset link
      trySetValFn(removed_value, () => Some(rv._val));
      return true;
    } else {
      trySetValFn(removed_value, () => None());
      return false;
    }
  }

  Iterable<FindBox<T>> find_all<T>({Func1<bool, dynamic> where, Or<dynamic, Func1<bool, dynamic>> space}) sync* {
    if (where == null) {
      where = (item) => item is! T;
    } else {
      final old_where = where;
      where = (item) => !old_where(item) && item is! T;
    }

    Iterable<FindBox<T>> forSmap(Map<dynamic, _Node> map, space) sync* {
      for (var item in map.keys) {
        if (where(item)) continue;
        yield FindBox<T>(item, space);
      }
    }

    if (space is OrLeft) {
      final smap = _try_get(_map, space.getL);
      if (smap is None) return;
      yield* forSmap(smap.val, space.getL);
    } else {
      for (var s in space is OrRight ? _map.keys : _map.keys.where(space.getR)) {
        final smap = _map[s];
        yield* forSmap(smap, s);
      }
    }
  }

  Iterable<_RawFindLinkBox<F, T>> _find_all_link_base<F, T>(
      {Or<dynamic, Func1<bool, dynamic>> fromSpace, Func1<bool, F> fromWhere, Or<dynamic, Func1<bool, dynamic>> toSpace, Func1<bool, T> toWhere, LinkDirection direct = LinkDirection.Mutual}) {
    if (fromWhere == null) {
      fromWhere = (item) => item is F;
    } else {
      final old_where = fromWhere;
      fromWhere = (item) => old_where(item) && item is F;
    }

    if (toWhere == null) {
      toWhere = (item) => item is T;
    } else {
      final old_where = toWhere;
      toWhere = (item) => old_where(item) && item is T;
    }

    Iterable<_RawFindBox<A>> forSmap<A>(Map<dynamic, _Node> map, Func1<bool, A> where, space) sync* {
      for (var item in map.keys) {
        if (!where(item)) continue;
        yield _RawFindBox<A>(item, space, map[item]);
      }
    }

    Iterable<_RawFindBox<F>> getFrom() sync* {
      if (fromSpace != null) {
        if (fromSpace is OrLeft) {
          final smap = _try_get(_map, fromSpace.getL);
          if (smap is None) return;
          yield* forSmap<F>(smap.val, fromWhere, fromSpace.getL);
          return;
        } else if (fromSpace.getR != null) {
          for (var s in _map.keys.where(fromSpace.getR)) {
            final smap = _map[s];
            yield* forSmap<F>(smap, fromWhere, s);
            return;
          }
        }
      }
      for (var s in _map.keys) {
        final smap = _map[s];
        yield* forSmap<F>(smap, fromWhere, s);
      }
    }

    Func1<bool, dynamic> getToSoaceFn() {
      if (toSpace != null) {
        if (toSpace is OrLeft) {
          final space = toSpace.getL;
          return (s) => s == space;
        } else if (toSpace.getR != null) {
          return toSpace.getR;
        }
      }
      return (_) => true;
    }

    Iterable<_RawFindLinkBox<F, T>> getLink() sync* {
      final toSoaceFn = getToSoaceFn();

      Iterable<_RawFindLinkBox<F, T>> genTo(_RawFindBox<F> find) sync* {
        yield* find.node._to.entries.where((e) => toWhere(e.key._val) && toSoaceFn(e.key._space)).map((e) => _RawFindLinkBox(find, _RawFindBox.FromNode(e.key), e.value));
      }

      Iterable<_RawFindLinkBox<F, T>> genFrom(_RawFindBox<F> find) sync* {
        yield* find.node._from.where((_n) => toWhere(_n._val) && toSoaceFn(_n._space) && _n._to.containsKey(find.node)).map((_n) => _RawFindLinkBox(find, _RawFindBox.FromNode(_n), _n._to[find.node]));
      }

      switch (direct) {
        case LinkDirection.Mutual:
          for (var find in getFrom()) {
            yield* genTo(find);
            yield* genFrom(find);
          }
          break;
        case LinkDirection.From:
          for (var find in getFrom()) {
            yield* genFrom(find);
          }
          break;
        case LinkDirection.To:
          for (var find in getFrom()) {
            yield* genTo(find);
          }
          break;
      }
    }

    return getLink();
  }

  Iterable<FindLinkBox<F, T>> find_all_link<F, T>(
      {Or<dynamic, Func1<bool, dynamic>> fromSpace,
      Func1<bool, F> fromWhere,
      Or<dynamic, Func1<bool, dynamic>> toSpace,
      Func1<bool, T> toWhere,
      Or<dynamic, Func1<bool, dynamic>> linkSpace,
      LinkDirection direct = LinkDirection.Mutual}) sync* {
    Iterable<_RawFindLinkBox<F, T>> getLink() => _find_all_link_base(fromSpace: fromSpace, fromWhere: fromWhere, toSpace: toSpace, toWhere: toWhere, direct: direct);

    if (linkSpace != null) {
      if (linkSpace is OrLeft) {
        yield* getLink().where((l) => l.map.containsKey(linkSpace.getL)).map((l) => FindLinkBox(l.from.val, l.from.space, l.to.val, l.to.space, linkSpace.getL));
      } else if (linkSpace.getR != null) {
        for (var l in getLink()) {
          yield* l.map.keys.where(linkSpace.getR).map((s) => FindLinkBox(l.from.val, l.from.space, l.to.val, l.to.space, s));
        }
      }
    }
    for (var l in getLink()) {
      yield* l.map.keys.map((s) => FindLinkBox(l.from.val, l.from.space, l.to.val, l.to.space, s));
    }
  }

  Iterable<FindLinkValBox<F, T, V>> find_all_link_WithVal<F, T, V>(
      {Or<dynamic, Func1<bool, dynamic>> fromSpace,
      Func1<bool, F> fromWhere,
      Or<dynamic, Func1<bool, dynamic>> toSpace,
      Func1<bool, T> toWhere,
      Or<dynamic, Func1<bool, dynamic>> linkSpace,
      Func1<bool, V> valWhere,
      LinkDirection direct = LinkDirection.Mutual}) sync* {
    if (valWhere == null) {
      valWhere = (item) => true;
    }

    Iterable<_RawFindLinkBox<F, T>> getLink() => _find_all_link_base(fromSpace: fromSpace, fromWhere: fromWhere, toSpace: toSpace, toWhere: toWhere, direct: direct);

    if (linkSpace != null) {
      if (linkSpace is OrLeft) {
        yield* getLink()
            .where((l) => l.map.containsKey(linkSpace.getL) && l.map[linkSpace.getL] is V && valWhere(l.map[linkSpace.getL] as V))
            .map((l) => FindLinkValBox(l.from.val, l.from.space, l.to.val, l.to.space, linkSpace.getL, l.map[linkSpace.getL] as V));
      } else if (linkSpace.getR != null) {
        for (var l in getLink()) {
          yield* l.map.keys.where(linkSpace.getR).where((s) => l.map[s] is V && valWhere(l.map[s] as V)).map((s) => FindLinkValBox(l.from.val, l.from.space, l.to.val, l.to.space, s, l.map[s] as V));
        }
      }
    }
    for (var l in getLink()) {
      yield* l.map.keys.where((s) => l.map[s] is V && valWhere(l.map[s] as V)).map((s) => FindLinkValBox(l.from.val, l.from.space, l.to.val, l.to.space, s, l.map[s] as V));
    }
  }
}
