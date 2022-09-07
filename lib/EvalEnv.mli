(*************************************************)
(* An environment-based evaluator for Dynamic ML *)
(*************************************************)

(* evaluate input to a value using given environment *)
val eval_body : Syntax.env -> (Syntax.env -> Syntax.exp -> Syntax.exp) -> Syntax.exp -> Syntax.exp

(* evaluate input to a value *)
val eval : Syntax.exp -> Syntax.exp

(* evaluate input to a value while printing intermediate results *)
val debug_eval : Syntax.exp -> Syntax.exp
