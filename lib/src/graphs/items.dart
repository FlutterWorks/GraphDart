part of meowtype.graph;

Map<Type, Map<dynamic, _Node>> _create_InnerMap() => Map<Type, Map<dynamic, _Node>>();
Map<dynamic, _Node> _create_InnerMap2() => Map<dynamic, _Node>();
Map<Type, Map<_Node, dynamic>> _create_InnerMap_V() => Map<Type, Map<_Node, dynamic>>();
Map<_Node, dynamic> _create_InnerMap2_V() => Map<_Node, dynamic>();

/// Basic graph node collection
abstract class GraphBase implements IGraph {
  final Map<dynamic, Map<Type, Map<_Node, dynamic>>> _node_to_val = {};
  final Map<dynamic, Map<Type, Map<dynamic, _Node>>> _map = {};

  base_add.Add get add => base_add.Add(this);
  base_has.Has get has => base_has.Has(this);
  base_remove.Remove get remove => base_remove.Remove(this);

  bool to_add<T>(T node, [space = NoneSpace]) => to_add_AnyType(T, node, space);
  bool to_add_AnyType(Type type, node, [space = NoneSpace]) {
    final map = _add_or_get(_add_or_get(_map, space, _create_InnerMap), type, _create_InnerMap2);
    final success = _Ref<bool>();
    final n = _add_or_get(map, node, _newNode, success);
    if (success.val) {
      final vmap = _add_or_get(_add_or_get(_node_to_val, space, _create_InnerMap_V), type, _create_InnerMap2_V);
      vmap[n] = node;
    }
    return success.val;
  }

  bool check_has<T>(T node, [space = NoneSpace]) => check_has_AnyType(T, node, space);
  bool check_has_AnyType(Type type, node, [space = NoneSpace]) {
    final smap = _try_get(_map, space);
    if (smap is None) return false;
    final tmap = _try_get(smap.val, type);
    if (tmap is None) return false;
    return tmap.val.containsKey(node);
  }

  bool try_remove<T>(T node, [space = NoneSpace]) => try_remove_AnyType(T, node, space);
  bool try_remove_AnyType(Type type, node, [space = NoneSpace]) {
    final smap = _try_get(_map, space);
    if (smap is None) return false;
    final tmap = _try_get(smap.val, type);
    if (tmap is None) return false;
    final r = tmap.val.containsKey(node);
    if (r) tmap.val.remove(node);
    return r;
  }

  Iterable<FindBoxBy<T>> find_allBy<T>([Maybe space, Func2<bool, dynamic, dynamic> where, Func1<bool, dynamic> where_space]) sync* {
    if (space is Some) {
      final smap = _try_get(_map, space.val);
      if (smap is None) return;
      final tmap = _try_get(smap.val, T);
      if (tmap is None) return;
      if (where == null) {
        for (var item in tmap.val.keys) {
          yield FindBoxBy<T>(item, space.val);
        }
      } else {
        for (var item in tmap.val.keys) {
          if (!where(item, space.val)) continue;
          yield FindBoxBy<T>(item, space.val);
        }
      }
    } else {
      for (var s in where_space == null ? _map.keys : _map.keys.where(where_space)) {
        final smap = _map[s];
        final tmap = _try_get(smap, T);
        if (tmap is None) return;
        if (where == null) {
          for (var item in tmap.val.keys) {
            yield FindBoxBy<T>(item, s);
          }
        } else {
          for (var item in tmap.val.keys) {
            if (!where(item, s)) continue;
            yield FindBoxBy<T>(item, s);
          }
        }
      }
    }
  }

  Iterable<FindBox> find_all([Maybe space, Func3<bool, dynamic, dynamic, Type> where, Func1<bool, dynamic> where_space, Func1<bool, Type> where_type]) sync* {
    if (space is Some) {
      final smap = _try_get(_map, space.val);
      if (smap is None) return;
      for (var type in smap.val.keys) {
        final tmap = smap.val[type];
        if (where == null) {
          for (var item in tmap.keys) {
            yield FindBox(item, space.val, type);
          }
        } else {
          for (var item in tmap.keys) {
            if (!where(item, space.val, type)) continue;
            yield FindBox(item, space.val, type);
          }
        }
      }
    } else {
      for (var space in where_space == null ? _map.keys : _map.keys.where(where_space)) {
        final smap = _map[space];
        for (var type in where_type == null ? smap.keys : smap.keys.where(where_type)) {
          final tmap = smap[type];
          if (where == null) {
            for (var item in tmap.keys) {
              yield FindBox(item, space, type);
            }
          } else {
            for (var item in tmap.keys) {
              if (!where(item, space, type)) continue;
              yield FindBox(item, space, type);
            }
          }
        }
      }
    }
  }
}

// //====================================================================================================

// class GraphQuery_Add extends GraphQuery with GraphQueryGETNodeMixin<GraphQuery_Add_Node> {
//   GraphQuery_Add(IGraph graph) : super(graph);

//   GraphQuery_Add_Node<T> nodeBy<T>(T node, [space = NoneSpace]) => GraphQuery_Add_Node<T>(this, node, space);
// }

// //====================================================================================================

// class GraphQuery_Add_Node<T> extends GraphQuery_Node<T> implements IGraphQueryGETLink {
//   final GraphQuery _query;
//   GraphQuery_Add_Node(this._query, T node, [space = NoneSpace]) : super(node, space);

//   GraphQuery_Add_Link<L> link<L>({space = NoneSpace, Maybe<L> value}) => GraphQuery_Add_Link(space, value);
//   GraphQuery_Add_LinkTo<L> linkTo<L>({space = NoneSpace, Maybe<L> value}) => GraphQuery_Add_LinkTo(space, value);
// }

// class GraphQuery_Add_Node_End<T> extends GraphQuery_Node<T> {
//   final IGraphQuery_Link _link;
//   GraphQuery_Add_Node_End(this._link, T node, [space = NoneSpace]) : super(node, space);
// }

// //====================================================================================================

// mixin IGraphQuery_Add_Link on GraphQueryGETNodeMixin<GraphQuery_Add_Node_End> implements IGraphQuery_Link {
//   GraphQuery_Add_Node_End<T> nodeBy<T>(T node, [space = NoneSpace]) => GraphQuery_Add_Node_End<T>(this, node, space);
// }

// //==================================================

// class GraphQuery_Add_Link<T> extends GraphQuery_Link<T> with GraphQueryGETNodeMixin<GraphQuery_Add_Node_End>, IGraphQuery_Add_Link {
//   GraphQuery_Add_Link([space = NoneSpace, Maybe<T> value]) : super(space, value);
// }

// //==================================================

// class GraphQuery_Add_LinkTo<T> extends GraphQuery_LinkTo<T> with GraphQueryGETNodeMixin<GraphQuery_Add_Node_End>, IGraphQuery_Add_Link {
//   GraphQuery_Add_LinkTo([space = NoneSpace, Maybe<T> value]) : super(space, value);
// }

// //====================================================================================================
