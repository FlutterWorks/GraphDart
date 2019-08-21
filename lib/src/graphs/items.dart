part of meowtype.graph;

const NoneSpace = #meowtype.graph.nonespace;

Map<Type, Map<dynamic, _Node>> _create_InnerMap() => Map<Type, Map<dynamic, _Node>>();
Map<dynamic, _Node> _create_InnerMap2() => Map<dynamic, _Node>();
Map<Type, Map<_Node, dynamic>> _create_InnerMap_V() => Map<Type, Map<_Node, dynamic>>();
Map<_Node, dynamic> _create_InnerMap2_V() => Map<_Node, dynamic>();

/// Basic graph node collection
abstract class GraphBase implements IGraph {
  final Map<dynamic, Map<Type, Map<_Node, dynamic>>> _node_to_val = {};
  final Map<dynamic, Map<Type, Map<dynamic, _Node>>> _map = {};

  GraphQuery_Base_Add get add => GraphQuery_Base_Add(this);

  bool _to_add<T>(T node, space) {
    final map = _add_or_get(_add_or_get(_map, space, _create_InnerMap), T, _create_InnerMap2);
    final success = _Ref<bool>();
    final n = _add_or_get(map, node, _newNode, success);
    if (success.val) {
      final vmap = _add_or_get(_add_or_get(_node_to_val, space, _create_InnerMap_V), T, _create_InnerMap2_V);
      vmap[n] = node;
    }
    return success.val;
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
