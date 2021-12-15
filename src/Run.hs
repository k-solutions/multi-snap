module Run (run) where

import Import
import Data.Semigroup (Endo(appEndo))
import RIO.Process hiding (proc)   -- (HasProcessContext(processContextL))
import Types
import qualified RIO.Text as Text
import System.Process.Typed (proc)


run :: RIO App ()
run = do
  runCmds  
  logInfo "We're inside the application!"

-- | 'runCmds' given commands according envirnment
runCmds :: RIO App ()
runCmds = do
    env <- ask
    let (CmdList cfgCmds) = env ^. configCtxL . cfgCmdsL
        procCtx           = env ^. processContextL 
    forConcurrently_ cfgCmds $ \(Cmd cmd args) -> do
        let cmdStr  = Text.unpack cmd
            argsStr = map Text.unpack args 
        extCode <- runProcess $ proc cmdStr argsStr  
        logInfo $ "Process exit code: " <> displayShow extCode
