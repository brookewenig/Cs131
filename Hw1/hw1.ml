let rec subset a b = 
    let c = List.sort_uniq compare a in
    let d = List.sort_uniq compare b in
    match(c,d) with
    | [],_ -> true
    | _,[] -> false
    | x::xs,y::ys -> if x ==y then 
                        subset xs ys
                     else
                        subset c ys;;
	(* TODO: could be a subset that doesn't start at the beginning
		2 3
		1 2 3
	*)

let rec equal_sets a b = 
	let c = List.sort_uniq compare a in
	let d = List.sort_uniq compare b in
	match (c,d) with
	| [],[] -> true
	| _,[] -> false
	| [],_ -> false
	| x::xs, y::ys -> if x == y then
							equal_sets xs ys
						else
							false;;
	(*Order set first, then do this 3 1 2 = 1 2 3*)

let rec find a b = 
	match b with
	| [] -> false
	| x::xs -> if x == a then
					true
				else
					find a xs;;
	(* Helper function to see if the single value a is in list b*)

let rec set_union a b = 
	(* Go through each element in b, if it is not in a, then append*)
	(* Remove duplicates from the sets *)
	let d = List.sort_uniq compare a in
	let e = List.sort_uniq compare b in

	match d,e with
	| [], [] -> []
	| _, [] -> d
	| [], _ -> e
	| x::xs, y::ys -> if find y d then
							set_union d ys
						else
							let c = y::d in
							set_union c ys;;
(* 1 2 3 ; 2 3 4*)

let rec set_intersection_three a b c = 
        match a,b with
        | [], [] -> []
        | _, [] -> c
        | [], _ -> c
        | x::xs, y::ys -> if find y a then
                            (let d = y::c in
                            set_intersection_three a ys d)
                          else
                              set_intersection_three a ys c;;

let set_intersection a b = 
    set_intersection_three a b [];;
	(* Pass in third param keeping the ones that they have in common*)

let rec set_diff_three a b c = 
    match a,b with
        | [], [] -> []
        | [], _ -> c
        | _, [] -> a
        | x::xs, y::ys -> if find x b then (* a looking inside of b, if there, don't do anything *)
                            set_diff_three xs b c
                          else
                            (let d = x::c in
                             set_diff_three xs b d);;

let set_diff a b = 
    set_diff_three a b [];;

let rec computed_fixed_point eq f x = 
    if (eq(f(x)) x) then x
    else 
        let y = f x in computed_fixed_point eq f y;;

let rec computed_periodic_point eq f p x =
 	if p = 0 then 
    	x
	else 
	(if (eq(f(x)) x) then x
	else 
        let y = f x in 
            let dec = p-1 in computed_periodic_point eq f dec y);; 
	(* Doesn't pass 2nd test case*)

(*Helper functions for filter_blind_alleys *)
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

(* Get the LHS of the rule *)
let extract_lhs (lhs,rhs) = lhs;;

let extract_rhs (lhs,rhs) = rhs;;

(* Check if symbol is NT or T*)
let is_terminal x =
    match x with
    | T _ -> true
    | N _ -> false;;
    
let remove_symbol = function
    | N x -> x;;

let exists_in_parent p r =
    List.exists(fun y -> 
        List.exists(fun z -> not (is_terminal(y)) && (z==(remove_symbol y))) p) 
        r;;
    
let rec check_rule g p r =
    List.for_all(fun x -> 
        if is_terminal x then true
        else List.exists(fun z -> if (extract_lhs z == remove_symbol(x)) && not (exists_in_parent p (extract_rhs z)) then (check_rule g ((remove_symbol x)::p) (extract_rhs z)) else false) g)
       r;;
    
let filter_rules g  =
    List.find_all(fun x -> if extract_rhs(x)==[] then true else check_rule g [] (extract_rhs x)) g;;
    
let filter_blind_alleys (lhs, rhs) = 
    (lhs, filter_rules rhs);;
    


