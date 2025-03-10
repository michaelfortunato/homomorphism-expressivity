#import "@preview/bloated-neurips:0.5.1": botrule, midrule, neurips2024, paragraph, toprule, url, font
#import "@preview/lemmify:0.1.8": *
#import "@preview/cetz:0.3.3": canvas, draw, tree
#import "@preview/subpar:0.2.1"

#let scr(it) = text(
  features: ("ss01",),
  box($cal(it)$),
)


#let affls = (
  uChicago: ("University of Chicago", "Chicago", "USA"),
)

#let authors = (
  (
    name: "Michael Newman Fortunato",
    affl: "uChicago",
    email: "michaelfortunato@uchicago.edu",
    equal: true,
  ),
)

#show: neurips2024.with(
  title: [
    Characterizing Schur Net's Expressivity Via \ Homomorphism Expressivity \
    #text(fill: red, "NOTICE: THIS IS THE LATE VERSION AND WAS SUBMITTED AFTER THE DEADLINE")],
  authors: (authors, affls),
  keywords: ("GNNs", "Permutation-Equivairant-Neuralnetworks"),
  abstract: [
    Graph spectral invariants and group-theoretic constructions each offer
    complementary pathways toward building expressive Graph
    Neural Networks (GNNs) @thiedeAutobahnAutomorphismbasedGraph2021
    Recent work on higher-order message passing has shown
    that subgraphs communicating with subgraphs can capture complex local structures (e.g., cycles)
    by leveraging equivariance to the automorphism group of each local environment @thiedeAutobahnAutomorphismbasedGraph2021
    However, explicitly enumerating these automorphism groups is often infeasible.
    In response to these challenges, Schur Net provides a spectral
    approach that circumvents direct group enumeration,
    yet its precise expressive power relative to group-based methods remains an open question @zhangSchurNetsExploiting2025

    Quite recently, a theoretical framework for measuring
    the expressivity of GNNs was introduced,
    dubbed _Homorphism Expressivity_ @gaiHomomorphismExpressivitySpectral2024
    Crucially, Homomorphism Expressivity is the first measure of a GNN's expressivity
    that does not fall under a Weisfeiler-Lehman test @gaiHomomorphismExpressivitySpectral2024
    In this proposal, we layout a plan for theoretically
    measuring the expressivity of Schur Nets @zhangSchurNetsExploiting2025
    using Homomorhism Expressivity @gaiHomomorphismExpressivitySpectral2024
    Specifically, we could characterize
    how Schur Net’s spectral invariants compare to, and sometimes replicate,
    the subgraph-counting capabilities
    typically attributed to automorphism-based frameworks.
    Our analysis quantifies which families of graphs (and which substructures within them) each paradigm can homomorphism-count, and under what conditions they coincide or diverge.
    Furthermore, we extend our results to higher-order GNNs, clarifying how spectral techniques and group-theoretic constructions each handle more complex local symmetries.
    By illuminating these trade-offs, we aim to guide the design of hybrid GNN architectures that harness both the computational simplicity of spectral methods and
    the robust theoretical grounding of group-theoretic approaches.
  ],
  appendix: [
    #include "appendix.typ"
  ],
  bibliography: bibliography("Zotero.bib"),
  bibliography-opts: (title: "References"),
  accepted: none,
)

#let (
  theorem,
  lemma,
  corollary,
  remark,
  proposition,
  definition,
  example,
  proof,
  rules: theorem_rules,
) = default-theorems("theorem_group", lang: "en")

#show: theorem_rules

// Patch neurips bloated to get it all right
#let make_figure_caption(it) = {
  set align(center)
  block({
    set align(left)
    set text(size: font.normal)
    it.supplement
    if it.numbering != none {
      [ ]
      context it.counter.display(it.numbering)
    }
    it.separator
    [ ]
    it.body
  })
}
#let make_figure(caption_above: false, it) = {
  let body = block(
    width: 100%,
    {
      set align(center)
      set text(size: font.normal)
      if caption_above {
        v(1em, weak: true) // Does not work at the block beginning.
        it.caption
      }
      v(1em, weak: true)
      it.body
      v(8pt, weak: true) // Original 1em.
      if not caption_above {
        it.caption
        v(1em, weak: true) // Does not work at the block ending.
      }
    },
  )

  if it.placement == none {
    return body
  } else {
    return place(it.placement, body, float: true, clearance: 2.3em)
  }
}

#show figure: set block(breakable: false)
#show figure.caption.where(kind: table): it => make_figure_caption(it)
#show figure.caption.where(kind: image): it => make_figure_caption(it)
#show figure.where(kind: image): it => make_figure(it)
#show figure.where(kind: table): it => make_figure(it, caption_above: true)

// Default edge draw callback
//
// - from (string): Source element name
// - to (string): Target element name
// - parent (node): Parent (source) tree node
// - child (node): Child (target) tree node
#let default-draw-edge(from, to, parent, child) = {
  draw.line(from, to)
}

// Default node draw callback
//
// - node (node): The node to draw
#let default-draw-node(node, _) = {
  let text = if type(node) in (content, str, int, float) {
    [#node]
  } else if type(node) == dictionary {
    node.content
  }

  draw.get-ctx(ctx => {
    draw.content((), text)
  })
}

// Function to draw a star graph with n outer nodes
#let draw-star-graph(
  n,
  node_label_fn: i => text(str(i)),
  node_color_function: i => white,
) = {
  canvas({
    import draw: *

    let radius = 1 // Radius of the circle for outer nodes
    let center = (0, 0) // Position of the central node

    // Calculate positions of outer nodes
    let nodes = (center,)
    for i in range(n) {
      let angle = 360deg / n * i
      let x = radius * calc.cos(angle)
      let y = radius * calc.sin(angle)
      nodes.push((x, y))
    }

    // Draw edges from center to all outer nodes
    for i in range(1, n + 1) {
      line(nodes.at(0), nodes.at(i), stroke: 1pt)
    }

    // Draw all nodes
    for (i, pos) in nodes.enumerate() {
      circle(pos, radius: 0.3, fill: node_color_function(i), stroke: 1pt)
      content(pos, node_label_fn(i), anchor: "center")
    }
  })
}

// Function to draw a graph from an adjacency matrix
#let draw-graph-from-adj-matrix(
  adj-matrix,
  positions: none,
  node_label_fn: i => text(str(i)),
  node_color_function: i => white,
  node-radius: 0.45,
  stroke: (thickness: 1pt), // Changed to dictionary format
) = {
  canvas({
    import draw: *

    // Number of nodes (assuming the matrix is square)
    let n = adj-matrix.len()
    if n == 0 or adj-matrix.at(0).len() != n {
      panic("Adjacency matrix must be square")
    }

    // Determine node positions
    let node-positions = if positions == none {
      // Default: Circular layout
      let radius = calc.max(2, calc.sqrt(n)) / 2 // Adjust radius based on number of nodes
      let center = (0, 0)
      let positions = ()
      for i in range(n) {
        let angle = 360deg / n * i
        let x = radius * calc.cos(angle)
        let y = radius * calc.sin(angle)
        positions.push((x, y))
      }
      positions
    } else {
      // Use provided positions
      if positions.len() != n {
        panic("Number of positions must match number of nodes")
      }
      positions
    }

    // Draw edges based on the adjacency matrix
    for i in range(n) {
      for j in range(i + 1, n) {
        // Only upper triangle for undirected graph
        if adj-matrix.at(i).at(j) == 1 {
          line(node-positions.at(i), node-positions.at(j), stroke: 1pt)
        }
      }
    }

    // Draw nodes
    for (i, pos) in node-positions.enumerate() {
      circle(pos, radius: node-radius, fill: node_color_function(i), stroke: 1pt)
      content(pos, node_label_fn(i), anchor: "center")
    }
  })
}

= Introduction <sec:1>

Placing the task of learning under a mathematical formalism has
been the aspiration of different groups of researchers for various reasons:
philosophers, logicians, information theorists, researchers studying
AI alignment, and others.

// The explosive commerical success of neural networks attributes itself
// to advancements amongst the empricists, and in the increasing power of
// computation -- not to general frameworks developed by theorists.
//
// For this reason, the majority and well financed part of the community
// has focused on developing neural networks architectures using amorphous
// notions of insight and intuition, and testing their hypothesis by building
// their models and deploying them at large.

// This has worked exceedingly well the last 30 years. More damning to learning
// theorists is the fact that billion parameter neural networks
// have been able to generalize, contradicting some natural interpretations
// of VC dimensionality,
// @zhangUnderstandingDeepLearning2017 @kruegerDEEPNETSDONT2017
// @vapnikMeasuringVCdimensionLearning1994.

Historically, mathematicians used objects from statistics to construct
a formal framework for learning. Simultaneously, a handful of mathematicians
chose to couch learning in the language of group theory, using representation
theory of finite groups @fultonRepresentationTheory2004 to realize models on Turing machines
@woodRepresentationTheoryInvariant1996 @kondorGroupTheoreticalMethods2008.

On one hand, the theory of finite groups is of interest to researchers building models
on graphs because a graph, which is a set of vertices and a collection of
binary relations, is much like a group. On the other hand, for those studying
group actions, a group action on a graph can be readily interpreted, motivating
those neural network theorists to first try to apply their formalism on various types of
graph learning problems.

In an attempt to create a group based formalism for learning, graphs
are an attractive object of which to first study because the object suggests
that actions on them respect certain constraints so loudly and so
naturally, that researchers consider the constraints to be axiomatic.
In particular, given a representation $A in {0,1}^(n times n)$ of a graph
$cal(G)$, permuting the labels of each node the same graph, and so
functions we wish to construct should be insensitive to this augmentation.
This can be formalized by saying that given our graph $cal(G)$, we want
$f(cal(G)) = f(sigma dot.op cal(G))$ for any permutation $sigma in SS_(n)$.

To achieve this invariance, designers

In the most abstract sense, given a graph $cal(G)$,
researchers wish to construct a function $phi$ so that $phi(cal(G))$ yields
something useful. We want to define $phi$ as a composition of a finite number of layers
$ell$

$
  phi = phi^(ell) compose phi^(ell - 1) ... phi^(2) compose phi^(1).
$<base_phi>



To motivate the group theoretic formalism we expound in this paper,
let's consider problem of designing a function that takes a graph $cal(G)$
in the form of a star, and consider how we want to design such a function.

#example[
  We define a _star graph_ to be a graph $cal(G)$ with $n$
  vertices, where the first $n - 1$ have an edge to the $n$th vertex,
  and no other edges exist in the graph.We wish to construct a
  function $phi$ that indicates whether or not
  a graph is a star.

  Two star graphs are shown in @fig1.

  // Place figures side by side using a grid
  #let fig1() = figure(
    caption: [ The Original Star Graph ],
    supplement: [Figure],
    draw-star-graph(6),
  )

  #let _s7 = i => {
    if i == 0 {
      return text(str(6))
    } else if (i == 6) {
      return text(str(0))
    } else {
      return text(str(i))
    }
  }

  #let fig2() = figure(
    // caption: [The Star Graph under $sigma = $ in $S_(7)$, which is not an automorphism],
    caption: [The Star Graph under $sigma = (0 & 6)$],
    supplement: [Figure],
    draw-star-graph(6, node_label_fn: _s7),
  )
  #let padding = 2em
  #subpar.grid(
    columns: (1fr, 1fr),
    inset: (top: padding, left: padding, right: padding, bottom: padding),
    gutter: 20pt,
    [#fig1() <fig1.a>],
    [#fig2() <fig1.b> ],
    label: <fig1>,
    caption: [A star graph under different labellings],
  )

  Say our function $phi$ was first given the graph in @fig1.a and correctly
  classified it. Now we relabel the nodes in our graph by swapping the label
  on node 0 with the label on node 6. The relabel graph is shown in @fig1.b.

  We want our function to still classy the graph as a star graph.
  In fact, no matter how we label the graph's nodes,
  we still want our function to classify the graph as a star graph.

] <example1>


// Recall that designers always construct $phi$ as a composition of
// some finite number of layers
// $phi = phi^(ell) compose phi^(ell - 1) compose ... compose phi^(1)$
// (see @base_phi).
// It is easy to see that a composition of permutation invariant functions is
// permutation invariant to any permutation.
// Therefore, one clear way to construct $phi$
// so that $phi$ is permutation invariant, is to simply to design layers
// that are permutation invariant as well. However, this severely
// limits the number of functions designers can choose construct, as
// treated formally in @maronInvariantEquivariantGraph2018.
// Fortunately, using the observation that the composition of equivariant functions
// is equivariant, designers were able to captures a wider class of permutation
// invariant models by ensuring the first $ell - 1$
// layers were equivariant _to the *entire* input graph_
// $cal(G)$, and then ensuring the last layer was invariant to $cal(G)$.


= Background <sec:2>

Designers of graph neural networks want their functions
to treat a graph with one choice of node labels the same
as the graph under another choice of vertex labels.
Designers initially achieved this by ensuring that the first
$ell - 1$ layers were equivariant to permutations and then
then ensured the last layer was invariant. This because
most neural network $phi$ are composed of as a series of layers
$phi = phi^(ell) compose phi^(ell -1) compose ... compose phi^(1)$,
and it is known that the composition of two equivariant functions is
equivariant, so networks $phi$ invariant to permutations of their input graphs
can be constructed a series of equivariant layers, until the last layer is made
to be invariant.

However, just as the GNN community realized historically
that invariant internal layers
could be swapped for more expressive equivariant layers, it has recently
been shown @thiedeAutobahnAutomorphismbasedGraph2021 that,
in order to construct a
neural network $phi$ that is _invariant to the entire input graph $cal(G)$_,
internal layers of a GNN $phi^(i)$ need not be equivariant to the entire
input graph $cal(G)$, but rather need just be equivariant to the
automorphism group of a template graph $cal(T)$.

As we will see in @sec:AutobahnExample,
the template graph $cal(T)$ is chosen based on the problem
domain. And so, designers using Autobahn based neural networks
need to enumerate and manually choose the proper template graph.
Schur Nets @zhangSchurNetsExploiting2025
was introduced to address this drawback in Autobahn. Schur Nets uses
a spectral approach construct a Autobahn-style neural network. This allows
Schur Nets to avoid having to explicitly state the template graph automorphism.

While Schur Nets approach to automorphism sub-graph equivariance
avoids the overhead imposed by the purely group theoretic approach,
Schur Nets' does not necessary yield an irreducible representation for each
graph. Therefore, Schur Net-based constructions of equivariance do not
necessarily yield the most generalizable forms of automorphism (Autobahn-type)
neural networks. Furthermore, the extent of the gap between Schur Nets
and group theoretic based automorphism networks remains an open question and
area of research.

One of the primary challenges to exploring the expressivity gap between
Autobahn
and Schur Nets is that Schur Nets is not amendable to
Weisfeiler-Lehman @huangShortTutorialWeisfeilerlehman2021 tests of expressivity.
In fact, the authors of Schur Nets intuit that #quote(
  attribution: <zhangSchurNetsExploiting2025>,
)[...the ability to learn certain features (such as count cycles of certain sizes
  or learn some function related to specific functional groups)
  might be a better criterion ... [than WL type tests].
  It’ll be an interesting research direction to design suitable criteria for the expressive power of such higher order MPNNs in general.]

This notion, that measuring the ability of GNN to count structures
like sub-graph structures, has been recognized recently by other researchers
as well, and has been formalized by @zhangCompleteExpressivenessHierarchy2023
in a new framework for expressivity measurement, termed
_Homomorphism Expressivity_. This initial work established Homomorphism
Expressivity for sub-graph counting GNNs. Therefore, such a framework would
_not_ be directly applicable to Schur Nets, because it is a spectral invariant
based GNN. However, following up on that work, Homomorphism Expressivity
was extended to spectral invariant GNNs such as Schur Nets
@gaiHomomorphismExpressivitySpectral2024, giving us the tools necessary
to compare pure group theoretic models (Autobahn) with spectral models
(Schur Nets) using this framework.

// It’ll be an interesting research direction to design suitable criteria for the expressive power of such higher order MPNNs in general.

In this paper we seek to kick of the theoretical exploration of this gap.
First, we expound both the Autobahn and Schur Nets construction by formulating
both approaching on example graphs. Not only does this formulation
demonstrate this author's understanding and faculty with both frameworks
#footnote[Facetious], but also suggests a intuitive understanding of both
the characters of the frameworks, which we will enforce by making qualitative
observations of both behaviors.

With these preliminaries and intuitions established, we finally get to the main
construction of this paper, which is a formal treatment and classification
of both frameworks under Homomorphism Expressivity
@gaiHomomorphismExpressivitySpectral2024. First, we show that, in the language
of _Homomorphism Expressivity_, Schur Nets can be described as a
_spectral invariant graph neural network_, and that Autobahn can be
classified as a _sub graph counting graph neural network_.
Next, using the main result from @gaiHomomorphismExpressivitySpectral2024,
we compute Schur Nets' Homomorphism Expressivity and compare it to Autobahn.


= Preliminaries <sec:>

In this paper, if we refer to a group action of the symmetric group on a
$k$-ranked tensor without mentioning the particular action, assume it is the
action defined below, dubbed _the permutation action_.
#definition(name: [Permutation action on $k$th order tensors])[
  Let $upright(bold(T)) in RR^(n^(k))$ be $k$th order (rank) tensor.
  Let $sigma in SS_(n)$ be a permutation in the symmetric group $SS_(n)$.
  Then we say that the _action of the permutation group
  $SS_(n)$ on $upright(bold(T))$_, also
  called the permutation action on $upright(bold(T))$, is
  $
    sigma dot.op upright(bold(T)) \
    [sigma dot.op upright(bold(T))]_(i_(1),...i_(k))
    = [upright(bold(T))]_(sigma^(-1)(i_(1)),...,sigma^(-1)(i_(k)))
  $
] <def:sga>

#remark[
  For a given graph with $n$ nodes, represented by the rank two tensor
  $A in {0,1}^(n times n)$, we say that $SS_(n)$ permutes
  the graph by the action defined in @def:sga.
  Conceptually, permuting the graph $A$ by @def:sga can is
  equivalent to relabelling the nodes of the graph.
]

Graph neural network designers want their models to be
invariant to all permutations on the input graph $cal(G)$.

#definition(name: "Permutation Invariance")[
  Let $f: RR^(n^(k_(1))) -> RR^(n^(k_(2)))$ be a function.
  We say that $f$ _is permutation invariant to any permutation_ if,
  for any input $A^(n^(k_(1)))$,
  $
    f(sigma dot.op A) = sigma dot.op f(A)
  $
  for any $sigma in SS_(n)$.
]<permutation-invariant>


#remark[
  Note,
  I am not sure exactly how you define permutation equivariance if $f$,
  represented by a matrix, was not square
  . For instance if
  $
    f = L^(m times n)
  $
  and $m != n$, then $sigma dot.op L$ cannot be defined using @def:sga.
  $dot.op$.
]

#definition(name: "Permutation Equivariance")[
  Similarly, we say that $f: RR^(n^(k_(1))) -> RR^(n^(k_(2)))$ is
  _permutation equivariant_
  We say that $f$ _is permutation invariant to any permutation_ if,
  for any input $A^(n^(k_(1)))$,
  $
    f(sigma dot.op A) = sigma dot.op f(A)
  $
  for any $sigma in SS_(n)$.
]<permutation-equivariant>

#corollary(name: "An Equivalent Definition of Permutation Equivariance")[
  Note that the permutation action of $SS_(n)$ given by @def:sga,
  immediately implies
  a homomorphism between $SS_(n)$ and $"GL"(n, RR)$. This can be used to redefine
  permutation equivariance when considering linear functions.
  Let $f: RR^(n) -> RR^(n)$, so $f$ is in $"GL"(n, RR)$ and can be written
  as the matrix $L in RR^(n times n)$. Next, let $rho: SS_(n) -> "GL"(n, RR)$,
  then we can say that $f in "GL"(n, RR)$ is permutation equivariant if and only
  if
  $
    rho(sigma) star f = f star rho(sigma)
  $ for any $sigma$,
  where $star$ is the binary operation of the group $"GL"(n, RR)$. Note that
  $star$ is just matrix multiplication if we represent $f$ and $rho(sigma)$
  with matrices. One can also that that $f$ is permutation equivariant
  to $SS_(n)$ if $f$ _commutes_ with every element of $SS_(n)$.

  In general, I believe a group action $phi : G times cal(X) -> cal(X)$ always
  implies a homomorphism between $G$ and the group of functions which map
  $cal(X)$ to $cal(X)$ under composition (sometimes termed the automorphism
  group). It is sometimes useful to think of permutation equivariance for a
  given internal layer $phi^(i)$ this way
  as it generalizes its particular input.
]


#definition(name: [Automorphism of a graph $A in {0,1}^(n times n)$])[
  Let $cal(G)$ be a graph with $n$ nodes. Let the adjacency matrix
  $A in M(2, RR)$ be $cal(G)$'s representation.
  Given the representation $A$, consider the set of permutations
  in $SS_(n)$, that, when acting on $cal(G)$ via @def:sga leave $cal(G)$
  unchanged. That is the set
  $
    {sigma in SS_(n) bar.v sigma dot.op A = A}.
  $
  We denote this set of permutations by $"Aut"(cal(G))$, that is
  the set of permutations that leave $cal(G)$ unchanged.
  #example(name: [4 node graphs])[
    It was not initially clear to me why one would be interested in
    the Automorphism group of a graph at all.
    Furthermore, For any given graph $A in {0, 1}^(n times n)$, that
    $SS_(n)$ was not always essentially e $"Aut"(A)$. Clearly though $"Aut"(A) != SS_(n)$.
    We can see this by considering the graph
    #let adj-matrix-raw = (
      (0, 0, 1, 0),
      (0, 0, 1, 0),
      (1, 1, 0, 1),
      (0, 0, 1, 0),
    )
    And then considering the permutation $sigma = (4 #h(.4em) 1) in SS_(n)$.

    We note that $sigma dot.op A != A$, and so $sigma in.not SS_(n)$.

    #let p-1-4 = ((0, 0, 1, 0), (0, 1, 0, 0), (1, 0, 0, 0), (0, 0, 0, 1))

    #let sigma-adj-matrix = (
      (0, 1, 1, 1),
      (1, 0, 0, 0),
      (1, 0, 0, 0),
      (1, 0, 0, 0),
    )
    $
      A = mat(delim:"[", ..#adj-matrix-raw) #h(1em) "vs." #h(1em)
      sigma dot.op A = mat(delim:"[", ..#sigma-adj-matrix)
    $<A>

    #let fig1 = figure(
      // caption: [The Star Graph under $sigma = $ in $S_(7)$, which is not an automorphism],
      caption: [The Graph $A$ Given By @A],
      supplement: [Figure],
      draw-graph-from-adj-matrix(adj-matrix-raw, node_label_fn: i => text(str(i + 1))),
    )
    #let relabel = i => {
      if i == 0 { return text(str(3)) }
      if i == 2 { return text(str(1)) }
      return text(str(i + 1))
    }
    #let fig2 = figure(
      // caption: [The Star Graph under $sigma = $ in $S_(7)$, which is not an automorphism],
      caption: [The Graph $sigma dot.op A$],
      supplement: [Figure],
      draw-graph-from-adj-matrix(adj-matrix-raw, node_label_fn: relabel),
    )
    #let padding = 2em
    #subpar.grid(
      columns: (1fr, 1fr),
      inset: (top: padding, left: padding, right: padding, bottom: padding),
      gutter: 20pt,
      [#fig1],
      [#fig2],
      caption: [$A != sigma A$ when $sigma = (3 #h(.4em) 1)$ ],
    )

    Of course, $A$ and $sigma dot.op A$ _look_ the same, and that is because
    their node-edge relations are the same, so invariance over $SS_(n)$ is
    typically what we want. _However_, just as $SS_(n)$ captures
    symmetries on the entire graph $A$, automorphisms,
    capture symmetry up to _sub-graphs_, so it is
    a finer filter.
    What I mean is that, notice how the nodes in
    sub-graph ${(v_(3), v_(4)), (v_(3), v_(2))}$ in $A$
    and the nodes in the corresponding sub-graph in $sigma dot.op A$,
    i.e. ${(v_(1), v_(2)), (v_(1), v_(4))}$ are not the same across the two
    sub-graphs ($v_(3)$ was swapped out for $v_(1)$).

    Automorphisms of $A$, such as $sigma' = (4 #h(1em) 1)$ would ensure
    that the nodes involved in the sub-graph
    ${(v_(3), v_(4)), (v_(3), v_(2))}$ in $A$ would remain the same.
    So the automorphism group of $A$, $"Aut"(A)$ can be thought of as
    the set of relabellings that leave the sub-graphs of $A$ in tact.
    #let relabel = i => {
      if i == 3 { return text(str(2)) }
      if i == 1 { return text(str(4)) }
      return text(str(i + 1))
    }

    #let fig3 = $sigma' dot.op A = (4 #h(1em) 1) dot.op A = mat(delim:"[", ..#adj-matrix-raw)$
    #let fig4 = figure(
      supplement: [Figure],
      draw-graph-from-adj-matrix(adj-matrix-raw, node_label_fn: relabel),
    )
    #subpar.grid(
      columns: (1fr, 1fr),
      inset: (top: padding, left: padding, right: padding, bottom: padding),
      gutter: 20pt,
      [#fig3],
      [#fig4],
      caption: [The Automorphism $sigma' = (4 #h(1em) 1)$ Preserves The Sub-Graph Structure of $A$],
    )
  ]
]

Autobahn works by taking the user-given template graph and classifying
functions that are equivariant to the entire input graph while judiciously
breaking symmetry with the template graph's automorphism group
(see @psuedoAuto). This has advantages and drawbacks, as discussed in
@SummarizingAutobahnExample.

In contrast, Schur Nets take a spectral approach. In particular,
Schur Net layers are described by the Corollary proved in their work.
This Corollary gives the core characterization of a non-higher order
Schur Net.



In the next section we compare and constrast how Autobahn and Schur Nets
how the models compute on a pendant graph with
a 5-cycle, in precise detail. This will give us the conceptual basis
to give a formal analysis of the expressivity of both frameworks.
Moreover, it will suggest that the expressivity of both GNNs frameworks
is best measured via sub-graph counting, and as a corollary why WL tests
are not a satistifactory measure of expressivity for these frameworks.
This will lead us to our major contribution, which is providing a
precise characterization of Schur Nets and Autobahn within the measurement
framework of Homomorphism Expressivity.



= Exemplifying The Expressivity Gap Between Schur Nets and Autobahn <sec:Main1>

With its preliminaries established,
the first main contribution of this report is to show in full detail
how Autobahn @thiedeAutobahnAutomorphismbasedGraph2021 and
Schur Nets @zhangSchurNetsExploiting2025 handle a certain graph.

The graph we will be applying Autobahn and Schur Nets to is
a labelled 5 cycle graph with a pendant edge.

#let pastel-blue = rgb(63, 206, 241)
#let pastel-green = rgb(180, 242, 167)
#let pastel-yellow = rgb(255, 249, 176)

#let A_e_main = (
  (0, 1, 0, 0, 1, 1),
  (1, 0, 1, 0, 0, 0),
  (0, 1, 0, 1, 0, 0),
  (0, 0, 1, 0, 1, 0),
  (1, 0, 0, 1, 0, 0),
  (1, 0, 0, 0, 0, 0),
)
#let node_color_function(i) = {
  if (i + 1 < 6) {
    return pastel-blue
  } else {
    return pastel-yellow
  }
}

$
  A = mat(delim:"[", ..#A_e_main)
$<eq:1>

#figure(
  supplement: [Figure],
  caption: [The Graph Given By The Adjacency Matrix In @eq:1],
  draw-graph-from-adj-matrix(A_e_main, node_label_fn: i => text(str(i + 1)), node_color_function: node_color_function),
)<fig:1>
#remark[
  Before we continue, we make a few key observations
  about our chosen graph @eq:1.
  - The graph has a cycle of length $5$, $(v_(1), v_(2), v_(3), v_(4), v_(5), v_(1))$
  - $v_(6)$ is not in the cycle and the edge $(v_(6), v_(1))$ is why we call this graph a
    "pendant".
  - We've colored (labelled) the nodes $v_(i)$ that belong to the cycle in blue,
    the pendant node ($v_(6)$) that does not belong to the cycle in yellow.
  // , and the ambassador node
  // $v_(1)$ that belongs to both sub-graphs in green.
  - Clearly the colors and the pendant node introduce asymmetry.
]


== Autobahn's Behavior On The Pendant Graph @eq:1 <sec:AutobahnExample>
#remark[For simplicity, I may gloss over the promotion and narrowing
  aspects of Autobahn's algorithm. Although those are the essential contribution,
  I am primarily interested in treating group theoretic automorphism based networks,
  as given by @dehaanNaturalGraphNetworks2020]
We now observe how Autobahn works on @fig:1.

=== Step 1: Choose The Template Graph $cal(T)$ <subsubsec:>

Our first step is to choose our template graph $cal(T)$ that aligns
with our problem domain. Autobahn is designed to recognized the sub-graphs
of the input graph $A$ isomorphic to this sub-graph $A$ and break permutation equivariance across sub-graph boundaries, which gives a more expressive class of neural networks than those whose neurons are permutation equivariant to all of $SS_(n)$ (i.e MPNNs).
Notice that we labelled the nodes with colors corresponding to the selection
of our template graph.

Notice the 5-cycle in our node color labelling, so in line with that
let us choose the template graph $cal(T) = C_(5)$.

#let At = (
  (0, 1, 0, 0, 1),
  (1, 0, 1, 0, 0),
  (0, 1, 0, 1, 0),
  (0, 0, 1, 0, 1),
  (1, 0, 0, 1, 0),
)

In particular, the adjacency matrix of $cal(T)$ is given by
$
  A_(cal(T)) = mat(delim:"[",
  ..#At
  ).
$

The automorphism group of $A_(cal(T))$ is
$
  "Aut"(A_(cal(T))) = D_(5)
$
The dihedral group of 5 elements,
$D_(5)$ is the set of rotations and reflections. Visually this makes sense,
as rotating or reflecting this sub-graph should not change it.

#figure(
  supplement: [Figure],
  caption: [The Template Graph $cal(T)$, A Sub-Graph of $A$],
  draw-graph-from-adj-matrix(At, node_label_fn: i => text(str(i + 1)), node_color_function: i => pastel-yellow),
)

Now that we have chosen our template graph, Autobahn starts.

=== Step 2: Determine The Sub-graphs Isomorphic To $C_(5)$ <subsubsec:>

- Objective: To find the sub-graph of $A$ that are isomorphic to the template
  graph $cal(T) = C_(5)$. In other words, find all sub-graphs in our input graph
  that contain 5-cycles.
- How: Find all $sigma in SS_(6)$ so that
  $
    sigma dot.op A = A_(cal(T)).
  $

=== Step 3: Construct A Function That Is Equivariant to $"Aut"(C_(5)) = D_(5)$ <psuedoAuto>
Let $f^(ell - 1)_(i)$ denote the feature vector form the previous layer ($ell - 1$)
corresponding to the $i$th vertex. For us, we will consider the first internal layer
and let
$
  f^(0)_(i) = "deg"(v_(i)) \
  f^(0) &= (f^(0)_(1), ... , f^(0)_(6)) \
  &= (3, 2, 2, 2, 2, 1)
$

// Now, for each 5-cycle sub-graph, define a function that is equivariant
// to automorphisms. Such functions should compute features that are only local
// to the sub-graph. For our case, the only 5-cycle is $v_(1),...,v_(5)$.
// Let the altered feature vectors on the 5-cycle be
// $
//   f'^(0)_(i) = ("deg"(v_(i)), "is-adjacent-to-pendant")
// $ for $i = {1, ..., 5}$
//
// So we have
// $
//   f'^(0) = ((2, 0), (2, 0), (2, 0), (2, 0), (2,0))
// $
//
// #remark[
//   To emphasize, we are only computing $f'$ on the sub-graph $C_(5)$,
//   hence $f'^(0)_(1) = (2, 0)$, even though globally it is $(2, 1)$
// ]
//
//
Let $f'^(0)$ be the feature vector but only on the 5-cycle
$
  f'^(0)_(i) = ("deg"(v_(i)))
$ for $i = {1, ..., 5}$

We construct our sub-graph neuron so that it is pseudo-equivariant $"Aut"(C_(5))$ if we
only compute the features on the sub-graph, but in actuality is not equivariant
to $"Aut"(C_(5))$. We can construct our sub-graph neuron to be do this by having our sub-graph neuron convolve
over all permutations in $D_(5)$
$
  f'^(1) = sum_(sigma in D_(5))^() sigma dot.op w * f'^(0)
$<eq:psuedo>
for some learnable weight $w$.

Notice that, conceptually, if we only compute $f'^(0)$ with respect to
the 5-cycle sub-graph, then $f^(0)_(1) = "deg"(v_(1)) = 2$ and @eq:psuedo
is indeed equivariant to $D_(5)$. On the other hand, if we compute
$f'^(0)$ with respect to the entire graph $A$, then
$f^(0)_(1) = "deg"(v_(1)) = 3$, and @eq:psuedo is not actually equivariant
to $D_(5)$. This is the crucial insight. In essence, Autobahn breaks permutation
equivariance to $D_(5)$ of global features of the graph, while maintaining
permutation equivariance to $D_(5)$ of local features of the graph.

In other words
$
  f'^(0) = (2,2,2,2,2) & "When on considered on the isoloated subgraph" \
  f'^(0) = (3,2,2,2,2) & "in actuality. I.e. with respect to the entire graph."
$

=== Step 4: Apply Non-Linearity And Add $f^(1)_(6)$ <subsubsec:>
Finally, we construct the output layer

$
  f^(1) = f'^(1) + f^(1)_(6),
$ where $f'^(1)$ is computed with
$f'^(0) = ("deg"(v_(1)), "deg"(v_(2)), "deg"(v_(3)), "deg"(v_(4)), "deg"(v_(5)) = (3,2,2,2,2)$

== Summarizing Autobahn <SummarizingAutobahnExample>

In summary, Autobahn requires you to choose a template graph $cal(T)$
that reflects the input graph's structures and problem domain nicely.
For instance, we could have chosen $cal(T) = P_(3)$, that is, all paths
of length $3$ in our input graph $A$.

- Finds the sub-graphs isomorphic to $cal(T)$ on $A$.
- Constructs neurons that are permutation equivariant to $"Aut"(A_(cal(T)))$
  with respect the sub-graph
- Incorporates these terms to the neuron's activations on other vertices not in the sub-graph,
  ensuring global equivariance with respect to the graph.

In summary, by ensuring functions on sub-graphs are permutation equivariant to $D_(5)$
*if the features the functions are acting on are computed with respect to the sub-graph*,
Autobahn cleverly breaks permutation equivariance to $D_(5)$ by applying
this function on $f'^(0)$ evaluated on the entire input graph.

One apparent drawback of Autobahn is that it requires
users to select the template sub-graph. On the other hand, that requirement
can actually be considered advantageous as it gives domain practitioners flexibility
to choose the template graph that is important to their domain. For instance,
chemists applying GNN's on molecules can choose their template graph that is
isomorphic to highly functional sub-structures of the molecule
@kongMoleculeGenerationPrincipal2022.

However, the major drawback of Autobahn is that is requires considering all elements
of the automorphism group in order to achieve equivariance,
via generalized convolution. Moreover, the complexity that arises due
to overlapping sub-graphs isomorphic to the input graph introduces complexities
and computational overhead. Autobahn addresses these issues by introducing
narrowing and promotion,
but it is still a source of complexity. This is discussed in @A:NarrowExplainer.

== How Schur Nets Handles The Pendant Graph <subsec:SchurNetExample>

The construction of a Schur Net neuron is given by the following corollary
proved in their work.

#corollary(name: [Schur Net Neuron (Zhang, Xu & Kondor) @zhangSchurNetsExploiting2025])[
  Consider a GNN on the input graph $cal(G)$, represented by $A$. Let $cal(n)_(F)$
  be a neuron that operates on sub-graph $F$ of $cal(G)$.
  Let input sub-graph $F$ (and its features) be represented by
  $T in RR^(m)$. Let $L$ be the Laplacian of $S$, $U_(1), ...,U_(p)$
  be the eigenspaces of $L$, and $M_(i)$ be an orthogonal basis
  for the $i$th eigenspace stacked into a $RR^(n times dim(U_(i)))$
  Then for any collection of learnable weight matrices
  $W_(1), ...,W_(p) in RR^(a times b)$
  $
    phi : T --> sum_(i=1)^(p)M_(i)M^(T)_(i) T W_(i)
  $
  is a permutation equivariant operation.
]<schur-cor>

Like Autobahn, Schur Net's allows the designer to choose the sub-graph
$F$ (see @schur-cor).
Therefore, we choose $F = C_(5)$, inline with the prior section.

Next, we compute the Laplacian of $F$. For convenience, recall that the adjacency
matrix of the input graph and the 5-cycle template sub-graph stated in
@eq:1 is given by

#let math_no_number = math.equation.with(
  block: true,
  numbering: none,
)
#math_no_number([
  $
    A &= mat(delim:"[", ..#A_e_main) "(Input Graph)"
  $])
and,
#math_no_number([
  $A_(cal(T)) &= mat(delim: "[", ..#At) "(5-Cylcle)".$
])
#let laplacian_F = (
  (2, -1, 0, 0, -1),
  (-1, 2, -1, 0, 0),
  (0, -1, 2, -1, 0),
  (0, 0, -1, 2, -1),
  (-1, 0, 0, -1, 2),
)

Then the Laplacian of $F$ is given by $L = D_(F) - A_(F)$ so
$
  L = mat(delim:"[", ..#laplacian_F).
$

Next, we compute the eigenvalues of $L$. This is known for 5-cycles
@trevisanLecture06.
Let $lambda_(i)$ denote the $i$th eigenvalue.
Then for $i = k + 1$, compute $i = 1,...,5$
$
  lambda_(i) = 2 - 2cos((2 pi k)/5)
$

We also know the eigenvectors are given by the columns of the discrete Fourier
matrix. So the $k$th eigenvector is given by
$
  v^((k))_(j) = 1/sqrt(n) e^((2 pi i k j)/n), #h(.4em) j=0,1,...,n-1, #h(.4em) n = 5.
$

In particular
#let eigenvalues = ()
#for k in (0, 1, 2, 3, 4) {
  let val = 2 - 2 * calc.cos(2 * calc.pi * k / 5)
  eigenvalues = eigenvalues + (val,)
}
#let unique_eigs = array.dedup(eigenvalues)
#let mults = (1, 2, 2) //unique_eigs.map(eig => eigenvalues.filter(x => calc.round(x, digits: 3) == eig).len())
#let eigenvectors = (
  ($frac(1, sqrt(5)), frac(1, sqrt(5)), frac(1, sqrt(5)), frac(1, sqrt(5)), frac(1, sqrt(5))$),
  ($frac(1, sqrt(5)) (1, cos(2 * pi / 5), cos(4 * pi / 5), cos(4 * pi / 5), cos(2 * pi / 5))$),
  ($frac(1, sqrt(5)) (0, -sin(2 * pi / 5), -sin(4 * pi / 5), sin(4 * pi / 5), sin(2 * pi / 5))$),
  ($frac(1, sqrt(5)) (1, cos(4 * pi / 5), cos(2 * pi / 5), cos(4 * pi / 5), cos(4 * pi / 5))$),
  ($frac(1, sqrt(5)) (0, -sin(pi / 5), sin(2 * pi / 5), -sin(3 * pi / 5), sin(4 * pi / 5))$),
)

#figure(
  caption: [The Eigenvalues of The $C_(5)$ Laplacian $L$],
  supplement: [Figure],
  table(
    columns: (auto, auto, auto, auto),
    inset: 10pt,
    table.header(
      [$i$],
      [$lambda_(i)$ of $C(5)$],
      [Multiplicity, $kappa_(i)$],
      [Eigenvectors],
    ),
    ..for (i, (eig, mult)) in unique_eigs.zip(mults).enumerate() {
      let x = eigenvectors.at(i)
      (str(i), str(eig), str(mult), $vec(#x)$)
    }
  ),
)



= A General Characterization Of The Expressivity of Both Autobahn And Schur Nets

The main contribution of this project is to provide a precise characterization
of the expressivity of automorphism based GNNs given by Autobahn and Natural
Graph Networks @thiedeGeneralTheoryPermutation2020 @dehaanNaturalGraphNetworks2020
as opposed to Schur Nets. We are able to do this in general thanks to framework
introduced by Zhang et al. @zhangCompleteExpressivenessHierarchy2023
and in particular for Schur Nets thanks to the recent results from
Zhang and Maron et al @gaiHomomorphismExpressivitySpectral2024.



= Acknowledgements
This work is incomplete. I will send the completed version this weekend, but
I acknowledged that this submission will be the one that is graded.

== TODOs <sec:>

- Transcribe C4 example of 5 node (pendant node makes it clear, but I like comparing it to $SS_(4)$ better)
  from scratch notes but already 1/3 way.
- Transcribe C3 example (my first attempt earlier this week, include it ?)
- Now, gather parallel trees analysis notes for $d = 2$ and $3$. (Too many examples)?
- Now, show exactly how Schur Nets is good at capturing parallel trees up to $d$,
  show autobahn captures symmetries more generally.
  *Schur Nets may miss symmetries in parallel trees after a certain depth.*


