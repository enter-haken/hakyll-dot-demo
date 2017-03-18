{-# LANGUAGE OverloadedStrings #-}
import Hakyll
import Text.Pandoc
import System.Process ( readProcess )
import System.IO.Unsafe ( unsafePerformIO )

import Text.Pandoc.Walk ( walk )

main :: IO ()
main = hakyll $ do
    match "index.markdown" $ do
        route $ setExtension "html"
        compile $ pandocPostCompiler 
            >>= loadAndApplyTemplate "template.html" defaultContext

    match "template.html" $ compile templateCompiler

pandocPostCompiler :: Compiler (Item String)
pandocPostCompiler = pandocCompilerWithTransform
    defaultHakyllReaderOptions
    defaultHakyllWriterOptions
    graphViz

graphViz :: Pandoc -> Pandoc
graphViz = walk codeBlock

codeBlock :: Block -> Block
codeBlock cb@(CodeBlock (id, classes, namevals) contents) = 
    case lookup "lang" namevals of
        Just f -> RawBlock (Format "html") $ svg contents
        nothing -> cb
codeBlock x = x

svg :: String -> String
svg contents = unsafePerformIO $ readProcess "dot" ["-Tsvg"] contents
