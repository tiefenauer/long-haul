-- (1) Consider a function safetail that behaves in the same way as tail, except that safetail maps the empty list to the empty list, whereas tail gives an error in this case.  Define safetail using:
--     (a) a conditional expression
safetail xs = if xs == [] then [] else tail xs
--     (b) guarded equations
safetail' xs | xs == [] = []
             | otherwise = tail xs
--     (c) pattern matching
safetail'' [] = []
safetail'' xs = tail xs

-- (2) Give three possible definitions for the logical or operator (||) using pattern matching.
or' True True = True
or' True False = True
or' False True = True
or' False False = False

or'' True _ = True
or'' _ True = True
or'' _ _ = False

or''' False False = False
or''' _ _ = True

-- (3) Redefine the following version of (&&) using conditionals rather than patterns:
and' x y = if x then if y then True else False else False

-- (4) Do the same for the following version
and'' x y = if not x then False else if y then True else False