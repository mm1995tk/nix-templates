module Main (main) where

import Lib (someFunc)

main :: IO ()
main = do
  someFunc
  putStrLn "hello y!"
