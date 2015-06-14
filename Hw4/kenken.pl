/* 
  Summary of statistics:
  - There is a noticable difference between the runtime of kenken and plain_kenken
  - Example: 
    plain_kenken(
      4,
      [
       +(9, [1-1, 1-2, 1-3]),
       /(2, 1-3, 2-3),
       -(1, 3-1, 4-1),
       +(9, [3-3, 4-3, 4-4]),
       *(1, [1-4])
      ],
    T), write(T), nl, fail.

  - kenken: 
      T = user_time
      V = [1688,13] ? a

      T = system_time
      V = [38,8]

      T = cpu_time
      V = [1726,21]

      T = real_time
      V = [490340,275815]

      T = local_stack
      V = [896,16776320]

      T = global_stack
      V = [4560,33549872]

      T = trail_stack
      V = [104,16777112]

      T = cstr_stack
      V = [0,16777216]

      T = atoms
      V = [1789,30979]

  - plain_kenken: 
      T = user_time
      V = [2892,1204] ? a

      T = system_time
      V = [47,9]

      T = cpu_time
      V = [2939,1213]

      T = real_time
      V = [528453,38113]

      T = local_stack
      V = [896,16776320]

      T = global_stack
      V = [4560,33549872]

      T = trail_stack
      V = [104,16777112]

      T = cstr_stack
      V = [0,16777216]

      T = atoms
      V = [1790,30978]

  I first implemented plain_kenken, then kenken. Note: running anything larger than a 
  4x4 on plain_kenken will take minutes to solve, whereas kenken can do it in seconds
*/


/************ Plain KenKen **************/

plain_kenken(N, C, T) :- 
    plain_rowsUnique(N,N,T), /* Create unique entries in the rows */
    transpose(T, T_transpose), /* Transpose cols into rows and then reevaluate rows are valid*/
    maplist(uniqueElems, T_transpose),
    plain_constraints(T,C). /* Verify constraints still hold */

plain_rowsUnique(0, _, T) :- length(T,0).
plain_rowsUnique(RowsLeft, N, [H|T]) :-
    RowsLeft > 0,
    plain_rowUnique(N, N, H), /* Checks this row is ok */
    RowsLeft1 is RowsLeft - 1,
    plain_rowsUnique(RowsLeft1, N, T). /* Recursively calls for all other rows */

plain_rowUnique(_, 0, _). /* True if get to N=0 */
plain_rowUnique(OrigN, N, T) :- 
    length(T, OrigN),
    member(N, T), 
    N1 is N -1, 
    plain_rowUnique(OrigN, N1, T). /* Find N-1 in T. */

uniqueElems([]).
uniqueElems([H|T]) :- \+(member(H, T)), uniqueElems(T). /* H is not already a member of T */

plain_constraints(_, []).
plain_constraints(T,[H|Tail]) :- plain_matchConstraint(T,H), plain_constraints(T, Tail).
plain_matchConstraint(T, +(S, L)) :- plain_add(T, S, L, 0).
plain_matchConstraint(T, *(P, L)) :- plain_mult(T, P, L, 1).
plain_matchConstraint(T, -(D, J, K)) :- plain_sub(T, D, J, K).
plain_matchConstraint(T, /(Q, J, K)) :- plain_div(T, Q, J, K).

plain_add(_, S, [], S). 
plain_add(T, S, [H|Tail], A) :- 
    getElement(H, T, Value),
    New_A is A + Value, 
    plain_add(T, S, Tail, New_A). 

plain_mult(_, P, [], P).
plain_mult(T, P, [H|Tail], A) :-
    getElement(H, T, Value),
    New_A is A * Value, 
    plain_mult(T, P, Tail, New_A). 

plain_sub(_, D, _, _, D).
plain_sub(T, D, J, K) :-
    getElement(J, T, Value_J),
    getElement(K, T, Value_K),
    Comp_Val is Value_K - Value_J,
    plain_sub(T, D, J, K, Comp_Val).
plain_sub(T, D, J, K) :-
    getElement(J, T, Value_J),
    getElement(K, T, Value_K),
    Comp_Val is Value_J - Value_K,
    plain_sub(T, D, J, K, Comp_Val).

plain_div(_, Q, _, _, Q).
plain_div(T, Q, J, K) :- 
    getElement(J, T, Value_J),
    getElement(K, T, Value_K),
    Comp_Val is Value_K/Value_J,
    plain_div(T, Q, J, K, Comp_Val).
plain_div(T, Q, J, K) :- 
    getElement(J, T, Value_J),
    getElement(K, T, Value_K),
    Comp_Val is Value_J/Value_K,
    plain_div(T, Q, J, K, Comp_Val).

/* Access method for that cell in the matrix */
getElement(I_row-J_col, T, Value) :- nth(I_row, T, Row), nth(J_col, Row, Value).

/* Transpose code taken from clpfd.pl library */
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).

/********* KenKen *******************/


kenken(N, C, T) :-
    length(T, N), maplist(checkLength(N), T), /* T must be of size N by N */
    maplist(setDomain(N), T), /* Restrict the value of the cells in T to be between 1 and N */
    maplist(fd_all_different, T), /* Check that all entries in a row are unique */
    constraints(T,C), /* Verify all constraints are satisfied */
    transpose(T, T_Transpose), /* Turn the columns into rows */
    maplist(fd_all_different, T_Transpose),  /* Check that all entries in the transposed row are unique */
    maplist(fd_labeling, T). /*  assigns a value to each variable X of the list Vars according to the list of labeling options given by Options */

checkLength(Length, Item) :- length(Item, Length).
setDomain(N, Vars) :- fd_domain(Vars, 1, N). /* constraints each element X of Vars to take a value in Lower..Upper */

/* Contraints: Takes the list of constraints and recursively iterates through */
constraints(_, []).
constraints(T,[H|Tail]) :- matchConstraint(T,H), constraints(T, Tail).
matchConstraint(T, +(S, L)) :- add(T, S, L, 0). /* Add extra param for add and mult because L may be larger than 2; need accumulator */
matchConstraint(T, *(P, L)) :- mult(T, P, L, 1).
matchConstraint(T, -(D, J, K)) :- sub(T, D, J, K).
matchConstraint(T, /(Q, J, K)) :- div(T, Q, J, K).

add(_, S, [], S). 
add(T, S, [H|Tail], A) :- 
    getElement(H, T, Value),
    New_A #= A + Value, 
    add(T, S, Tail, New_A). 

mult(_, P, [], P).
mult(T, P, [H|Tail], A) :-
    getElement(H, T, Value),
    New_A #= A * Value, 
    mult(T, P, Tail, New_A). 

/* Compute j - k and k - j */
sub(_, D, _, _, D).
sub(T, D, J, K) :-
    getElement(J, T, Value_J),
    getElement(K, T, Value_K),
    Comp_Val #= Value_K - Value_J,
    sub(T, D, J, K, Comp_Val).
sub(T, D, J, K) :-
    getElement(J, T, Value_J),
    getElement(K, T, Value_K),
    Comp_Val #= Value_J - Value_K,
    sub(T, D, J, K, Comp_Val).

/* Compute j div k and k div j */
div(_, Q, _, _, Q).
div(T, Q, J, K) :- 
    getElement(J, T, Value_J),
    getElement(K, T, Value_K),
    Comp_Val #= Value_K/Value_J,
    div(T, Q, J, K, Comp_Val).
div(T, Q, J, K) :- 
    getElement(J, T, Value_J),
    getElement(K, T, Value_K),
    Comp_Val #= Value_J/Value_K,
    div(T, Q, J, K, Comp_Val).