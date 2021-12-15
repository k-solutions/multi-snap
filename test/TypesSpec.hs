module TypesSpec (spec) where

import Import
import Util
import Test.Hspec
import Test.Hspec.QuickCheck

spec :: Spec
spec = do 
  describe "config" $ do
    it "set only Just" 
--    prop "encode <=> decode" $ \i -> plus2 i - 2 `shouldBe` i

--- Helper ---

testCmd  :: Value
testCmds = object  [ "cat /proc/meminfo"
                   , "df -h"
                   , "vmstat"
                   , "ps -eo pcpu,pid,user,args | sort -k 1 -r | head -10"
                   , "docker stats --no-stream"
                   ]

