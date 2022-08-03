# Assignment 4: Interpreters and Proofs

## Quick Links:

- [Part 1: An Environment-based Interpreter](#part-1-environment-based-evaluator)
- [Part 2: Proofs of Correctness](#part-2-program-correctness)

## Objectives

In this assignment, you will develop an environment-based interpreter to replace
the substitution-based interpreter defined in class. You will also practice
proving your functional programs are correct. You will do this assignment
individually.

Note: You can do Parts 1 and 2 in either order (or switch back and forth).

## Getting Started

You should see the following files in this repository:
- A collection of `.ml` files. You will edit three of these. Others are there
    for reference or as libraries.
- A collection of `.mli` files. These are interfaces that describe what
    functions the corresponding `.ml` file must have.
- A `Makefile` to simplify building the main program from its many sources.
- An `.ocamlinit` file to load the appropriate files in to the OCaml toplevel if
    you use it. Before starting the toplevel, you will have to compile your
    binaries.
- `proofs.txt`, which contains part 2 of the assignment.
- `signature.txt`: You will record your sources here.

A few important things to remember before you start:
- This assignment is to be done individually.
- Make sure that the functions you are asked to write have the correct names and
    the number and type of arguments specified in the assignment. Programs that
    do not compile will be subject to penalties on top of regular deductions.
- In this problem set, it is important to use good style (style will factor in
    to your grade). Style is naturally subjective, but the
    [COS 326 style guide](https://www.cs.princeton.edu/courses/archive/fall22/cos326/style.php)
    provides some good rules of thumb. As always, think first; write second;
    test and revise third. Aim for elegance.

## Part 1: Environment-based Evaluator

In class, we developed a substitution-based interpreter in OCaml. While
substitution makes for a good theoretical model of how OCaml programs evaluate,
practical implementations use an environment-based model of execution.
Fortunately, the two models coincide, so you can safely use substitution to
reason about your programs while your interpreter uses environments to implement
them.

In this part of the assignment, you will implement an environment-based
interpreter for a simplified OCaml-like language (let's call it MiniML). In this
repository, you should find the following files:
- `Syntax.ml`: The datatype that defines the abstract syntax of the language.
    The language contains integers, pairs, lists, and possibly-recursive
    functions. This file also contains a definition of environments and a few
    small functions you must complete.
- `EvalSubst.ml`: A call-by-value, substitution-based interpreter. We have
    partially implemented a substitution-based interpreter for you. This is to
    give you a (partial) reference implementation that you can look at and to
    ensure that you understand the semantics of recursive functions, variables,
    let expressions, etc. **You do not have to implement any more of this
    interpreter!** (You may for fun, of course.)
- `EvalEnv.ml`: A call-by-value, environment-based interpreter. In this
    interpreter, variable bindings are stored in an environment. When we
    encounter a variable in our code, we look up the value of the variable in
    the environment. In addition, to evaluate a function definition, we create a
    closure, which is a pair of the recursive function definition and its
    environment.
- `EvalUtil.ml`: A couple of utilities shared between both the substitution-
    based interpreter and the environment-based interpreter.
- `Testing.ml`: A small collection of test cases. You will have to edit this
    file to add a few additional test cases (and then as many more as you want
    to test your code).
- `Printing.ml`: Some pretty-printing routines. You do not have to touch this
    file.
- `Main.ml`: A driver that runs the test cases. It is set up to test `EvalEnv`.
    If you would like to test `EvalSubst`, you only need to change one line.

### Prelude

It is a good idea to begin by familiarizing yourself with the code before you
start writing any new code yourself.
- Start by looking at `Syntax.ml`. That is the place where we define the
    datatype for the language. Bring questions about how the various elements of
    the language work to precept.
- Next, look at some of the test cases in `Testing.ml`. Those show you how to
    use the data types to construct example programs. Even though the
    substitution-based interpreter is incomplete, you should be able to execute
    a few of the examples, such as `fact4`. Try it. The examples also help show
    you how to use pairs and lists. If you aren't sure how some of the elements
    of the language (like pairs or lists) should be structured or can't figure
    out how some of the examples we have given you work, ask in precept, on Ed,
    or in office hours.
- Next, look at some of the code in `EvalSubst.ml`. That code will illustrate
    the basic structure of a (substitution-based) interpreter. Your environment-
    based interpreter will be a little different, of course.

### Part 1.1

Your main task is to implement the environment-based interpreter. To do this,
you will initially have to modify 2 files:
- In `Syntax.ml`, fill in the small definitions of `lookup` and `update`. (See
    `Syntax.ml` for a description of what they should do.)
- In `EvalEnv.ml`, examine `is_value`. This defines the elements of the language
    that are values. Next, look at `eval_body`, which is the bulk of the
    interpreter. We have given you 1 case of the interpreter: how to evaluate
    variables. That case simply looks up a variable in the current environment.
    You should not change this case. The other key cases are:
    - The case for `Rec`. `Rec` is the definition of a function, which might be
        recursive. In this case, you will have to return not a `Rec` (like in
        the subsitution-based interpreter), but instead a `Closure`, which
        packages the components of the function definition up with an
        environment.
    - The case for function application. We will let you figure out what to do
        there.

    Of course, you will also have to fill in cases involving pairs, lists and
    match statements.

### Part 1.2

In `Testing.ml`, we ask you to create several specific new test cases. Please
see that file and create the new functions that are requested. (Of course, you
might want to do this while writing and testing your interpreter above.) You may
also create as many more test cases as you like.

### Part 1.3

In functional programming language implementations, it is important to optimize
the size of the closures that are created. The most na&iuml;ve thing one can
do when creating a closure is to put ALL variables in the current execution
environment into the closure's environment. However, any given function only
requires access to its *free variables*. For a refresher on free and bound
variables
[read this note](https://www.cs.princeton.edu/courses/archive/fall22/cos326/notes/evaluation.php).

Some key examples:
- expression: `x + 2`

    free variables: `x`
- expression: `let x = 3 in x + 2`

    free variables: none (`x` is bound by the `let` statement)
- expression: `rec f x = x + y`

    free variables: only `y` (`x` is bound as a function parameter)
- expression: `closure [y=3] f x = x + y`

    free variables: none (`x` is bound as function parameter, `y` is found in
    environment)

The environment that a `Rec` is evaluated with to form the closure could have
many superfluous bindings that can be *pruned*, including duplicate bindings of
the same variable or variables that do not appear in the function. Revise your
implementation of the `Rec` case of the interpreter to create minimal
closures&mdash;closures where the environment contains only the variables that
are free variables in that function. To do so, you'll need to write a function
that analyzes an arbitrary function to extract the free variables of the
function, and include only these bindings in the environment.

<!--
Note: be careful comparing strings. You should use `String.compare`. We placed a
couple of helper functions in `Syntax.ml` for comparing variables for equality
and inequality (`var_eq` and `var_neq`).
-->

## Part 2: Program Correctness

In this section, you must answer several theoretical questions. You must present
your proofs in the 2-column style illustrated in class with facts that you
conclude (like a new expression being equal to a prior one) on the left and a
justification (like by "evaluation" or a certain mathematical property) on the
right. Hand in the text file `proofs.txt` filled in with your answers.

### Part 2.0

To prepare for this part of the assignment, read the online notes on
[equational reasoning](https://www.cs.princeton.edu/courses/archive/fall22/cos326/notes/reasoning.php).
Hand in proofs in the style presented in those notes.

### Part 2.1: Complex Numbers

Complex numbers can be represented by their real and imaginary components. Let
us use a pair of integers for this. Consider the following addition function
that adds the corresponding components of the pairs.

```
type complex = int * int

let cadd (c1:complex) (c2:complex) =
  let (x1,y1) = c1 in
  let (x2,y2) = c2 in
  (x1+x2, y1+y2)
```

Let `a == (a1,a2)`, `b == (b1, b2)`, and `c == (c1,c2)` be complex numbers.
Prove that addition is associative. In other words, prove:

```
cadd a (cadd b c) == cadd (cadd a b) c
```

### Part 2.2: A Minimal Proof

Consider the following code (and please note that `min_int` is a constant with
type `int` that OCaml provides you with):

```
let max (x:int) (y:int) =
  if x >= y then x else y

let rec maxs (xs:int list) =
  match xs with
      [] -> min_int
    | hd::tail -> max hd (maxs tail)

let rec append (l1:'a list) (l2:'a list) : 'a list =
  match l1 with
    [] -> l2
  | hd::tail -> hd :: append tail l2
```

You may use the fact that `max`, `maxs` and `append` are all total functions.
You may also use the following simple properties of `max` by name without
proving them:

```
For all integer values a, b, c:

(commutativity) max a b == max b a

(associativity) max (max a b) c == max a (max b c)

(idempotence)   max a (max a b) == max a b

(min_int)       max min_int a == a
```

Now, prove that for all integer lists `xs` and `ys`,

```
max (maxs xs) (maxs ys) == (maxs (append xs ys))
```

At the beginning of your proof, be sure to state the methodology that you intend
to use (ie: by induction on ...) Mention where you use properties such as
associativity, commutativity, idempotence or `min_int`, if and when you need to
use them.

### Part 2.3: Map and Back

In previous assignments, we sometimes asked you to write recursive functions
over lists using map and fold and some times without. Now you can prove that it
doesn't matter which way you choose to write your function&mdash;the two styles
are equivalent.

```
let rec map (f:'a -> 'b) (xs:'a list) : 'b list =
  match xs with
      [] -> []
    | hd::tail -> f hd :: map f tail

let bump1 (xs:int list) : int list =
  map (fun x -> x+1) xs

let bump2 (xs:int list) : int list =
  match xs with
    [] -> []
  | hd::tail -> (hd+1) :: map (fun x -> x+1) tail

let rec bump3 (xs:int list) : int list =
  match xs with
    [] -> []
  | hd::tail -> (hd+1) :: bump3 tail
```

(a) Prove that `for all integer lists l, bump1 l == bump2 l`.

(b) Prove that `for all integer lists l, bump1 l == bump3 l`.

(c) In one sentence, what's the big difference between the part (a) and part
(b)?

### Part 2.4: Zippity do da

In this question, you'll probably want to use "eta-pair" and/or "pair-pattern"
from the
[equational reasoning rules](https://www.cs.princeton.edu/courses/archive/fall22/cos326/notes/reasoning.php).

With these new laws in mind, consider the following functions:

```
let rec zip (ls:'a list * 'b list) : ('a * 'b) list =
  match ls with
      ([],_) -> []
    | (_,[]) -> []
    | (x::xrest, y::yrest) -> (x,y)::zip (xrest,yrest)

let rec unzip (xs:('a * 'b) list) : 'a list * 'b list =
  match xs with
      [] -> ([],[])
    | (x,y)::tail ->
      let (xs,ys) = unzip tail in
      (x::xs, y::ys)
```

Prove or disprove each of the following.

(a) `For all l : ('a * 'b) list, zip(unzip l) == l`.

(b) `For all l1 : 'a list, l2 : 'b list, unzip(zip (l1,l2)) == (l1,l2)`.

NOTE: The way that you disprove a theorem is you give a *counter example*. For
instance, if a theorem says "for all x of type t, ... property about x ..." then
to disprove the theorem, all you need to do is find one value v with type t and
show that the property does not hold for v. If you can, then clearly the
property does not hold "for all" x of type t.

## Handin Instructions and Grading Information

This problem set is to be done individually.

Your assignment will be automatically submitted every time you push your changes
to your GitHub repository. Within a couple minutes of your submission, the
autograder will make a comment on your commit listing the output of our testing
suite when run against your code. **Note that you will be graded only on your
changes to `EvalEnv.ml`, `Syntax.ml`, `Testing.ml`, and `proofs.txt`**, and not
on your changes to any other files.

You may submit and receive feedback in this way as many times as you like,
whenever you like.

There are 50 total points in this assignment, broken down as 18 for part 1.1, 7
for part 1.2, 5 for part 1.3, 4 for part 2.1, 4 for part 2.2, 6 for part 2.3,
and 6 for part 2.4.
