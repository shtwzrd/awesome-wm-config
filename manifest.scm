(use-modules (guix transformations))

(packages->manifest
 (list
  (specification->package "coreutils")
  (specification->package "make")
  (specification->package "lua@5.1")
  (specification->package "lua5.1-socket")
  (specification->package "lua5.1-lgi")

  ((options->transformation
    '((with-input . "lua=lua@5.1")
      (with-commit . "fennel=03c1c95f")))
   (specification->package "fennel"))

  (specification->package "luajit")
  (specification->package "awesome-next-luajit")
  (specification->package "gobject-introspection")
  (specification->package "xorg-server")
  (specification->package "xterm")))

