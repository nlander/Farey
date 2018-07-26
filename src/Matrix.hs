module Matrix where
import           BinaryTrees
import           Control.Monad
import           Data.Monoid
import           Fractions
import           RationalTrees


data SternTerm = L | R deriving (Eq, Show)
type SternPath = [SternTerm]

data Matrix = M Integer Integer Integer Integer deriving Show

instance Monoid Matrix where
    mempty = ident -- Identity 2x2 matrix
    -- matrix multiplication
    mappend (M a b c d) (M w x y z) =
        M (a*w + b*y) (a*x + b*z) (c*w + d*y) (c*x + d*z)

left :: Matrix
left = M 1 1 0 1

right :: Matrix
right = M 1 0 1 1

ident :: Matrix
ident = M 1 0 0 1

sternTermMatrix :: SternTerm -> Matrix
sternTermMatrix t = if t == L then left else right

reduceMatrix :: Matrix -> Fraction
reduceMatrix (M a b c d) = F (c + d) (a + b)

reduceSternPath :: SternPath -> Fraction
reduceSternPath   = reduceMatrix . foldl (\ acc t -> sternTermMatrix t <> acc ) ident

reduceSternPath' :: SternPath -> Fraction
reduceSternPath' = reduceMatrix . mconcat . fmap sternTermMatrix


sternPath :: Fraction -> SternPath
sternPath frac = go (fraction <$> buildBrocTreeLazy) fr [] where
        fr = reduce frac
        go (BNode (F p q) l r) (F n d) path
            | p == n && q == d   = path
            | F p q < F n d      = go r fr (R : path)
            | otherwise          = go l fr (L : path)

sternPathNM :: Fraction -> SternPath
sternPathNM (F m n) = go m n  where
    go m' n'
        | n' == m' = []
        | m' < n'   = L : go m' (n' - m')
        | otherwise = R : go (m' - n') n'

sternPathFloat :: Float -> SternPath
sternPathFloat  = go  where
    go d
        | d < 1 = L : go (d / (1 - d))
        | otherwise = R : go (d - 1)

fractionPathString :: String -> [Fraction]
fractionPathString  = fractionPath . fmap (\x -> if x == 'L' then L else R)


fractionPath :: SternPath -> [Fraction]
fractionPath  = go ( fraction <$> buildBrocTreeLazy)  where
    go (BNode frac _ _) []     = [frac]
    go (BNode frac l r) (p:ps) = frac : go (pick p l r) ps where
        pick p l r = if p == L then l else r

