-- Hangman
import System.IO

match :: String -> String -> String
match xs ys = [if elem x ys then x else '-' | x <- xs]

play' :: String -> IO ()
play' word =
    do putStr "? "
       guess <- getLine
       if guess == word then
           putStrLn "You got it!"
       else
           do putStrLn (match word guess)
              play' word

getCh :: IO Char
getCh = do hSetEcho stdin False
           x <- getChar
           hSetEcho stdin True
           return x

sgetLine :: IO String
sgetLine = do x <- getCh
              if x == '\n' then
                   do putChar x
                      return []
              else
                   do putChar '-'
                      xs <- sgetLine
                      return (x:xs)

hangman :: IO ()
hangman = do putStrLn "Think of a word: "
             word <- sgetLine
             putStrLn "Try to guess it:"
             play' word

-- Game of nim (without input validation
showBoard :: [Int] -> IO ()
showBoard xs = do mapM_ putStrLn [replicate x '*' | x <- xs]

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