module Prima.Pyxis.Form.Examples.View exposing (view)

import Browser
import Date exposing (Date)
import Html exposing (Html, div, fieldset, i, legend, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Examples.FormConfig as Config
import Prima.Pyxis.Form.Examples.Model exposing (Model, Msg(..))
import Prima.Pyxis.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    { title = "Form"
    , body = appBody model
    }


appBody : Model -> List (Html Msg)
appBody model =
    let
        toggleDatePicker =
            div
                [ class "m-form__field__group__append"
                ]
                [ i
                    [ class "a-icon a-icon-calendar cBrandAltDark"
                    , onClick ToggleDatePicker
                    ]
                    []
                ]
    in
    [ Helpers.pyxisStyle
    , div
        [ class "a-container" ]
        [ fieldset
            [ class "a-fieldset" ]
            [ legend
                [ class "a-fieldset__legend" ]
                [ text "Form example" ]
            , Form.wrapper <| (Form.render model Config.username ++ Form.render model Config.password)
            , Form.wrapper <| Form.render model Config.note
            , Form.wrapper <| Form.render model Config.gender
            , Form.wrapper <| Form.render model Config.genderVertical
            , Form.wrapper <| Form.render model Config.privacy
            , Form.wrapper <| Form.render model (Config.visitedCountries model)
            , Form.wrapper <| Form.render model (Config.city model.isOpenCity)
            , Form.wrapper <| Form.renderWithGroup [ toggleDatePicker ] model (Config.dateOfBirth model)
            , Form.wrapper <| Form.render model (Config.country model)
            , Form.wrapper <| Form.render model (Config.staticHtml model)
            ]
        ]
    ]
