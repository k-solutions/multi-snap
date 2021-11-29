-- | Silly utility module, used to demonstrate how to write a test
-- case.
module Util
  ( plus2
  , testCmds
  ) where

import RIO
 
testCmds = [ "cat /proc/meminfo"
           , "df -h"
           , "vmstat"
           , "ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
           , "docker stats --no-stream"
           ]

plus2 :: Int -> Int
plus2 = (+ 2)
