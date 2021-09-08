{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DeriveGeneric #-}
{-# OPTIONS_GHC -ddump-splices #-}
module Main
  ( main,
  )
where

import Data.Morpheus.Document (importGQLDocument)

importGQLDocument "src/schema.gql"

-- main :: IO ()
-- main = return ()
