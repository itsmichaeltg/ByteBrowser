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

let fuzzy_find lst str = 
  List.filter lst ~f:(fun i -> dl_distance i str < 4);
;;

let%expect_test "dl" =
  let i = fuzzy_find ["CA"; "ABC"; "CBA"; "FGHIK"] "ABC" in
  print_s [%sexp (i : string list)];
  [%expect {| (CA ABC CBA) |}]
;;