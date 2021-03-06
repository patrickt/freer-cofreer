module Control.Monad.Free.Freer.Spec where

import Control.Monad.Free.Freer
import Test.Hspec
import Test.Hspec.LeanCheck

spec :: Spec
spec = do
  describe "Freer" $ do
    describe "Eq" $ do
      prop "is reflexive" $
        \ a -> a `shouldBe` (a :: Freer Maybe Int)

      prop "is commutative" $
        \ a b -> a == b `shouldBe` b == (a :: Freer Maybe Int)
