# How to run

Instructions below are for Arch Linux, but it should work on most distributions.

### 1. Install Opam (OCaml Package Manager)

Installing Opam will also install OCaml as a dependency so there is no need to install it separately.
```bash
sudo pacman -S opam #Or equivalent command for your distribution
```

During instalation you may be asked if you want to edit ~/.bash_profile. Select "yes".

### 2. Install [Bogue](https://github.com/sanette/bogue)
```bash
sudo pacman -S pkg-config
opam install bogue
```

During installation you will be asked to install additional packages. Install them.
Afterwards restart terminal and run:
```bash
eval $(opam config env)
```

### 3. Compile

Enter repositiory's directory and run:
```bash
ocamlfind ocamlc -package bogue -linkpkg -o memory -thread memory.ml
```

### 4. Run
```bash
./memory
```
