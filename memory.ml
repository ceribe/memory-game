open Bogue
module W = Widget
module L = Layout
module T = Trigger

(** Utility functions *)

(* Returns a given list but order of its elements is random *)
let shuffle list = 
    Random.self_init ();
    let tuples = List.map (fun elem -> (Random.bits (), elem)) list in
    let sorted_tuples = List.sort compare tuples in
    List.map snd sorted_tuples

(* Chunks given list. Each chunk's lenght will be equal to "size" 
  chunk_list [1;2;3;4;5;6;7;8;9] 3 => [[1;2;3];[4;5;6];[7;8;9]] *)
let chunk_list list size =
  let (_, remainings, chunked_list) =
    List.fold_left (fun (current_size, current_list, chunked_list) elem ->
      if current_size = 0 then 
        (size - 1, [elem], chunked_list @ [current_list])
      else 
        (current_size - 1, current_list @ [elem], chunked_list)
      ) (size, [], []) list
  in
  chunked_list @ [remainings]

(** Constants initalization *)

(* List's lenght is 13 so after doubling each element and removing one it will be possible to place them in a 5x5 grid *)
let tiles_names = ["a";"b";"c";"d";"e";"f";"g";"h";"i";"j";"k";"l";"m"]

(* Double the occurence of each element so there will be a pair of each letter *)
let tiles_names_doubled = tiles_names @ tiles_names

(* Shuffle the list so every time the app is launched placement of pairs will be different *)
let shuffled_names = shuffle tiles_names_doubled

(* Remove one value from shuffled_names so there are 25 elements total (5x5 grid) *)
let names = List.tl shuffled_names

let button_bg_color = (Draw.(opaque(find_color "#00FFFF")))

(** Variables representing game state *)

let found_pairs = ref 0
let prev_button = ref (W.button "")
let prev_button_2 = ref (W.button "")
let prev_value = ref ""
let already_guessed_count = ref 0
let total_guess_count = ref 0
let end_label_text = ref ""

(** Functions used to respond to user input *)

let show_end_game layout =
   end_label_text := "Game over";
   Popup.info ~w:60 ~h:40 "You won!" layout
;;

(* Checks if user guessed correctly and if so marks tiles with X *)
let process_guess button name_label layout = 
  if (W.get_text name_label) = !prev_value then begin
    already_guessed_count := 0;
    W.set_text button "X";
    W.set_text !prev_button "X";
    found_pairs := !found_pairs + 1;
    if !found_pairs = 12 then show_end_game layout
  end

(* Resets previous guesses by hiding them *)
(* The paramter is not needed, but when there wasn't one this function wasn't called properly *)
let reset_prev_guesses _ =
  already_guessed_count := 1;
  W.set_text !prev_button_2 "?";
  W.set_text !prev_button "?"

let process_tile_click button name_label layout = 
  total_guess_count := !total_guess_count + 1;
  already_guessed_count := !already_guessed_count + 1;
  if !already_guessed_count == 2 then
    process_guess button name_label layout;
  if !already_guessed_count == 3 then
    reset_prev_guesses 0; 

  prev_button_2 := !prev_button;
  prev_button := button;
  prev_value := W.get_text name_label;

  (* If guess was correct do not change it to a letter *)
  if (W.get_text button) <> "X" then
    W.set_text button (W.get_text name_label)

(** UI definition  *)

let main () =
  let moves_label = W.label "Moves: 000" in
  let end_label = W.label "                       " in

  (* A flat list of buttons with labels *)
  let buttons = List.init 25 (fun _ -> W.button ~bg_off:(Solid button_bg_color) "?") in  

  (* Each button has a corresponding label with its value. It's a convinient way to be able to check button's real value in click action *)
  let button_names = List.map (fun b -> W.label b) names in

  (* Button names need to be placed on a layout to not crash the program *)
  let _ = L.flat_of_w button_names in

  (* Create a list of columns. Each column has 5 buttons *)
  let columns = List.map (fun l -> L.tower_of_w ~w:30 l) (chunk_list buttons 5) in

  let top_layout = L.flat_of_w [moves_label] in
  let squares_grid_layout = L.flat ~sep:(-9) columns in
  let bottom_layout = L.flat_of_w [end_label] in

  (* Runs on each frame before displaying UI *)
  let before_display () =
    W.set_text moves_label ("Moves: " ^ string_of_int !total_guess_count);
    W.set_text end_label !end_label_text 
  in

  let layout = L.tower [top_layout;squares_grid_layout;bottom_layout] in

  let on_tile_click button name_label _ = 
    if (W.get_text button) = "?" then (process_tile_click button name_label layout)
  in

  (* Binds all buttons and their names with on_tile_click function *)
  let connections = List.map2 (fun b n -> W.connect b n on_tile_click T.buttons_down) buttons button_names in

  let board = Bogue.make connections [layout] in
  Bogue.run ~before_display board

let () = main ();
  Bogue.quit ()