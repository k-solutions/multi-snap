module Types where

import RIO
import RIO.Process
import RIO.Lens
import Control.Concurrent.STM (TVar)
import Data.Aeson (withObject)
import Data.Yaml
import qualified Data.Map as Map
import qualified RIO.NonEmpty as NonEmpty
import qualified RIO.Vector as Vector 
import qualified RIO.Text as Text 

-- import qualified RIO.Prelude as Map

-- | Command error
data CmdError = CmdError Cmd ByteString
                   deriving (Show, Typeable)

-- | Command line arguments 
data Options = Options
  { optionsVerbose :: !Bool
  } 

data PercentVal a = PercentVal
                { pvVal :: !a
                , pvPercent :: !Double
                , pvMax :: !a 
                } deriving (Eq,  Show)

data DataUnit = Percent
              | Kb 
              | Mb 
              | Gb 
              deriving (Eq, Show)

data Device = CPU
            | Memory
            | Disk
            deriving (Eq, Show )

data Metrics = Metrics
             { msValue  :: !Int 
             , msDevice :: !Device
             , msDataUnit :: !DataUnit  
             }

-- | 'Result' of the operation
newtype Result = Result (NonEmpty Metrics)

data Cmd = Cmd 
         { cmdShell :: !Text
         , cmdArgs  :: [Text] 
         } deriving (Eq, Show, Generic)

-- | Custom JSON parser for Cmd
parseCmd :: Value -> Parser (Maybe Cmd)
parseCmd = withText "command" (pure . arrToCmd . Text.words) 

newtype CmdList = CmdList (NonEmpty Cmd)
                  deriving (Eq, Show)
instance FromJSON CmdList where
   parseJSON = withArray "commands" (toCmdList . Vector.toList)    
                   
type Snapshot = Map Cmd Result
type CmdResult = Either [CmdError] Snapshot

-- | Config data comming form application config 
data Config = Config
            { cfgCommands :: !CmdList
            , cfgSnapInterval :: !Int    --- in seconds 
            } deriving (Eq, Show)
instance FromJSON Config where
    parseJSON = withObject "Config"$ \o -> Config
              <$> o .: "commands" 
              <*> o .: "snap-interval"

cfgCmdsL :: Lens' Config CmdList
cfgCmdsL = lens cfgCommands (\x y -> x {cfgCommands = y})

data App = App
  { appLogFunc :: !LogFunc
  , appProcessContext :: !ProcessContext
  , appOptions :: !Options
  , appConfig :: !Config
  , appResult :: TVar CmdResult 
  }
      
class HasConfig env where 
    configCtxL :: Lens' env Config

class HasResult env where
    resultCtxL :: Lens' env (TVar CmdResult)    

instance HasLogFunc App where
  logFuncL = lens appLogFunc (\x y -> x { appLogFunc = y })
instance HasProcessContext App where
  processContextL = lens appProcessContext (\x y -> x { appProcessContext = y })
instance HasConfig App where
  configCtxL = lens appConfig (\x y -> x { appConfig = y })  
instance HasResult App where
  resultCtxL = lens appResult (\x y -> x { appResult = y })

--- Helpers --- 

toCmdList :: [Value] -> Parser CmdList
toCmdList vs = do
    mCmds <- mapM parseCmd vs
    let cmds = catMaybes mCmds
    case NonEmpty.nonEmpty cmds of
      Just nCmds -> pure . CmdList $ nCmds
      Nothing    -> fail " empty commands list" 

arrToCmd :: [Text] -> Maybe Cmd
arrToCmd arr = case arr of
                 [cmd]      -> Just $ Cmd cmd []
                 (cmd:args) -> Just $ Cmd cmd args
                 _          -> Nothing 

newSnapshot :: Snapshot
newSnapshot = Map.empty
