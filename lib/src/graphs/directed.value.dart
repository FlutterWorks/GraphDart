part of MeowType.Graph;

abstract class DirectedValueGraph extends DirectedGraph {
  factory DirectedValueGraph() => FullGraph();
  void setTo(from, to, key, val);
  void setToBy<T>(from, to, val);
  bool hasEdgeTo(from, to, key);
  bool hasEdgeToBy<T>(from, to);
  bool unSetTo(from, to, key);
}

mixin DirectedValueGraphMixin on DirectedGraphMixin
    implements DirectedValueGraph, GraphGet {
  void setTo(from, to, key, val) {
    final _f = _add_or_get(_map, from, _newNode);
    final _t = _add_or_get(_map, to, _newNode);
    _t.setFrom(_f);
    _f.setToV(_t, key, val);
  }

  void setToBy<T>(from, to, val) {
    final _f = _add_or_get(_map, from, _newNode);
    final _t = _add_or_get(_map, to, _newNode);
    _t.setFrom(_f);
    _f.setToT<T>(_t, val);
  }

  bool hasEdgeTo(from, to, key) {
    final _f = _add_or_get(_map, from, _newNode);
    final _t = _add_or_get(_map, to, _newNode);
    return _f.hasToV(_t, key);
  }

  bool hasEdgeToBy<T>(from, to) {
    final _f = _add_or_get(_map, from, _newNode);
    final _t = _add_or_get(_map, to, _newNode);
    return _f.hasToT<T>(_t);
  }

  bool unSetTo(from, to, key) {
    final _f = _add_or_get(_map, from, _newNode);
    final _t = _add_or_get(_map, to, _newNode);
    return _f.unsetToV(_t, key);
  }

  bool unSetToBy<T>(from, to) {
    final _f = _add_or_get(_map, from, _newNode);
    final _t = _add_or_get(_map, to, _newNode);
    return _f.unsetToV(_t, T);
  }
}
