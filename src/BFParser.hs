module BFParser where

import Text.ParserCombinators.Parsec hiding (spaces)
--import Control.Monad.State
import Data.Char

data BF = BF
        { register :: [Int]
        , pointer  ::  Int
        } deriving (Show)

symbol :: Parser Char
symbol = oneOf "+-<>[],."

readExpr :: String -> String
readExpr input = 
    case parse (spaces >> symbol) "brainf*ck" input of
        Left err -> "No match:" ++ show err
        Right val -> "Foudn value"

spaces :: Parser ()
spaces = skipMany1 space

bfInit ::  BF
bfInit = BF 
        { register = [0, 0 ..]
        , pointer = 0 }

bfRun :: String -> IO BF
bfRun cmd = bfRun' cmd bfInit
    where
        bfRun' :: String -> BF -> IO BF
        bfRun' [] bf = return $ bf
        bfRun' (cmd : xs) bf = do {newBF <- bfDo bf cmd; bfRun' xs newBF}

bfDo :: BF -> Char -> IO BF
bfDo bf cmd = case cmd of
        '+' -> return $ bfReg (+ 1) bf
        '-' -> return $ bfReg (subtract 1) bf
        '>' -> return $ bfShift (+ 1) bf
        '<' -> return $ bfShift (subtract 1) bf
        '.' -> bfPrint bf
        ',' -> undefined
        '[' -> undefined
        ']' -> undefined
        _   -> undefined

bfReg :: (Int -> Int) -> BF -> BF
bfReg f bf = bf { register = localMap f (pointer bf) (register bf) }

bfShift :: (Int -> Int) -> BF -> BF
bfShift f bf = bf { pointer = f $ pointer bf}

chrToStr :: Char -> String
chrToStr chr = [chr]

bfPrint :: BF -> IO BF
bfPrint bf = do
 putStr . chrToStr . chr $ (register bf) !! (pointer bf)
 return bf

localMap :: Num a => (a -> a) -> Int -> [a] -> [a]
localMap f pos list = (take pos list) ++ f (list !! pos) : drop (pos + 1) list
