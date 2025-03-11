#import "@preview/lemmify:0.1.8": new-theorems

#let (definition, proof, remark, rules) = new-theorems(
  "theorem_group",
  ("definition": [Definition], "proof": [Proof], "remark": [Remark]),
)
#show: rules




= Appendix


== Discussion: Autobahn Is a $k$-Local GNN


Zhang et al @zhangCompleteExpressivenessHierarchy2023 provides a
definition for GNNs that are based on graph coloring, which is a reformulation
of the coloring perspective introduced in @weisfeilerREDUCTIONGRAPHCANONICAL.
Graph GNNs then fall into one of the sub-categories given by this coloring
definition. Their definition is below, and in particular, one could
say that Autbahn falls into the k-Local GNN GNN category. In this subsection,
we discuss Autobahn and the general results of Homorphism expressivity
for k-Local GNNs. As of writing, a general characterization for k local
GNNs has only been done for $k = 2$.

#definition(name: [Zhang et al @zhangCompleteExpressivenessHierarchy2023])[
  GNNs can be generally described as graph functions that
  are invariant under isomorphism. This is precisely the characterization
  we gave at the beginning of the report, where in @Background we said the key requirement of graph neural networks is to remain invariant under permutations of the symmetric group, and of course for any $sigma in SS_(n)$,
  $cal(G) tilde.equiv sigma dot.op cal(G)$.

  Most GNN's therefore, can be said to adhere to a _color refinement_
  approach: they maintain a feature representation, i.e. a color, for
  each vertex or vertex tuple, and iteratively refine these features
  by processing them through the equivariant hidden layers, until the last layer
  pools all of these features together to ensure invariance (isomorphism).

  - *MPNN*: Given a graph $G$, MPNN maintains a color
    $cal(X)^("MP")_(G)(u)$ for each vertex $u in V_(G)$. Initially
    the color only depends on the label of the vertex. For instance
    $cal(X)^("MP",(0))_(G)(u) = ell_(G)(u)$. Then, for each layer,
    the color is refined by the update
    $
      cal(X)_(G)^("MP",(t+1))(u) = "hash"lr(( cal(X)_(G)^("MP",(t)),
      lr({{ cal(X)_(G)^("MP", (t))(v) bar.v v in N_(G)(u) }}))).
    $
    Here, we used ${{ dot.op }}$ to denote the multi-set.
    After a certain point, the color processing stabilizes and the graph
    representation becomes $cal(X)_(G)^("MP")(G) = {{cal(X)_(G)^("MP")(u) bar.v u in V_(G)}}$

  - *Local GNN*. We quote their definition #quote(attribution: <zhangCompleteExpressivenessHierarchy2023>, "Inspired by the k-WL test (Grohe, 2017), Local k-GNN is defined by replacing all global aggregations in k-WL by sparse ones that only aggregate local neighbors, yielding a much more efficient CR algorithm.")
  I omit the other sub-graph types.
]<def:graphtypes>

Automorphism based GNN @dehaanNaturalGraphNetworks2020 such as
Autobahn are considered by homomorphism expressivity to be _local
GNN's_, according to @def:graphtypes. Their forumulation for local GNN's
is not as precise as for the other 3 GNN classes they characterize, but
in general, Autobahn works by being a sparse k-WL.
The number of vertices in the given template graph corresponds to $k$.
Moreover, Autobahn avoids the computation overhead of k-WL by identifying
sub-sequences of vertices that are isomorphic to the template sub-graph.

Without a more rigorous formulation of the Local GNN variant we cannot
prove the Autobahn is a local GNN, which precludes us from using
the results for local 2-GNN's in @gaiHomomorphismExpressivitySpectral2024.
Moreover, Autobahn is not in a general a local 2-GNN, so Theorem 3.4 @zhangWeisfeilerLehmanQuantitativeFramework2024 cannot be
used. However, while we have not classified Autobahn in general under homomorphism
expressivity, we classify Autobahn under certain sub-graphs and compare.

Researching a proper definition of Local k-GNN and formulating Autobahn
in terms of it is an area for future investigation. However,
the only proven general characterization of Local k-GNN is for $k=2$ @zhangWeisfeilerLehmanQuantitativeFramework2024, and
the proof is a major technical contribution. Therefore, it may not be best
to consider this route, especially as homomorphism expressivity provides
valuable insight alone when using it on particular graphs, as we show now.

== Autobahn As a 2 Local GNN

Autobahn is a very flexible framework. Assuming we can indeed
think of Autobahn as a k-local GNN, we show that, even as a 2-local GNN, it
it is distinguishes the graphs given in @main:2.

#proof(name: "Trivial")[
  Using @zhangWeisfeilerLehmanQuantitativeFramework2024, all 2-local GNNs
  can recognize any two graphs $G$ and $H$ if via $F$, if $F$ is a _strongly nested
ear decomposition_ @eppsteinParallelRecognitionSeriesparallel1992 @zhangWeisfeilerLehmanQuantitativeFramework2024.
  $C_(3)$ is indeed a strongly nested
]

#definition(name: [Narrowing In Autobahn @thiedeAutobahnAutomorphismbasedGraph2021])[
  Let $(i_(1),...,i_(k))$ be an ordered subset of ${1,2,...m}$.
  The set ${1,...,m}}$ corresponds to the sub-graph isomorphic
  to the template graph $cal(T)$, and the ordered subset
  $(i_(1), ... ,i_(k))$ corresponds to $k$ "ambassador nodes"
  that overlap with a different sub-graph.

  Now, for all $u in SS_(k)$, let $tilde(u) in SS_(k)$ be the permutation
  that $u$ to the first $k$ elements and for all $s in SS_(m-k)$,
  let $tilde(s) in SS_(m)$ be the permutation that applies $s$ to the last $m -k$ elements. Then, given our activation function $f: SS_(m) -> RR^(d)$,
  the _narrowing_ of $f$ to $(i_(1),...,i_(k))$ is
  $
    f #h(-.01em) scripts(arrow.b)_(i_(1),...i_(k)) = (m - k)!^(-1) sum_(s in SS_(m-k))^()f(tilde(u) tilde(s) t)
  $
  #remark[This was taken from @thiedeAutobahnAutomorphismbasedGraph2021.
    At a high-level narrowing produces a function $f arrow.b$ that is only
    dependent on the important nodes $(v_(i_(1)), ..., v_(i_(k)))$.
  ]
]<def:narrowing>


// == How Narrowing And Promotion Work In Autobahn: A Qualitative Explanation <A:NarrowExplainer>
//
// #remark[
//   We omitted details of Autobahn's primary contribution, that
//   is, the formalized notions of _narrowing_ and _promotion_.
//   This is because we are concerned with Autobahn's sub-graph counting
//   abilities, and narrowing and promotion are techniques to reduce the
//   computation complexity of achieving automorphism based neurons when graphs
//   overlap @dehaanNaturalGraphNetworks2020.
//
//   We constructed our example to be particularly simple, and showed such
//   an automorphism based neuron @dehaanNaturalGraphNetworks2020.
//   The point of the section was to illustrate, through elementary computation and
//   novice language,
//   the sub-graph counting abilities
//   of automorphism based neuron networks.
//
//   See the appendix @A:NarrowExplainer for an explanation of
//   how Autobahn uses narrowing and promotion to reduce the computation
//   overhead, which is important when the input graph contains more than 1
//   sub-graph isomorphic to the template graph.
// ]
//
// At any given layer $i$, Autobahn first identifies all the sub-graphs of $A$
// that are isomorphic to $cal(A)_(cal(T))$. In our case,
// $(v_(1), v_(2), v_(3), v_(4), v_(5))$ is the only such sub graph of $A$.
//
// Next, given we are looking at the first layer,
// we need to define an input domain. Let the input to the first layer
// be the degree of each node on the feature graph.
//
// Next, for each sub-graph isomorphic to $A$, Autobahn performs _narrowing_.
// _Narrowing_ will be described plainly here. The formal definition is given in
// the appendix.
// _Narrowing_ takes the sub-graph $(v_(i_(1)), ... ,v_(i_(m)))$
// and partitions the nodes of the graph into two groups: the important group
// $cal(I)_(1) = {i_(1), ... ,i_(k)}$ and the not important group consisting of
// the remaining $k - m$ nodes, $cal(I)_(2) = {i_(k+1), ... ,i_(m)}$.
// Note that I assumed that the first $1$ through
// $k$ indices were the important nodes, but typically narrowing adds the indices
// to the important group which _overlap_ with a another sub-graph.
// Let us call such nodes the "ambassador" nodes.
//
// In our example, narrowing operates on our sub-graph ${v_(1), ... ,v_(5)}$.
// It then adds node $v_(1)$ to the important group $cal(I)_(1) = {i_(1)}$
// and puts the remaining $2, ... ,4$ indices in the not important group
// $cal(I)_(2) = {i_(2), ... i_(4)}$. Finally, the narrowing procedure is applied
// to our sub-graph neuron, which makes our sub-graph neuron only depend on the
// important nodes in $cal(I)_(1)$. See the appendix @def:narrowing for the
// formal definition of narrowing.
//
// Similarly to how narrowing is done, then _promoting_ is done to the neuron,
// which takes the narrowing activations and spreads them out to all the
// $m$ nodes in the sub-graph that this neuron is working on.
//
// We won't go into narrowing or promotion in too much detail, but we can provide
// a sketch of how to ensure that our neuron $cal(n)$ is equivariant to $"Aut"(A_(cal(T)))$
// and also equivariant to all of $A$ in general.
//
// For example, in our case let the input feature vectors be
// $f_(1) = "deg"(v_(1)) = 2, f_(2) = "deg"(v_(2)) = 2 = ... = f_(5)$.
// Notice that $f_(1) = 2$, because we are only considering degrees within the
// sub graph $v_(1),...v_(5)$.
//
// Now, we can ensure equivariance of our function $cal(n)$ on this 5-tuple
// with respect to $D_(5)$, by convolving over the element of $D_(5)$.
// $
//   D_(5) = sum_(sigma in D_(5))^() f
// $
//
//
// Now, in order to account for $v_(1)$'s connection
// to $v_(6)$, we redefine the feature vectors $f_(i)$ to include a indicator
// variable saying if the node is adjacent to the pendant node $v_(6)$.
//
// $
//   f_(1)=("deg"(v_(1)), 1) = (2, 1) #h(2em) f_(2) = ("deg"(v_(1))), 0) = (2, 0)
//   = f_(2) ... = f_(5)
// $



