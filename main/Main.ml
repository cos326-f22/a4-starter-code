(* Main program:  runs our tests *)
open A4lib

(* switch EvalEnv to EvalSubst to test substitution-based interpreter *)
module Eval = EvalEnv

let main = Testing.run_tests Eval.eval Testing.tests
