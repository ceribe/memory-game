# How to run 
Instructions below are for Arch Linux, but it should work on most distributions.
### 1. Install Opam
```
sudo pacman -S opam #Or equivalent command for your distribution
```
During instalation you will be asked if you want to edit bash_profile. Select "yes" as it will prevent possible problems.

### 2. Install [Bogue](https://github.com/sanette/bogue)
```
opam install bogue
```
During installation you will be asked to install additional packages. Install them.
Afterwards restart terminal and run:
```
eval $(opam config env)
```

### 3. Compilation
Enter repositiory's directory and run:
```
ocamlfind ocamlc -package bogue -linkpkg -o memory -thread memory.ml
```

### 4. Run
```
./memory.ml
```
