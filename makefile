build:
	ocamlfind ocamlc -package bogue -linkpkg -o memory -thread memory.ml

clean:
	rm memory{.cmi,.cmo,}