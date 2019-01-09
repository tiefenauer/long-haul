---
title: Programming in Haskell - Solutions to slides
layout: post
toc: true
---

I attended a course about Advanced Programming Paradigms for my master studies (MSE course TSM_AdvPrPa) which introduces programming in a purely functional language by example of Haskell. We use the book [Programming in Haskell](http://www.cs.nott.ac.uk/~pszgmh/pih.html) by Graham Hutton. Although the book itself is not free, it comes with slides which can be downloaded for free and contain some exercises for each chapter. Since have not found a complete set of solutions for those exercises, I put my own solutions online (chapter 2 - 10 only, note that chapter 1 does not contain any exercises). You can download the code for each chapter by clicking the link below each caption. The files can be imported in GHCi.

I also removed the blue background from the PowerPoint slides for printability and exported to PDF. You can download the printable slides by clicking the link below each caption.

## Chapter 1: Introduction

(no script) / [printable slides](/assets/img/posts/2018-06-28-programming-in-haskell/ch1.pdf)

## Chapter 2: First Steps

[script](/assets/img/posts/2018-06-28-programming-in-haskell/ch2.hs) / [printable slides](/assets/img/posts/2018-06-28-programming-in-haskell/ch2.pdf)

```haskell
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
```

## Chapter 3: Types and Classes

[script](/assets/img/posts/2018-06-28-programming-in-haskell/ch3.hs) / [printable slides](/assets/img/posts/2018-06-28-programming-in-haskell/ch3.pdf)

```haskell
-- (1) What are the types of the following values?
-- ['a','b','c'] :: [Char]
-- ('a','b','c') :: (Char, Char, Char)
-- [(False,'0'),(True,'1')] :: [(Bool, Char]
-- ([False,True],['0','1']) :: ([Bool], [CHar])
-- [tail,init,reverse] :: [[a] -> [a]]

-- (2) What are the types of the following functions?
second :: [a] -> a
second xs = head (tail xs)

swap :: (a,b) -> (b,a)
swap (x,y) = (y,x)

pair :: a -> b -> (a,b)
pair x y = (x,y)

double :: Num a => a -> a
double x = x*2

palindrome :: Eq a => [a] -> Bool
palindrome xs = reverse xs == xs

twice :: (a -> a) -> a -> a
twice f x = f (f x)

-- (3) Check your answers using GHCi.
-- see results above
```

## Chapter 4: Defining Functions

[script](/assets/img/posts/2018-06-28-programming-in-haskell/ch4.hs) / [printable slides](/assets/img/posts/2018-06-28-programming-in-haskell/ch4.pdf)

```haskell
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
```

## Chapter 5: List Comprehensions

[script](/assets/img/posts/2018-06-28-programming-in-haskell/ch5.hs) / [printable slides](/assets/img/posts/2018-06-28-programming-in-haskell/ch5.pdf)

```haskell
-- (1) A triple (x,y,z) of positive integers is called pythagorean if x2 + y2 = z2.  Using a list comprehension, define a function
pyths n = [(x,y,z) | x <- [1..n], y <- [1..n], z <- [1..n], x*x + y*y == z*z]

-- (2) A positive integer is perfect if it equals the sum of all of its factors, excluding the number itself.  Using a list comprehension, define a function
factors n = [x | x <- [1..n], n `mod` x == 0 && x /= n]
perfects n = [x | x <- [1..n], sum (factors x) == x]

-- (3) The scalar product of two lists of integers xs and ys of length n is give by the sum of the products of the corresponding integers:
scalar xs ys = sum [x*y | (x,y) <- zip xs ys]
```

## Chapter 6: Recursive Functions

[script](/assets/img/posts/2018-06-28-programming-in-haskell/ch6.hs) / [printable slides](/assets/img/posts/2018-06-28-programming-in-haskell/ch6.pdf)


```haskell
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
```

## Chapter 7: Higher-Order Functions

[script](/assets/img/posts/2018-06-28-programming-in-haskell/ch7.hs) / [printable slides](/assets/img/posts/2018-06-28-programming-in-haskell/ch7.pdf)

```haskell
-- (1) What are higher-order functions that return functions as results better known as?
-- curried functions (?)

-- (2) Express the comprehension [f x | x <- xs, p x] using the functions map and filter.
comprehension xs f p = map f (filter p xs)

-- (3) Redefine map f and filter p using foldr.
map' f = foldr (\x acc -> f x : acc) []
filter' p = foldr (\x acc -> if p x then x:acc else acc) []
```

## Chapter 8: Declaring Types and Classes

[script](/assets/img/posts/2018-06-28-programming-in-haskell/ch8.hs) / [printable slides](/assets/img/posts/2018-06-28-programming-in-haskell/ch8.pdf)
```haskell
data Nat = Zero | Succ Nat

nat2int :: Nat -> Int
nat2int Zero = 0
nat2int (Succ n) = 1 + nat2int n

instance Show Nat where
    show n = show (nat2int n)

-- (1) Using recursion and the function add, define a function that multiplies two natural numbers.
add :: Nat -> Nat -> Nat
add Zero n = n
add (Succ m) n = Succ (add m n)

mul :: Nat -> Nat -> Nat
mul Zero _  = Zero
mul _ Zero = Zero
mul m (Succ n) = add m (mul m n)

-- example: 3 * 4 = 12
three = Succ (Succ (Succ Zero)) -- 3
four = Succ (Succ (Succ (Succ Zero))) -- 4
res1 = mul three four -- 12

-- (2) Define a suitable function folde for expressions, and give a few examples of its use.
data Expr = Val Int
          | Add Expr Expr
          | Mul Expr Expr

-- evaluation function from slide 19
eval :: Expr -> Int
eval (Val n) = n
eval (Add m n) = eval m + eval n
eval (Mul m n) = eval m * eval n

-- folde function
-- 1st param (Int -> a): ID-operation that maps an (Integer-)Value of a Value-Expression to an arbitrary return type
-- 2nd param (a -> a -> a): operation that adds two Expressions (add)
-- 3rd param (a -> a -> a): operation that multiplies two Expressions (mul)
-- 4th param Expr: an expresion to fold
-- returns a: arbitrary return type
folde :: (Int -> a) -> (a -> a -> a) -> (a -> a -> a) -> Expr -> a
folde id _ _ (Val x) = id x
folde id add mul (Add x y) = add (folde id add mul x) (folde id add mul y)
folde id add mul (Mul x y) = mul (folde id add mul x) (folde id add mul y)

-- evaluation function with folde: return type =Int
evalToInt :: Expr -> Int
evalToInt e = folde id (+) (*) e

-- evaluation function with folde: return type = Double
evalToDouble :: Expr -> Double
evalToDouble e = folde fromIntegral (+) (*) e

-- evaluation function with folde that maps each value to a value twice the size in th expression (for demonstration purposes only): return type=Int
evalToTwice :: Expr -> Int
evalToTwice e = folde (\x -> 2*x) (+) (*) e

e = Mul (Add (Val 3) (Val 4)) (Val 5)
res2 = eval e -- 35
res2Int = evalToInt e -- 35
res2Double = evalToDouble e -- 35.0
res2Twice = evalToTwice e -- 140 = (3*2 + 4*2) * 5*2 = (6 + 8) * 10

-- (3) A binary tree is complete if the two sub-trees of every node are of equal size.  Define a function that decides if a binary tree is complete.
data Tree a = Leaf a
            | Node (Tree a) a (Tree a)

-- example Tree from slide 21
t = Node (Node (Leaf 1) 3 (Leaf 4)) 5 (Node (Leaf 6) 7 (Leaf 9))
-- imperfect Tree (additional leaves under node 9)
t' = Node (Node (Leaf 1) 3 (Leaf 4)) 5 (Node (Leaf 6) 7 (Node (Leaf 8) 9 (Leaf 10)))

treeDepth :: (Tree a) -> Int
treeDepth (Leaf a) = 0
treeDepth (Node l a r) = 1 + max (treeDepth l) (treeDepth r)

isComplete :: (Tree a) -> Bool
isComplete (Leaf a) = True
isComplete (Node l a r) = (treeDepth l == treeDepth r)

res3 = isComplete t -- True
res3' = isComplete t' -- False
```

## Chapter 9: The Countdown Problem

(no script) / [printable slides](/assets/img/posts/2018-06-28-programming-in-haskell/ch9.pdf)

## Chapter 10: Interactive programming

[script](/assets/img/posts/2018-06-28-programming-in-haskell/ch10.hs) / [printable slides](/assets/img/posts/2018-06-28-programming-in-haskell/ch10.pdf)

```haskell
-- Game of nim (without input validation)
showBoard :: [Int] -> IO ()
showBoard xs = mapM_ putStrLn [replicate x '*' | x <- xs]

removeStars :: [Int] -> Int -> Int -> [Int]
removeStars xs l n = [if i==l then x-n else x | (i,x) <- zip [1..] xs]

play :: [Int] -> IO ()
play board = do
    showBoard board
    if sum board == 0 then
        putStrLn "finished!"
    else do
        putStrLn "Enter line number: "
        line <- getLine
        let l = (read line :: Int)
        putStrLn "Enter number of stars to remove: "
        stars <- getLine
        let n = (read stars :: Int)
        play (removeStars board l n)

-- n :: Int == number of lines
nim :: Int -> IO ()
nim n = play (reverse [1..n])
```