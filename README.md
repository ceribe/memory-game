# memory

## 1. Instalacja opam-u
```
yay opam
```
Podczas instalacji wybrac aby dodalo do bash_profile.

## 2. Instalacja bogue
Wejsc do katalogu z repo.
```
opam install bogue
```
Po instalacji odpalic:
```
eval $(opam config env)
```

## 3. Kompilacja
```
ocamlfind ocamlc -package bogue -linkpkg -o minimal -thread minimal.ml
```
