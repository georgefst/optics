{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
module Main where

import Optics.AffineFold
import Optics.AffineTraversal
import Optics.Fold
import Optics.Getter
import Optics.Iso
import Optics.Lens
import Optics.Prism
import Optics.Operators
import Optics.TH
import Optics.Traversal

import Optics.TH.Tests.T799 ()

data Bar a b c = Bar { _baz :: (a, b) }
makeLenses ''Bar

checkBaz :: Iso (Bar a b c) (Bar a' b' c') (a, b) (a', b')
checkBaz = baz

data Quux a b = Quux { _quaffle :: Int, _quartz :: Double }
makeLenses ''Quux

checkQuaffle :: Lens (Quux a b) (Quux a' b') Int Int
checkQuaffle = quaffle

checkQuartz :: Lens (Quux a b) (Quux a' b') Double Double
checkQuartz = quartz

data Quark a = Qualified   { _gaffer :: a }
             | Unqualified { _gaffer :: a, _tape :: a }
makeLenses ''Quark

checkGaffer :: Lens' (Quark a) a
checkGaffer = gaffer

checkTape :: AffineTraversal' (Quark a) a
checkTape = tape

data Hadron a b = Science { _a1 :: a, _a2 :: a, _c :: b }
makeLenses ''Hadron

checkA1 :: Lens' (Hadron a b) a
checkA1 = a1

checkA2 :: Lens' (Hadron a b) a
checkA2 = a2

checkC :: Lens (Hadron a b) (Hadron a b') b b'
checkC = c

data Perambulation a b
  = Mountains { _terrain    :: a
              , _altitude   :: b
              , _absurdity1 :: forall x y. x -> y
              , _absurdity2 :: forall x y. x -> y
              }
  | Beaches   { _terrain    :: a
              , _dunes      :: a
              , _absurdity1 :: forall x y. x -> y
              }
makeLenses ''Perambulation

checkTerrain :: Lens' (Perambulation a b) a
checkTerrain = terrain

checkAltitude :: AffineTraversal (Perambulation a b) (Perambulation a b') b b'
checkAltitude = altitude

checkAbsurdity1 :: Getter (Perambulation a b) (x -> y)
checkAbsurdity1 = absurdity1

checkAbsurdity2 :: AffineFold (Perambulation a b) (x -> y)
checkAbsurdity2 = absurdity2

checkDunes :: AffineTraversal' (Perambulation a b) a
checkDunes = dunes

makeLensesFor [ ("_terrain", "allTerrain"), ("_dunes", "allTerrain")
              , ("_absurdity1", "absurdities"), ("_absurdity2", "absurdities")
              ]
  ''Perambulation

checkAllTerrain :: Traversal (Perambulation a b) (Perambulation a' b) a a'
checkAllTerrain = allTerrain

checkAbsurdities :: Fold (Perambulation a b) (x -> y)
checkAbsurdities = absurdities

data LensCrafted a = Still { _still :: a }
                   | Works { _still :: a }
makeLenses ''LensCrafted

checkStill :: Lens (LensCrafted a) (LensCrafted b) a b
checkStill = still

data Task a = Task
  { taskOutput :: a -> IO ()
  , taskState :: a
  , taskStop :: IO ()
  }

makeLensesFor [("taskOutput", "outputLens"), ("taskState", "stateLens"), ("taskStop", "stopLens")] ''Task

checkOutputLens :: Lens' (Task a) (a -> IO ())
checkOutputLens = outputLens

checkStateLens :: Lens' (Task a) a
checkStateLens = stateLens

checkStopLens :: Lens' (Task a) (IO ())
checkStopLens = stopLens

data Mono a = Mono { _monoFoo :: a, _monoBar :: Int }
makeClassy ''Mono
-- class HasMono t where
--   mono :: Simple Lens t Mono
-- instance HasMono Mono where
--   mono = id

checkMono :: HasMono t a => Lens' t (Mono a)
checkMono = mono

checkMono' :: Lens' (Mono a) (Mono a)
checkMono' = mono

checkMonoFoo :: HasMono t a => Lens' t a
checkMonoFoo = monoFoo

checkMonoBar :: HasMono t a => Lens' t Int
checkMonoBar = monoBar

data Nucleosis = Nucleosis { _nuclear :: Mono Int }
makeClassy ''Nucleosis
-- class HasNucleosis t where
--   nucleosis :: Simple Lens t Nucleosis
-- instance HasNucleosis Nucleosis

checkNucleosis :: HasNucleosis t => Lens' t Nucleosis
checkNucleosis = nucleosis

checkNucleosis' :: Lens' Nucleosis Nucleosis
checkNucleosis' = nucleosis

checkNuclear :: HasNucleosis t => Lens' t (Mono Int)
checkNuclear = nuclear

instance HasMono Nucleosis Int where
  mono = nuclear

-- Dodek's example
data Foo = Foo { _fooX, _fooY :: Int }
makeClassy ''Foo

checkFoo :: HasFoo t => Lens' t Foo
checkFoo = foo

checkFoo' :: Lens' Foo Foo
checkFoo' = foo

checkFooX :: HasFoo t => Lens' t Int
checkFooX = fooX

checkFooY :: HasFoo t => Lens' t Int
checkFooY = fooY

data Dude a = Dude
    { dudeLevel        :: Int
    , dudeAlias        :: String
    , dudeLife         :: ()
    , dudeThing        :: a
    }
makeFields ''Dude

checkLevel :: HasLevel t a => Lens' t a
checkLevel = level

checkLevel' :: Lens' (Dude a) Int
checkLevel' = level

checkAlias :: HasAlias t a => Lens' t a
checkAlias = alias

checkAlias' :: Lens' (Dude a) String
checkAlias' = alias

checkLife :: HasLife t a => Lens' t a
checkLife = life

checkLife' :: Lens' (Dude a) ()
checkLife' = life

checkThing :: HasThing t a => Lens' t a
checkThing = thing

checkThing' :: Lens' (Dude a) a
checkThing' = thing

data Lebowski a = Lebowski
    { _lebowskiAlias    :: String
    , _lebowskiLife     :: Int
    , _lebowskiMansion  :: String
    , _lebowskiThing    :: Maybe a
    }
makeFields ''Lebowski

checkAlias2 :: Lens' (Lebowski a) String
checkAlias2 = alias

checkLife2 :: Lens' (Lebowski a) Int
checkLife2 = life

checkMansion :: HasMansion t a => Lens' t a
checkMansion = mansion

checkMansion' :: Lens' (Lebowski a) String
checkMansion' = mansion

checkThing2 :: Lens' (Lebowski a) (Maybe a)
checkThing2 = thing

type family Fam a
type instance Fam Int = String

data FamRec a = FamRec
  { _famRecThing :: Fam a
  , _famRecUniqueToFamRec :: Fam a
  }
makeFields ''FamRec

checkFamRecThing :: Lens' (FamRec a) (Fam a)
checkFamRecThing = thing

checkFamRecUniqueToFamRec :: Lens' (FamRec a) (Fam a)
checkFamRecUniqueToFamRec = uniqueToFamRec

checkFamRecView :: FamRec Int -> String
checkFamRecView = view thing

data AbideConfiguration a = AbideConfiguration
    { _acLocation       :: String
    , _acDuration       :: Int
    , _acThing          :: a
    }
makeLensesWith abbreviatedFields ''AbideConfiguration

checkLocation :: HasLocation t a => Lens' t a
checkLocation = location

checkLocation' :: Lens' (AbideConfiguration a) String
checkLocation' = location

checkDuration :: HasDuration t a => Lens' t a
checkDuration = duration

checkDuration' :: Lens' (AbideConfiguration a) Int
checkDuration' = duration

checkThing3 :: Lens' (AbideConfiguration a) a
checkThing3 = thing

dudeDrink :: String
dudeDrink      = (Dude 9 "El Duderino" () "white russian")      ^. thing
lebowskiCarpet :: Maybe String
lebowskiCarpet = (Lebowski "Mr. Lebowski" 0 "" (Just "carpet")) ^. thing
abideAnnoyance :: String
abideAnnoyance = (AbideConfiguration "the tree" 10 "the wind")  ^. thing

declareLenses [d|
  data Quark1 a = Qualified1   { gaffer1 :: a }
                | Unqualified1 { gaffer1 :: a, tape1 :: a }
  |]
-- data Quark1 a = Qualified1 a | Unqualified1 a a

checkGaffer1 :: Lens' (Quark1 a) a
checkGaffer1 = gaffer1

checkTape1 :: AffineTraversal' (Quark1 a) a
checkTape1 = tape1

declarePrisms [d|
  data Exp = Lit Int | Var String | Lambda { bound::String, body::Exp }
  |]
-- data Exp = Lit Int | Var String | Lambda { bound::String, body::Exp }

checkLit :: Int -> Exp
checkLit = Lit

checkVar :: String -> Exp
checkVar = Var

checkLambda :: String -> Exp -> Exp
checkLambda = Lambda

check_Lit :: Prism' Exp Int
check_Lit = _Lit

check_Var :: Prism' Exp String
check_Var = _Var

check_Lambda :: Prism' Exp (String, Exp)
check_Lambda = _Lambda


declarePrisms [d|
  data Banana = Banana Int String
  |]
-- data Banana = Banana Int String

check_Banana :: Iso' Banana (Int, String)
check_Banana = _Banana

cavendish :: Banana
cavendish = _Banana # (4, "Cavendish")

data family Family a b c

declareLenses [d|
  data instance Family Int (a, b) a = FamilyInt { fm0 :: (b, a), fm1 :: Int }
  |]
-- data instance Family Int (a, b) a = FamilyInt a b
checkFm0 :: Lens (Family Int (a, b) a) (Family Int (a', b') a') (b, a) (b', a')
checkFm0 = fm0

checkFm1 :: Lens' (Family Int (a, b) a) Int
checkFm1 = fm1

class Class a where
  data Associated a
  method :: a -> Int

declareLenses [d|
  instance Class Int where
    data Associated Int = AssociatedInt { mochi :: Double }
    method = id
  |]

-- instance Class Int where
--   data Associated Int = AssociatedInt Double
--   method = id

checkMochi :: Iso' (Associated Int) Double
checkMochi = mochi

declareFields [d|
  data DeclaredFields f a
    = DeclaredField1 { declaredFieldsA0 :: f a    , declaredFieldsB0 :: Int }
    | DeclaredField2 { declaredFieldsC0 :: String , declaredFieldsB0 :: Int }
    deriving (Show)
  |]

checkA0 :: HasA0 t a => AffineTraversal' t a
checkA0 = a0

checkB0 :: HasB0 t a => Lens' t a
checkB0 = b0

checkC0 :: HasC0 t a => AffineTraversal' t a
checkC0 = c0

checkA0' :: AffineTraversal' (DeclaredFields f a) (f a)
checkA0' = a0

checkB0' :: Lens' (DeclaredFields f a) Int
checkB0' = b0

checkC0' :: AffineTraversal' (DeclaredFields f a) String
checkC0' = c0

declareFields [d|
    data Aardvark = Aardvark { aardvarkAlbatross :: Int }
    data Baboon   = Baboon   { baboonAlbatross   :: Int }
  |]

checkAardvark :: Lens' Aardvark Int
checkAardvark = albatross

checkBaboon :: Lens' Baboon Int
checkBaboon = albatross

data Rank2Tests
  = C1 { _r2length :: forall a. [a] -> Int
       , _r2nub    :: forall a. Eq a => [a] -> [a]
       }
  | C2 { _r2length :: forall a. [a] -> Int }

makeLenses ''Rank2Tests

checkR2length :: Getter Rank2Tests ([a] -> Int)
checkR2length = r2length

checkR2nub :: Eq a => AffineFold Rank2Tests ([a] -> [a])
checkR2nub = r2nub

data PureNoFields = PureNoFieldsA | PureNoFieldsB { _pureNoFields :: Int }
makeLenses ''PureNoFields

data ReviewTest where ReviewTest :: a -> ReviewTest
makePrisms ''ReviewTest


-- test FieldNamers

data CheckUnderscoreNoPrefixNamer = CheckUnderscoreNoPrefixNamer
                                    { _fieldUnderscoreNoPrefix :: Int }
makeLensesWith (lensRules & lensField .~ underscoreNoPrefixNamer ) ''CheckUnderscoreNoPrefixNamer
checkUnderscoreNoPrefixNamer :: Iso' CheckUnderscoreNoPrefixNamer Int
checkUnderscoreNoPrefixNamer = fieldUnderscoreNoPrefix

-- how can we test NOT generating a lens for some fields?

data CheckMappingNamer = CheckMappingNamer
                         { fieldMappingNamer :: String }
makeLensesWith (lensRules & lensField .~ (mappingNamer (return . ("hogehoge_" ++)))) ''CheckMappingNamer
checkMappingNamer :: Iso' CheckMappingNamer String
checkMappingNamer = hogehoge_fieldMappingNamer

data CheckLookingupNamer = CheckLookingupNamer
                           { fieldLookingupNamer :: Int }
makeLensesWith (lensRules & lensField .~ (lookingupNamer [("fieldLookingupNamer", "foobarFieldLookingupNamer")])) ''CheckLookingupNamer
checkLookingupNamer :: Iso' CheckLookingupNamer Int
checkLookingupNamer = foobarFieldLookingupNamer

data CheckUnderscoreNamer = CheckUnderscoreNamer
                            { _hogeprefix_fieldCheckUnderscoreNamer :: Int }
makeLensesWith (defaultFieldRules & lensField .~ underscoreNamer) ''CheckUnderscoreNamer
checkUnderscoreNamer :: Lens' CheckUnderscoreNamer Int
checkUnderscoreNamer = fieldCheckUnderscoreNamer

data CheckCamelCaseNamer = CheckCamelCaseNamer
                           { _checkCamelCaseNamerFieldCamelCaseNamer :: Int }
makeLensesWith (defaultFieldRules & lensField .~ camelCaseNamer) ''CheckCamelCaseNamer
checkCamelCaseNamer :: Lens' CheckCamelCaseNamer Int
checkCamelCaseNamer = fieldCamelCaseNamer

data CheckAbbreviatedNamer = CheckAbbreviatedNamer
                             { _hogeprefixFieldAbbreviatedNamer :: Int }
makeLensesWith (defaultFieldRules & lensField .~ abbreviatedNamer ) ''CheckAbbreviatedNamer
checkAbbreviatedNamer :: Lens' CheckAbbreviatedNamer Int
checkAbbreviatedNamer = fieldAbbreviatedNamer

main :: IO ()
main = putStrLn "optics-th-tests: ok"
