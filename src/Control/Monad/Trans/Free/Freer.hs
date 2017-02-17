{-# LANGUAGE GADTs, RankNTypes #-}
module Control.Monad.Trans.Free.Freer where

import Data.Bifunctor
import Data.Functor.Classes
import Data.Functor.Listable

data FreerF f a b where
  Pure :: a -> FreerF f a b
  Free :: (x -> b) -> f x -> FreerF f a b


liftFreerF :: f b -> FreerF f a b
liftFreerF = Free id

hoistFreerF :: (forall a. f a -> g a) -> FreerF f b c -> FreerF g b c
hoistFreerF f r = case r of
  Pure a -> Pure a
  Free t r -> Free t (f r)


-- Instances

instance Bifunctor (FreerF f) where
  bimap f g r = case r of
    Pure a -> Pure (f a)
    Free t r -> Free (g . t) r

instance Functor (FreerF f a) where
  fmap = second


instance Foldable f => Foldable (FreerF f a) where
  foldMap f g = case g of
    Pure _ -> mempty
    Free t r -> foldMap (f . t) r

instance Traversable f => Traversable (FreerF f a) where
  traverse f g = case g of
    Pure a -> pure (Pure a)
    Free t r -> Free id <$> traverse (f . t) r


instance Eq1 f => Eq2 (FreerF f) where
  liftEq2 eqA eqB f1 f2 = case (f1, f2) of
    (Pure a1, Pure a2) -> eqA a1 a2
    (Free t1 r1, Free t2 r2) -> liftEq (\ x1 x2 -> eqB (t1 x1) (t2 x2)) r1 r2
    _ -> False

instance (Eq1 f, Eq a) => Eq1 (FreerF f a) where
  liftEq = liftEq2 (==)

instance (Eq1 f, Eq a, Eq b) => Eq (FreerF f a b) where
  (==) = liftEq (==)


instance Show1 f => Show2 (FreerF f) where
  liftShowsPrec2 sp1 _ sp2 sa2 d f = case f of
    Pure a -> showsUnaryWith sp1 "Pure" d a
    Free t r -> showsBinaryWith (const showString) (liftShowsPrec (\ i -> sp2 i . t) (sa2 . fmap t)) "Free" d "id" r

instance (Show1 f, Show a) => Show1 (FreerF f a) where
  liftShowsPrec = liftShowsPrec2 showsPrec showList

instance (Show1 f, Show a, Show b) => Show (FreerF f a b) where
  showsPrec = liftShowsPrec showsPrec showList


instance Listable1 f => Listable2 (FreerF f) where
  liftTiers2 t1 t2 = liftCons1 t1 Pure \/ liftCons1 (liftTiers t2) (Free id)

instance (Listable a, Listable1 f) => Listable1 (FreerF f a) where
  liftTiers = liftTiers2 tiers

instance (Listable a, Listable b, Listable1 f) => Listable (FreerF f a b) where
  tiers = liftTiers tiers