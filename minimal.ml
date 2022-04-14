open Bogue
module W = Widget
module L = Layout

let main () =

  let b = W.check_box () in
  let l = W.label "Hello world" in
  let layout = L.flat_of_w [b;l] in

  let board = Bogue.make [] [layout] in
  Bogue.run board;;

let () = main ();
  Bogue.quit ()
