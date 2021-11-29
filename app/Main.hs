{-# LANGUAGE TemplateHaskell #-}

module Main (main) where

import Import
import Run
import RIO.Process
import Options.Applicative.Simple
import qualified Paths_multy_snap
import Util (testCmds)
import Import (Options(optionsConfigFile))
import Data.Yaml.Config 

import Prelude (putStrLn)

mkDefaultCfg :: IO Config
mkDefaultCfg = pure $ Config (map Cmd testCmds) 100

main :: IO ()
main = do
  (options, ()) <- simpleOptions
    $(simpleVersion Paths_multy_snap.version)
    "Header for command line arguments"
    "Program description, also for command line arguments"
    (Options
       <$> switch ( long "verbose"
                 <> short 'v'
                 <> help "Verbose output?"
                  )
       <*>  strOption (  long "config"
                      <> short 'c'
                      <> help "A config file to load commands as Yaml array and interval (in sec.) for snapshot execution"
                      <> metavar "CONFIG"
                      <> value "default.yml"
                      <> showDefault
                      )          
    )
    empty

  -- | show parsed options
  putStrLn $ "Parsed options are: " <> optionsConfigFile options 
  
  lo  <- logOptionsHandle stderr (optionsVerbose options)
  pc  <- mkDefaultProcessContext
  cfg <- loadYamlSettings [optionsConfigFile options] [] useEnv
  withLogFunc lo $ \lf ->
    let app = App
          { appLogFunc = lf
          , appProcessContext = pc
          , appOptions = options
          , appConfig = cfg 
          }
     in runRIO app run
