module Prima.Pyxis.Form.Example exposing (main)

import Browser
import Date
import Prima.Pyxis.Form.Autocomplete as Autocomplete
import Prima.Pyxis.Form.Example.Model exposing (Model, Msg(..), initialModel)
import Prima.Pyxis.Form.Example.Update exposing (update)
import Prima.Pyxis.Form.Example.View exposing (view)
import Prima.Pyxis.Form.Select as Select
import Task


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions =
            always
                (Sub.batch
                    [ Sub.map SelectMsg Select.subscription
                    , Sub.map AutocompleteMsg Autocomplete.subscription
                    ]
                )
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, Task.perform OnTodayDateReceived Date.today )
