-- (1) Try out slides 2-7 and 13-16 using GHCi.
-- no solution

-- (2) Fix the syntax errors in the program below, and test your solution using GHCi.
n = a `div` length xs -- lowercase n, backticks instead of single quotes
  where
    a = 10 -- fix indentation
    xs = [1,2,3,4,5]

-- (3) Show how the library function last that selects the last element of a list can be defined using the functions introduced in this lecture.
last' xs = head (reverse xs)

-- (4) Can you think of another possible definition?
last'' xs = drop (length xs - 1) xs !! 0

-- (5) Similarly, show how the library function init that removes the last element from a list can be defined in two different ways.
init' xs = take (length xs - 1) xs
init'' xs = reverse (tail (reverse xs))