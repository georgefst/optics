-- |
--
-- Module: Optics
-- Description: The main module, usually you only need to import this one.
--
-- Introduction...
--
-- TODO: motivation behind @optics@
--
module Optics
  (
  -- * Basic usage
  -- $basicusage

  -- TODO: explain indexed optics

  -- * Differences from @lens@
  -- $differences

  -- * Core definitions

  -- | "Optics.Optic" module provides core definitions:
  --
  -- * Opaque 'Optic' type,
  --
  -- * which is parameterised over 'OpticKind';
  --
  -- * 'Is' and 'Join' relations, illustrated in the graph below;
  --
  -- * and optic composition operators '%' and '%%'.
  --
  -- <<optics.png Optics hierarchy>>
  --
  -- Red arrows connect optics which can be converted to each other with 're'.
  -- All other arrows represent 'Is' relation (partial order). The hierachy is a 'Join' semilattice, for example the
  -- 'Join' of a 'Lens' and a 'Prism' is an 'AffineTraversal'.
  --
  -- >>> :kind! Join A_Lens A_Prism
  -- Join A_Lens A_Prism :: OpticKind
  -- = 'An_AffineTraversal
  --
  -- There are also indexed variants of 'Traversal', 'Fold' and 'Setter'.
  -- Indexed optics are explained in more detail in /Differences from lens/ section.
  --
    module Optics.Optic

  -- * Optic variants

  -- |
  --
  -- There are 16 (TODO: add modules for LensyReview and PrismaticGetter)
  -- different kinds of optics, each documented in a separate module.
  -- Each optic module documentation has /formation/, /introduction/,
  -- /elimination/, and /well-formedness/ sections.
  --
  -- * The __formation__ sections contain type definitions. For example
  --
  --     @
  --     -- Tag for a lens.
  --     type 'A_Lens' = 'A_Lens
  --
  --     -- Type synonym for a type-modifying lens.
  --     type 'Lens' s t a b = 'Optic' 'A_Lens' i i s t a b
  --     @
  --
  -- * In the __introduction__ sections are described the ways to construct
  --   the particular optic. Continuing with a 'Lens' example:
  --
  --     @
  --     -- Build a lens from a getter and a setter.
  --     'lens' :: (s -> a) -> (s -> b -> t) :: 'Lens' i s t a b
  --     @
  --
  -- * In the __elimination__ sections are shown how you can destruct the
  --   optic into a pieces it was constructed from.
  --
  --     @
  --     -- 'Lens' is a 'Setter' and a 'Getter', therefore you can
  --
  --     'view1' :: 'Lens' i s t a b -> s -> a
  --     'set'   :: 'Lens' i s t a b -> b -> s -> t
  --     'over'  :: 'Lens' i s t a b -> (a -> b) -> s -> t
  --     @
  --
  -- * __Computation__ rules tie introduction and
  --   elimination combinators together. These rules are automatically
  --   fulfilled.
  --
  --     @
  --     'view1' ('lens' f g)   s = f s
  --     'set'   ('lens' f g) a s = g s a
  --     @
  --
  -- * All optics provided by the library are __well-formed__.
  --     Constructing of ill-formed optics is possible, but should be avoided.
  --     Ill-formed optic /might/ behave differently from what computation rules specify.
  --
  --     A 'Lens' should obey three laws, known as /GetPut/, /PutGet/ and /PutPut/.
  --     See "Optics.Lens" module for their definitions.
  --
  -- /Note:/ you should also consult the optics hierarchy diagram.
  -- Neither introduction or elimination sections list all ways to construct or use
  -- particular optic kind.
  -- For example you can construct 'Lens' from 'Iso' using 'sub'.
  -- Also, as a 'Lens' is also a 'Traversal', a 'Fold' etc, so you can use 'traverseOf', 'preview'
  -- and many other combinators.
  --
  , module O

  -- * Optics utilities

  -- ** Indexed optics

  -- | TODO
  , module Optics.Indexed

  -- ** Re

  -- | TODO
--  , module Optics.Re

  -- ** Each

  -- | A 'Traversal' for a (potentially monomorphic) container.
  --
  -- >>> over each (*10) (1,2,3)
  -- (10,20,30)
  --
  , module Optics.Each

  -- * Optics for concrete base types
  , module P
  )
  where

-- Core optics functionality

-- for some reason haddock reverses the list...

import Optics.Optic

import Optics.Traversal       as O
import Optics.Setter          as O
import Optics.Review          as O
import Optics.Prism           as O
import Optics.Lens            as O
import Optics.IxTraversal     as O
import Optics.IxSetter        as O
import Optics.IxFold          as O
import Optics.Iso             as O
import Optics.Getter          as O
import Optics.Fold            as O
import Optics.Equality        as O
import Optics.AffineTraversal as O
import Optics.AffineFold      as O

-- Optics utilities
import Optics.Each
import Optics.Indexed
-- import Optics.Re

-- Optics for concrete base types

import Data.Tuple.Optics  as P
import Data.Maybe.Optics  as P
import Data.Either.Optics as P

-- $basicusage
--
-- @
-- import "Optics"
-- @
--
-- and then...
--
-- Operators (if you prefer them) are in
--
-- @
-- import "Optics.Operators"
-- @
--


-- $differences
--
-- /This section is work-in-progress/
--
-- === From Adam's talk:
--
-- See @Talk.pdf@, or watch <https://skillsmatter.com/skillscasts/10692-through-a-glass-abstractly-lenses-and-the-power-of-abstraction>
--
-- * @optics@ has an abstract interface: 'Optic' is an opaque type
-- * Cannot write @optics@ without depending on the package,
--   therefore @optics-core@ doesnt' have non GHC-boot library dependencies.
--   (one cannot write /prisms/ with @lens@ without depending on @profunctors@, indexed optics require depending on @lens@ ...)
-- * abstract interface: @optics@ has better error messages (note: @silica@ is a hybrid approach)
--
--     >>> set (to fst)
--     ...
--     ...'A_Getter cannot be used as 'A_Setter
--     ...
--
-- * abstract interface: better type-inference (optics kind is preserved)
--
--     >>> :t traversed % to not
--     traversed % to not
--       :: Traversable t => Optic 'A_Fold o o (t Bool) (t Bool) Bool Bool
--
-- * abstract interface: not all optics have 'Join'
--
--     >>> sets map % to not
--     ...
--     ...'A_Setter cannot be composed with 'A_Getter
--     ...
--
-- * 'Optic' is a @Rank1Type@ (not really before #41), so there are no
--     need for @ALens@ etc.
-- * Types that say what they mean
-- * More comprehensible type errors
-- * Less vulnerable to the monomorphism restriction
-- * Free choice of lens implementation
-- * Indexed optics have different interface.
--
-- === Drawbacks
--
-- * Can’t insert points into the subtyping order post hoc
--
-- === Technical differences
--
-- * Composition operator is '%'
-- * 'view' is /smart/
-- * None of operators is exported from main module
-- * All ordinary optics are index-preserving by default
-- * Indexed optics interface is different (let's expand in own section, when the implementation is stabilised)
-- * There are no @Traversal1@
-- * There is 'AffineTraversal'
--
