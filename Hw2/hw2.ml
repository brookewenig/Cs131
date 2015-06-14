type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

let extract_lhs (lhs,rhs) = lhs;;
let extract_rhs (lhs,rhs) = rhs;;

let is_terminal x =
    match x with
    | T _ -> true
    | N _ -> false;;

let get_terminal = function
    | T x -> x;;

let get_nonterminal = function
    | N x -> x;;

let rec remove_rhs rules rhs_rules =
    let reverse =
    match rules with
    | [] -> rhs_rules
    | h::t -> remove_rhs t ((extract_rhs h)::rhs_rules) in List.rev reverse;;

let assoc_rules rules non_t =
    let nonterm_rule =  List.filter(fun x -> extract_lhs x = non_t) rules in remove_rhs nonterm_rule [];;

let convert_grammar (start_symbol, rules) =
    (start_symbol, function | non_terminal -> assoc_rules rules non_terminal);;

let get_nt_rules gram non_term =
    (snd gram) (non_term);;


(* ****************************************************************************************************************** *)

(* rec_vert traverses through the rules linearly, rec_horiz traverses the alternative list *)
(* 0 = fail, 1 = pass *)

let rec rec_vert rules frag path gram non_term = match rules with
    | [] -> (frag, [], 0) (* If no more rules, then didn't find a path *)
    | h::t ->
        match (rec_horiz frag ((non_term,h)::path) h gram non_term) with
        | (x, _, 0) ->  if ((List.length rules) = 1) then (x,[],0)
                        else rec_vert t frag path gram non_term
        | (x, y, 1) ->  if (List.length frag >= List.length h) then (x,y,1)
                        else if ((List.length rules) > 1)
                            then rec_vert t frag path gram non_term
                        else (x,[],0)
    and

rec_horiz frag path curr_rule gram non_term =
    if frag = [] then (
        if curr_rule = [] then (frag, path, 1)
        else (frag, [], 0)
    )
    else (
            match curr_rule with
            | [] -> (frag, path, 1) 
            | h::t -> 
                      if (is_terminal h) then (
                        if ((get_terminal h) = (List.hd frag)) then
                            match rec_horiz (List.tl frag) path t gram non_term with
                                | (a,b,1) -> if (List.length frag < List.length t) then (a,[],0)
                                             else (a,b,1)
                                | (a,_,0) -> (a,[],0)
                        else (frag, [], 0)
                        )
                      else
                          match rec_vert (get_nt_rules gram (get_nonterminal h)) frag path gram (get_nonterminal h) with
                              | (a,b,1) -> if ((List.length t) <= (List.length frag))
                                           then rec_horiz a b t gram non_term
                                           else (a,[],0)
                              | (a,_,0) -> (a,[],0)
    )
;;

(* Calls the rec_vert to start linear search *)
let eval_rec_vert gram frag = rec_vert ((snd gram) (fst gram)) frag [] gram (fst gram);;

(* Remove the 3rd param from the return result of rec_vert *)
let ret_frag gram frag = 
    match eval_rec_vert gram frag with 
    | (_, _, 0) -> ([],[])
    | (y, x, 1) -> ((List.rev x),y);;

(* Shorten the fragment and tests it with the acceptor *)
let rec test_frag gram accept frag frag_tail = 
    if frag = [] then None
    else match (ret_frag gram frag) with
          | (x,y) -> match accept x (y@frag_tail) with
                     | Some(x,y) -> Some(x,y)
                     | None -> test_frag gram accept (List.rev(List.tl (List.rev frag))) ((List.hd(List.rev frag))::frag_tail);;
                                                    (* Pass in the entire fragment except the head, store the head *)

let parse_prefix gram accept frag =
    if frag = [] then None
    else match (ret_frag gram frag) with
         | (x,y) -> match accept x y with
                    | Some(x,y) -> if x = [] then None
                                   else Some(x,y)
                    | None -> test_frag gram accept (List.rev(List.tl (List.rev frag))) [(List.hd(List.rev frag))];;
                      (* Fragment not acceptable, try to shorten the fragment *)
