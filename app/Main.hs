{-# LANGUAGE TemplateHaskell #-}

module Main (main) where

import Import
import Run
import RIO.Process
import Options.Applicative.Simple
import qualified Paths_multy_snap

import Prelude (putStrLn)

main :: IO ()
main = do
  (options, cfgAction) <- simpleOptions
    $(simpleVersion Paths_multy_snap.version)
    "Multy-snap takes a config ens do periodic snapshots of the node."
    "Collect snapshots of resources of node and analyze them. Provide config file in YML format about shell command to produce stats you interested atand the interval the snapshots should be taken on."
    (Options
       <$> switch ( long "verbose"
                 <> short 'v'
                 <> help "Verbose output?"
                  )
    ) $ do addCommand "config"
                      "YML Config file"
                      mkConfig
                      configOptions
  
  lo  <- logOptionsHandle stderr (optionsVerbose options)
  pc  <- mkDefaultProcessContext
  cfgRes <- cfgAction
  case cfgRes of
    Left (_file, excStr) -> putStrLn excStr
    Right cfg -> withLogFunc lo $ \lf ->
      let app = App
              { appLogFunc = lf
              , appProcessContext = pc
              , appOptions = options
              , appConfig = cfg 
              }
      in runRIO app run

--- Helpers ---

configOptions :: Parser String
configOptions = strArgument $ metavar "FILEPATH" <> help "Path to config file"


