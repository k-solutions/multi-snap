module Run (run) where

import Import
import Data.Semigroup (Endo(appEndo))
import RIO.Process -- (HasProcessContext(processContextL))
import Types
import System.Process.Typed (shell)


run :: RIO App ()
run = do
  runCmds  
  logInfo "We're inside the application!"

-- | 'runCmds' given commands according envirnment
runCmds :: RIO App ()
runCmds = do
    env <- ask
    let procCtx = env ^. processContextL
        cfgCmds  = env ^. configCtxL . cfgCmdsL 
    forConcurrently_ cfgCmds $ 
      \(Cmd cmd) -> do
        extCode <- runProcess $ shell cmd
        logInfo $ "Process exit code: " <> displayShow extCode
      
