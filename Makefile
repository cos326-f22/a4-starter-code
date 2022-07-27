TESTFILES = Syntax.ml Printing.mli Printing.ml EvalUtil.mli EvalUtil.ml EvalEnv.mli EvalEnv.ml EvalSubst.mli EvalSubst.ml Testing.ml Main.ml

testing: $(TESTFILES)
	ocamlbuild Main.byte

clean:
	ocamlbuild -clean
