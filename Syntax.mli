(*********************)
(* Dynamic ML Syntax *)
(*********************)

type variable = string

val var_eq : variable -> variable -> bool
val var_neq : variable -> variable -> bool

type constant = Int of int | Bool of bool

type operator = Plus | Minus | Times | Div | Less | LessEq

(* Match e1 e2 hd tl e3 =def
   match e1 with
     [] -> e2
   | hd::tl -> e3 *)

type exp =

  (* Basic *)
  | Var of variable
  | Constant of constant
  | Op of exp * operator * exp
  | If of exp * exp * exp
  | Let of variable * exp * exp

  (* Pairs *)
  | Pair of exp * exp
  | Fst of exp
  | Snd of exp

  (* Lists *)
  | EmptyList
  | Cons of exp * exp
  | Match of exp * exp * variable * variable * exp

  (* Recursive functions *)
  | Rec of variable * variable * exp
  | Closure of env * variable * variable * exp
  | App of exp * exp

and env = (variable * exp) list

(* empty environment *)
val empty_env : env

(* lookup_env env x == Some v
 *   where (x,v) is the most recently added pair (x,v) containing x
 * lookup_env env x == None if x in env
 *   if x does not appear in env *)
val lookup_env : env -> variable -> exp option

(* update env x v returns a new env containing the pair (x,v) *)
val update_env : env -> variable -> exp -> env
