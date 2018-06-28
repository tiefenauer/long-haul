-- (1) A triple (x,y,z) of positive integers is called pythagorean if x2 + y2 = z2.  Using a list comprehension, define a function
pyths n = [(x,y,z) | x <- [1..n], y <- [1..n], z <- [1..n], x*x + y*y == z*z]

-- (2) A positive integer is perfect if it equals the sum of all of its factors, excluding the number itself.  Using a list comprehension, define a function
factors n = [x | x <- [1..n], n `mod` x == 0 && x /= n]
perfects n = [x | x <- [1..n], sum (factors x) == x]

-- (3) The scalar product of two lists of integers xs and ys of length n is give by the sum of the products of the corresponding integers:
scalar xs ys = sum [x*y | (x,y) <- zip xs ys]