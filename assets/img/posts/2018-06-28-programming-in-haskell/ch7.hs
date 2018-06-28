-- (1) What are higher-order functions that return functions as results better known as?
-- curried functions (?)

-- (2) Express the comprehension [f x | x <- xs, p x] using the functions map and filter.
comprehension xs f p = map f (filter p xs)

-- test
xs = [1..10]
f = (*2)
p = even
res2 = [f x | x <- xs, p x]
res2' = comprehension xs f p

-- (3) Redefine map f and filter p using foldr.
map' f = foldr (\x acc -> f x : acc) []
filter' p = foldr (\x acc -> if p x then x:acc else acc) []

-- test
res3a = map f xs
res3b = filter p xs

res3a' = map' f xs
res3b' = filter' p xs