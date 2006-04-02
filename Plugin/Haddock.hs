--
-- | Hackish Haddock module.
--
module Plugin.Haddock (theModule) where

import Plugin

import qualified Data.Map as M
import qualified Data.FastPackedString as P

newtype HaddockModule = HaddockModule ()

theModule :: MODULE
theModule = MODULE $ HaddockModule ()

type HaddockState = M.Map P.FastString [P.FastString]

instance Module HaddockModule HaddockState where
    moduleCmds      _ = ["index"]
    moduleHelp    _ _ = "index <ident>. Returns the Haskell modules in which <ident> is defined"
    moduleDefState  _ = return M.empty
    moduleSerialize _ = Just $ Serial { deserialize = Just . readPacked
                                      , serialize   = const Nothing }
    process_ _ _ rest = do
       assocs <- readMS
       return . (:[]) $ maybe "bzzt" (concatWith ", " . (map P.unpack))
                                     (M.lookup (P.pack (stripParens rest)) assocs)

-- | make \@index ($) work.
stripParens :: String -> String
stripParens = reverse . dropWhile (==')') . reverse . dropWhile (=='(')
