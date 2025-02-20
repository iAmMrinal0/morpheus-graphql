{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE TypeFamilies #-}

module API.Users.Users where

import Data.Data (Typeable)
import Data.Morpheus.Kind (TYPE)
import Data.Morpheus.Types
import Data.Text (Text)
import GHC.Generics (Generic)

---- GQL User -------------------------------
data User m = User
  { id :: m ID,
    name :: m Text
  }
  deriving (Generic)

instance (Typeable m) => GQLType (User m) where
  type KIND (User m) = TYPE

---- GQL Query -------------------------------
data Query m = Query
  { users :: m [User m],
    user :: Arg "id" ID -> m (Maybe (User m))
  }
  deriving (Generic)

instance (Typeable m) => GQLType (Query m) where
  type KIND (Query m) = TYPE
