-- (1) Without looking at the standard prelude, define the following library functions using recursion:
--     (a) Decide if all logical values in a list are true:
and' [] = True
and' (b:bs) = b && and' bs

--     (b) Concatenate a list of lists:
concat' [] = []
concat' (x:xs) = x ++ concat(xs)

--     (c) Produce a list with n identical elements:
replicate' 0 _ = []
replicate' n x = [x] ++ replicate' (n-1) x

--     (d) Select the nth element of a list:
select' (x:xs) 0 = x
select' (x:xs) i = select' xs (i-1)

--      (e) Decide if a value is an element of a list:
elem' _ [] = False
elem' v (x:xs) = v == x || elem' v xs

-- (2) Define a recursive function that merges two sorted lists of values to give a single sorted list.  For example: merge [2,5,6] [1,3,4] == [1,2,3,4,5,6]
merge xs [] = xs
merge [] ys = ys
merge (x:xs) (y:ys) = (if x > y then [y,x] else [x,y]) ++ merge xs ys

-- (3) Define a recursive function that implements merge sort, which can be specified by the following two rules:
--      - Lists of length <= 1 are already sorted;
--      - Other lists can be sorted by sorting the two halves and merging the resulting lists. 
msort [] = []
msort (x:[]) = [x]
msort xs = merge (msort (take (length xs `div` 2) xs)) (msort (drop (length xs `div` 2) xs))