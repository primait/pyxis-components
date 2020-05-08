module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import NoExposingEverything
import NoImportingEverything
import NoMissingTypeAnnotation
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Variables
import Review.Rule exposing (Rule, ignoreErrorsForDirectories, ignoreErrorsForFiles)


config : List Rule
config =
    [ NoExposingEverything.rule
    , NoImportingEverything.rule
        [ "Html"
        , "Html.Attribute"
        , "Html.Events"
        ]
    , NoMissingTypeAnnotation.rule
    , NoUnused.CustomTypeConstructors.rule []
        |> ignoreErrorsForDirectories exampleDirectories
        |> ignoreErrorsForFiles exampleFiles
    , NoUnused.Dependencies.rule
    , NoUnused.Exports.rule
       |> ignoreErrorsForDirectories
           [ "src/Prima/Pyxis/" ]
       |> ignoreErrorsForFiles
           []
    , NoUnused.Modules.rule
       |> ignoreErrorsForDirectories exampleDirectories
       |> ignoreErrorsForFiles exampleFiles
    , NoUnused.Variables.rule
    ]


exampleDirectories : List String
exampleDirectories = 
    [ "Accordion"
    , "AtrTable"
    , "Button"
    , "Container"
    , "DownloadButton"
    , "Form"
    , "Link"
    , "ListChooser"
    , "Loader"
    , "Message"
    , "Modal"
    , "Table"
    , "Tooltip"]
    |> List.map (\file -> "src/Prima/Pyxis/"++  file ++"/Example")

exampleFiles : List String 
exampleFiles = 
    [ "Accordion"
    , "AtrTable"
    , "Button"
    , "Container"
    , "DownloadButton"
    , "Form"
    , "Link"
    , "ListChooser"
    , "Loader"
    , "Message"
    , "Modal"
    , "Table"
    , "Tooltip"]
    |> List.map (\file -> "src/Prima/Pyxis/"++  file ++"/Example.elm")