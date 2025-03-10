#import "@preview/lemmify:0.1.8": new-theorems

#let (definition, remark, rules) = new-theorems("theorem_group", ("definition": [Definition], "remark": [Remark]))
#show: rules



= Appendix

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

== How Narrowing And Promotion Work <A:NarrowExplainer>

#remark[
  We omitted details of Autobahn's primary contribution, that
  is, the formalized notions of _narrowing_ and _promotion_.
  This is because we are concerned with Autobahn's sub-graph counting
  abilities, and narrowing and promotion are techniques to reduce the
  computation complexity of achieving automorphism based neurons when graphs
  overlap @dehaanNaturalGraphNetworks2020.

  We constructed our example to be particularly simple, and showed such
  an automorphism based neuron @dehaanNaturalGraphNetworks2020.
  The point of the section was to illustrate, through elementary computation and
  novice language,
  the sub-graph counting abilities
  of automorphism based neuron networks.

  See the appendix @A:NarrowExplainer for an explanation of
  how Autobahn uses narrowing and promotion to reduce the computation
  overhead, which is important when the input graph contains more than 1
  sub-graph isomorphic to the template graph.
]

At any given layer $i$, Autobahn first identifies all the sub-graphs of $A$
that are isomorphic to $cal(A)_(cal(T))$. In our case,
$(v_(1), v_(2), v_(3), v_(4), v_(5))$ is the only such sub graph of $A$.

Next, given we are looking at the first layer,
we need to define an input domain. Let the input to the first layer
be the degree of each node on the feature graph.

Next, for each sub-graph isomorphic to $A$, Autobahn performs _narrowing_.
_Narrowing_ will be described plainly here. The formal definition is given in
the appendix.
_Narrowing_ takes the sub-graph $(v_(i_(1)), ... ,v_(i_(m)))$
and partitions the nodes of the graph into two groups: the important group
$cal(I)_(1) = {i_(1), ... ,i_(k)}$ and the not important group consisting of
the remaining $k - m$ nodes, $cal(I)_(2) = {i_(k+1), ... ,i_(m)}$.
Note that I assumed that the first $1$ through
$k$ indices were the important nodes, but typically narrowing adds the indices
to the important group which _overlap_ with a another sub-graph.
Let us call such nodes the "ambassador" nodes.

In our example, narrowing operates on our sub-graph ${v_(1), ... ,v_(5)}$.
It then adds node $v_(1)$ to the important group $cal(I)_(1) = {i_(1)}$
and puts the remaining $2, ... ,4$ indices in the not important group
$cal(I)_(2) = {i_(2), ... i_(4)}$. Finally, the narrowing procedure is applied
to our sub-graph neuron, which makes our sub-graph neuron only depend on the
important nodes in $cal(I)_(1)$. See the appendix @def:narrowing for the
formal definition of narrowing.

Similarly to how narrowing is done, then _promoting_ is done to the neuron,
which takes the narrowing activations and spreads them out to all the
$m$ nodes in the sub-graph that this neuron is working on.

We won't go into narrowing or promotion in too much detail, but we can provide
a sketch of how to ensure that our neuron $cal(n)$ is equivariant to $"Aut"(A_(cal(T)))$
and also equivariant to all of $A$ in general.

For example, in our case let the input feature vectors be
$f_(1) = "deg"(v_(1)) = 2, f_(2) = "deg"(v_(2)) = 2 = ... = f_(5)$.
Notice that $f_(1) = 2$, because we are only considering degrees within the
sub graph $v_(1),...v_(5)$.

Now, we can ensure equivariance of our function $cal(n)$ on this 5-tuple
with respect to $D_(5)$, by convolving over the element of $D_(5)$.
$
  D_(5) = sum_()^()
$


Now, in order to account for $v_(1)$'s connection
to $v_(6)$, we redefine the feature vectors $f_(i)$ to include a indicator
variable saying if the node is adjacent to the pendant node $v_(6)$.

$
  f_(1)=("deg"(v_(1)), 1) = (2, 1) #h(2em) f_(2) = ("deg"(v_(1))), 0) = (2, 0)
  = f_(2) ... = f_(5)
$



