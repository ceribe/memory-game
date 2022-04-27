open Bogue;;
module W = Widget
module L = Layout
module T = Trigger
module SSet = Set.Make(String)

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

(* Variables representing game state *)
let found_pairs = ref SSet.empty;;
let prev_button = ref (W.button "");;
let prev_button_2 = ref (W.button "");;
let prev_value = ref "";;
let already_guessed_count = ref 0;;
let guess_count = ref 0;;

let main () =
  let moves_label = W.label "Moves: 000" in
  
  (* A flat list of buttons with labels *)
  let buttons = List.init 25 (fun _ -> W.button ~bg_off:(Solid button_bg_color) "?") in  

  (* Each button has a corresponding label with its value. It's a convinient way to be able to check button's real value in click action *)
  let button_names = List.map (fun b -> W.label b) names in

  (* Button names need to be placed on a layout to not crash the program *)
  let fake_layout = L.flat_of_w button_names in

  (* Function checks if user guessed correctly and if so marks tiles with X and adds letter to set *)
  let process_guess button name_label = 
    if (W.get_text name_label) = !prev_value then begin
      W.set_text button "X";
      W.set_text !prev_button "X";
      found_pairs := SSet.add (W.get_text name_label) !found_pairs;
      already_guessed_count := 0
    end
  in

  (* Resets previous guesses by hiding them *)
  (* The paramter is not needed, but when there wasn't one this function wasn't called properly *)
  let reset_prev_guesses _ =
    already_guessed_count := 1;
    W.set_text !prev_button_2 "?";
    W.set_text !prev_button "?"
  in

  let tile_click button name_label _ = 
  (* TODO Fix when clicked on X *)
  (* TODO Prevent clicking on the same button twice *)
    guess_count := !guess_count + 1;
    already_guessed_count := !already_guessed_count + 1;
    if !already_guessed_count == 2 then
      process_guess button name_label;
    if !already_guessed_count == 3 then
      reset_prev_guesses 0; 

    prev_button_2 := !prev_button;
    prev_button := button;
    prev_value := W.get_text name_label;

    if (W.get_text button) <> "X" then
      W.set_text button (W.get_text name_label)

  (* TODO Detect when user has unveiled all 12 pairs and show a message box. After clicking on the message box app should close *)
  in

  (* Binds all buttons and their names with tile_click function *)
  let connections = List.map2 (fun b n -> W.connect b n tile_click T.buttons_down) buttons button_names in

  (* Create a list of columns. Each column has 5 buttons *)
  let columns = List.map (fun l -> L.tower_of_w ~w:30 l) (chunk_list buttons 5) in

  let flat_layout_with_text = L.flat_of_w [moves_label] in
  let squares_grid = L.flat ~sep:(-9) columns in

  (* Function run on each frame before displaying UI *)
  let before_display () =
    W.set_text moves_label ("Moves: " ^ string_of_int !guess_count) in

  let layout = L.tower [flat_layout_with_text;squares_grid] in
  let board = Bogue.make connections [layout]  in
  Bogue.run ~before_display board;;

let () = main ();
  Bogue.quit ()