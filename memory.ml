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

(* List of 13 different colors so after doubling them and removing one element it will be possible to place them in a 5x5 grid *)
let color_names = ["red"; "blue"; "green"; "magenta"; "cyan"; "yellow"; "sienna"; "#ff9900"; "#ff99ff"; "#3333ff"; "#99ff99"; "#0099cc"; "#ffcccc"];;

(* Double occurence of each color so there will ba a pair of each *)
let color_names_doubled = color_names @ color_names;;

(* Shuffle the colors list so every time the app is launched placement of pairs will be different *)
let shuffled_colors = shuffle color_names_doubled;;

(* Remove one value from shuffled_colors so there is 25 total elements (5x5 grid) *)
let colors = List.tl shuffled_colors;;

let main () =
  (* TODO Update the label on each click *)
  let lab = W.label "Moves: 0" in
  
  (* A flat list of buttons with colors *)
  (* TODO Make them have the same color before clicking and only change it after click *)
  (* TODO Found pairs should stay colored *)
  (* TODO After guessing wrong hide both squares *)
  (* TODO Detect when user has unveiled all 12 pairs and show a message box. After clicking on the message box app should close *)
  let buttons = List.map (fun c -> W.button ~bg_off:(Solid(Draw.(opaque(find_color c)))) "") colors in  

  (* Create a list of columns. Each column has 5 buttons *)
  let columns = List.map (fun l -> L.tower_of_w ~w:30 l) (chunk_list buttons 5) in

  let flat_layout_with_text = L.flat_of_w [lab] in
  let squares_grid = L.flat ~sep:(-9) columns in
  let layout = L.tower [flat_layout_with_text;squares_grid] in
  let board = Bogue.make [] [layout]   in
  Bogue.run board;;

let () = main ();
  Bogue.quit ()
