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
    --    |> ignoreErrorsForDirectories []
    --    |> ignoreErrorsForFiles
    --        []
    --, NoUnused.Dependencies.rule
    --, NoUnused.Exports.rule
    --    |> ignoreErrorsForDirectories
    --        [ "src/Prima/Pyxis/" ]
    --    |> ignoreErrorsForFiles
    --        []
    --, NoUnused.Modules.rule
    --    |> ignoreErrorsForDirectories
    --        [ "Example"
    --        ]
    --    |> ignoreErrorsForFiles
    --        [ "src/Prima.Pyxis.Accordion.Example.elm"
    --        , "src/Prima.Pyxis.AtrTable.Example.elm"
    --        , "src/Prima.Pyxis.Button.Example.elm"
    --        , "src/Prima.Pyxis.Container.Example.elm"
    --        , "src/Prima.Pyxis.DownloadButton.Example.elm"
    --        , "src/Prima.Pyxis.Form.Example.elm"
    --        , "src/Prima.Pyxis.Link.Example.elm"
    --        , "src/Prima.Pyxis.ListChooser.Example.elm"
    --        , "src/Prima.Pyxis.Loader.Example.elm"
    --        , "src/Prima.Pyxis.Message.Example.elm"
    --        , "src/Prima.Pyxis.Modal.Example.elm"
    --        , "src/Prima.Pyxis.Table.Example.elm"
    --        , "src/Prima.Pyxis.Tooltip.Example.elm"
    --        ]
    --, NoUnused.Variables.rule
    ]
