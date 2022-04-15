open Bogue;;
module W = Widget
module L = Layout

(** Utils functions *)

(* Returns a copy of list "d" but, order of its elements is random *)
let shuffle d = begin
    Random.self_init ();
    let nd = List.map (fun c -> (Random.bits (), c)) d in
    let sond = List.sort compare nd in
    List.map snd sond
 end

(* Chunks given "xs" list. Each chunk's lenght will be equal to "size" 
  chunk_list [1;2;3;4;5;6;7;8;9] 3 => [[1;2;3];[4;5;6];[7;8;9]] *)
let chunk_list xs size =
  let (_, r, rs) =
    List.fold_left (fun (csize, ys, zss) elt ->
      if csize = 0 then (size - 1, [elt], zss @ [ys])
      else (csize - 1, ys @ [elt], zss))
        (size, [], []) xs
  in
  rs @ [r]

(** Program logic *)

(* List's lenght is 13 so after doubling each element and removing one it will be possible to place them in a 5x5 grid *)
let tiles_names = ["a";"b";"c";"d";"e";"f";"g";"h";"i";"j";"k";"l";"m"];;

(* Double the occurence of each element so there will be a pair of each letter *)
let tiles_names_doubled = tiles_names @ tiles_names;;

(* Shuffle the list so every time the app is launched placement of pairs will be different *)
let shuffled_names = shuffle tiles_names_doubled;;

(* Remove one value from shuffled_names so there is 25 elements total (5x5 grid) *)
let names = List.tl shuffled_names;;

let button_bg_color = (Draw.(opaque(find_color "#00FFFF")))

let main () =
  (* TODO Update the label on each click *)
  let lab = W.label "Moves: 0" in
  
  (* A flat list of buttons with labels *)
  (* TODO Make them have no label  before clicking and only change it after click *)
  (* TODO Found pairs should have "X" *)
  (* TODO After guessing wrong hide both squares *)
  (* TODO Detect when user has unveiled all 12 pairs and show a message box. After clicking on the message box app should close *)
  let buttons = List.init 25 (fun _ -> W.button ~bg_off:(Solid button_bg_color) "?") in  
  let button_names = List.map (fun b -> W.label b) names in

  (* Create a list of columns. Each column has 5 buttons *)
  let columns = List.map (fun l -> L.tower_of_w ~w:30 l) (chunk_list buttons 5) in

  let flat_layout_with_text = L.flat_of_w [lab] in
  let squares_grid = L.flat ~sep:(-9) columns in
  let layout = L.tower [flat_layout_with_text;squares_grid] in
  let board = Bogue.make [] [layout]  in
  Bogue.run board;;

let () = main ();
  Bogue.quit ()
