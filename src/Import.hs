module Import
  ( module RIO
  , module Types
  , mkConfig
  ) where

import RIO
import Types
import Data.Yaml
import Data.Yaml.Config 

mkConfig ::  FilePath 
          -> IO (Either (FilePath, String) Config)
mkConfig file = do  
   res <- tryAny $ loadYamlSettings [file] [] useEnv
   pure $ case res of
     Left e -> Left (file, displayException e)
     Right cfg@Config {..}            -> Right cfg 

