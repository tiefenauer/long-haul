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

nim :: IO ()
nim = do      
    let board = reverse [1..5]             
    play board
         