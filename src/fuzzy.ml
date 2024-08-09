open! Core

let rec mini ?(tmp = Int.max_value) lst =
  if List.is_empty lst
  then tmp
  else (
    let curr_num = List.hd_exn lst in
    if curr_num < tmp
    then mini (List.tl_exn lst) ~tmp:curr_num
    else mini (List.tl_exn lst) ~tmp)
;;

let rec maxi ?(tmp = Int.min_value) lst =
  if List.is_empty lst
  then tmp
  else (
    let curr_num = List.hd_exn lst in
    if curr_num > tmp
    then maxi (List.tl_exn lst) ~tmp:curr_num
    else maxi (List.tl_exn lst) ~tmp)
;;

let indicator a b = if Char.equal a b then 0 else 1

let osa_distance string_1 string_2 =
  let d =
    Array.make_matrix
      ~dimx:(String.length string_1 + 1)
      ~dimy:(String.length string_2 + 1)
      0
  in
  String.iteri string_1 ~f:(fun i _ -> d.(i + 1).(0) <- i + 1);
  String.iteri string_2 ~f:(fun j _ -> d.(0).(j + 1) <- j + 1);
  String.iteri string_1 ~f:(fun i _ ->
    String.iteri string_2 ~f:(fun j _ ->
      d.(i + 1).(j + 1)
      <- mini
           [ d.(i).(j + 1) + 1
           ; d.(i + 1).(j) + 1
           ; d.(i).(j)
             + indicator (String.get string_1 i) (String.get string_2 j)
           ];
      if i + 1 > 1
         && j + 1 > 1
         && Char.equal (String.get string_1 i) (String.get string_2 (j - 1))
         && Char.equal (String.get string_1 (i - 1)) (String.get string_2 j)
      then d.(i + 1).(j + 1) <- min d.(i + 1).(j + 1) (d.(i - 1).(j - 1) + 1)));
  d.(String.length string_1).(String.length string_2)
;;

let%expect_test "osa" =
  let i = osa_distance "CA" "ABC" in
  print_s [%sexp (i : int)];
  [%expect {|3|}]
;;

let dl_distance string_1 string_2 =
  let strlen_1 = String.length string_1 in
  let strlen_2 = String.length string_2 in
  let da = Hashtbl.create (module Char) in
  let d = Array.make_matrix ~dimx:(strlen_1 + 2) ~dimy:(strlen_2 + 2) 0 in
  let maxdist = strlen_1 + strlen_2 in
  d.(0).(0) <- maxdist;
  String.iteri string_1 ~f:(fun i _ ->
    d.(i + 1).(0) <- maxdist;
    d.(i + 1).(1) <- i);
  d.(strlen_1 + 1).(0) <- maxdist;
  d.(strlen_1 + 1).(1) <- strlen_1;
  String.iteri string_2 ~f:(fun j _ ->
    d.(0).(j + 1) <- maxdist;
    d.(1).(j + 1) <- j);
  d.(0).(strlen_2 + 1) <- maxdist;
  d.(1).(strlen_2 + 1) <- strlen_2;
  String.iteri string_1 ~f:(fun i ai ->
    let i = i + 1 in
    let db = ref 0 in
    String.iteri string_2 ~f:(fun j bj ->
      let j = j + 1 in
      let k =
        match Hashtbl.find da bj with
        | Some idx -> idx + 1
        | None ->
          Hashtbl.set da ~key:bj ~data:(-1);
          0
      in
      let l = db in
      if Char.equal ai bj then db := j;
      d.(i + 1).(j + 1)
      <- mini
           [ d.(i).(j + 1) + 1
           ; d.(i + 1).(j) + 1
           ; d.(i).(j) + indicator ai bj
           ; d.(k).(!l) + (i - k - 1) + 1 + (j - !l - 1)
           ]);
    Hashtbl.set da ~key:ai ~data:(i - 1));
  d.(String.length string_1 + 1).(String.length string_2 + 1)
;;

let%expect_test "dl" =
  let i = dl_distance "CA" "ABC" in
  print_s [%sexp (i : int)];
  [%expect {|2|}]
;;

let gap_penalty n = 2 * n
let s a b = if Char.equal a b then 3 else -3

let find_max_idx matrix =
  let (x, y), _ =
    Array.foldi
      matrix
      ~init:((0, 0), matrix.(0).(0))
      ~f:(fun i ((max_x, max_y), max_elem) row ->
        Array.foldi
          row
          ~init:((max_x, max_y), max_elem)
          ~f:(fun j ((max_x, max_y), max_elem) elem ->
            if max_elem < elem
            then (i, j), elem
            else (max_x, max_y), max_elem))
  in
  x, y
;;

let get_neighbor_idx matrix ~x ~y =
  [ x - 1, y - 1; x, y - 1; x - 1, y ]
  |> List.filter ~f:(fun (x, y) -> x >= 0 && y >= 0)
;;

let zeros matrix ~x ~y =
  get_neighbor_idx matrix ~x ~y
  |> List.fold ~init:false ~f:(fun acc (i, j) ->
    if acc then acc else matrix.(i).(j) = 0)
;;

let find_max_neighbor_idx matrix ~x ~y =
  let _, coord =
    get_neighbor_idx matrix ~x ~y
    |> List.fold
         ~init:(Int.min_value, (0, 0))
         ~f:(fun (max_val, (max_x, max_y)) (i, j) ->
           if max_val < matrix.(i).(j)
           then matrix.(i).(j), (i, j)
           else max_val, (max_x, max_y))
  in
  coord
;;

let rec traceback ?(acc = []) coord ~matrix =
  let x, y = coord in
  if zeros matrix ~x ~y
  then (x, y) :: acc
  else (
    let x1, y1 = find_max_neighbor_idx matrix ~x ~y in
    traceback ~acc:((x, y) :: acc) ~matrix (x1, y1))
;;

let sw_algo string_1 string_2 =
  let n, m = String.length string_1, String.length string_2 in
  let scoring_matrix = Array.make_matrix ~dimx:(n + 1) ~dimy:(m + 1) 0 in
  String.iteri string_1 ~f:(fun i ai ->
    let i = i + 1 in
    String.iteri string_2 ~f:(fun j bj ->
      let j = j + 1 in
      scoring_matrix.(i).(j)
      <- maxi
           [ 0
           ; scoring_matrix.(i - 1).(j - 1) + s ai bj
           ; (if i > 0
              then
                maxi
                  (List.init i ~f:(fun p ->
                     scoring_matrix.(i - p).(j) - gap_penalty p))
              else 0)
           ; (if j > 0
              then
                maxi
                  (List.init j ~f:(fun q ->
                     scoring_matrix.(i).(j - q) - gap_penalty q))
              else 0)
           ]));
  let alignmnet =
    find_max_idx scoring_matrix |> traceback ~matrix:scoring_matrix
  in
  alignmnet
  (* List.filter alignmnet ~f:(fun (i, j) ->
    Char.equal (String.get string_1 (i - 1)) (String.get string_2 (j - 1))) *)
;;

let%expect_test "sw" =
  let i = sw_algo "home_dir" "emoh" in
  print_s [%sexp (i : (int * int) list)];
  [%expect {| ((1 4)) |}]
;;

let fuzzy_find str_1 str_2 =
  let str_1, str_2 = String.lowercase str_1, String.lowercase str_2 in
  let len = List.length (sw_algo str_1 str_2) in 
  len >= String.length str_2
;;

let%expect_test "fzf" = 
let my_files = [
  ".ocamlformat";
  "src";
  ".git";
  "log.txt";
  ".vscode";
  "tests";
  "README.md";
  "test_dir";
  "lib";
  "tmp";
  "_build";
  ".snapshots";
  ".gitignore";
  ".env";
  "demos";
  "file_manager_lib.opam";
  "demo.cast";
  "bb";
  "bin"
] in
  let filtered = List.filter my_files ~f:(fun str -> fuzzy_find str "tmp") in
  print_s [%sexp (filtered : string list)];
  [%expect {| ["home_tmp] |}]
;;