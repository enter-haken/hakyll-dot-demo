{-# LANGUAGE OverloadedStrings #-}
import qualified Data.Text as T
import Hakyll
import Text.Pandoc

import Text.Pandoc.Walk ( walkM )

main :: IO ()
main = hakyll $ do
    match "index.markdown" $ do
        route $ setExtension "html"
        compile $ pandocPostCompiler 
            >>= loadAndApplyTemplate "template.html" defaultContext

    match "template.html" $ compile templateCompiler

pandocPostCompiler :: Compiler (Item String)
pandocPostCompiler = pandocCompilerWithTransformM
    defaultHakyllReaderOptions
    defaultHakyllWriterOptions
    graphViz

graphViz :: Pandoc -> Compiler Pandoc
graphViz = walkM codeBlock

codeBlock :: Block -> Compiler Block
codeBlock (CodeBlock (_id, _classes, namevals) contents)
    | ("lang", "dot") `elem` namevals
    = RawBlock (Format "html") <$> svg contents
codeBlock x = return x

svg :: T.Text -> Compiler T.Text
svg contents = T.pack <$> unixFilter "dot" ["-Tsvg"] (T.unpack contents)
