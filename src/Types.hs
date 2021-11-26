module Types where

import RIO
import RIO.Process
import RIO.Lens

-- | Command line arguments
data Options = Options
  { optionsVerbose :: !Bool
  }

type CmdList = [Cmd]
data Config = Config
            { cfgCommands :: CmdList  
            }

cfgCmdsL :: Lens' Config CmdList
cfgCmdsL = lens cfgCommands (\x y -> x {cfgCommands = y})

data App = App
  { appLogFunc :: !LogFunc
  , appProcessContext :: !ProcessContext
  , appOptions :: !Options
  -- Add other app-specific configuration information here
  , appConfig :: !Config
  }

class HasConfig env where
    configCtxL :: Lens' env Config

instance HasLogFunc App where
  logFuncL = lens appLogFunc (\x y -> x { appLogFunc = y })
instance HasProcessContext App where
  processContextL = lens appProcessContext (\x y -> x { appProcessContext = y })
instance HasConfig App where
  configCtxL = lens appConfig (\x y -> x { appConfig = y })  

newtype Cmd = Cmd String 
              deriving (Eq, Show)

