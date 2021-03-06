module Control.Monad.Trans.Free.Freer.Spec where

import Control.Monad.Trans.Free.Freer
import Test.Hspec
import Test.Hspec.LeanCheck

spec :: Spec
spec = do
  describe "FreerF" $ do
    describe "Eq" $ do
      prop "is reflexive" $
        \ a -> a `shouldBe` (a :: FreerF Maybe Int Int)

      prop "is commutative" $
        \ a b -> a == b `shouldBe` b == (a :: FreerF Maybe Int Int)
