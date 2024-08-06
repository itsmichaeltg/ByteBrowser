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
  [%expect {|1|}]
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
  String.iteri string_1 ~f:(fun i _ ->
    let db = ref 0 in
    String.iteri string_2 ~f:(fun j _ ->
      let key = String.get string_2 j in
      let k =
        match Hashtbl.find da key with
        | Some v -> v
        | None ->
          Hashtbl.set da ~key ~data:(-1);
          -1
      in
      let l = db in
      if Char.equal (String.get string_1 i) (String.get string_2 j)
      then db := j;
      d.(i + 1).(j + 1)
      <- mini
           [ d.(i).(j + 1) + 1
           ; d.(i + 1).(j) + 1
           ; d.(i + 1).(j + 1)
             + indicator (String.get string_1 i) (String.get string_2 j)
           ; d.(k - 1).(!l - 1) + (i - k + 1) + 1 + (j - !l)
           ]);
    Hashtbl.set da ~key:(String.get string_1 i) ~data:i);
  d.(String.length string_1).(String.length string_2)
;;

let%expect_test "dl" =
  let i = dl_distance "CA" "ABC" in
  print_s [%sexp (i : int)];
  [%expect {|1|}]
;;
