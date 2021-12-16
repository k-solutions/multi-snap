{-# LANGUAGE QuasiQuotes #-}

module TypesSpec (spec) where

import Import
import Types 
import Test.Hspec
import Test.Hspec.QuickCheck
import Data.Aeson (decode)
import Text.RawString.QQ
import qualified Data.List.NonEmpty as NeList
import qualified RIO.ByteString.Lazy as LBStr

spec :: Spec
spec = do 
  describe "config" $ do
    it "with empty list" $
      (decode emptyCmds :: Maybe CmdList) `shouldBe` Nothing
    it "parsse only  non empty" $ 
      (decode testCmds :: Maybe CmdList) `shouldBe` asCmdList [Cmd "cat" ["/proc/meminfo"]]  

--- Helpers ---
asCmdList :: [Cmd] -> Maybe CmdList 
asCmdList = Just 
          . CmdList 
          . NeList.fromList 

testCmds :: LBStr.ByteString
testCmds = [r| 
             [ "cat /proc/meminfo"
             , "   "
             ] 
           |]
emptyCmds :: LBStr.ByteString
emptyCmds = [r|
              [ "   "
              , " "
              ]
            |]
