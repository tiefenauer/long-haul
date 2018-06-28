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