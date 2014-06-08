{-# LANGUAGE OverloadedStrings #-}
import Data.Monoid (mappend)
import Hakyll

main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/default.sass" $do
        route   $ gsubRoute "css/" (const "css/") `composeRoutes` setExtension "css"
        compile $ getResourceString
            >>= withItemBody (unixFilter "sass" ["-s"])
            >>= return . fmap compressCss

    match (fromList ["instr.markdown", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "tutorials/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    defaultContext
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            tutorials <- loadAll "tutorials/*"
            let indexCtx =
                    listField "tutorials" defaultContext (return tutorials) `mappend`
                    constField "title" "Home"                               `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler