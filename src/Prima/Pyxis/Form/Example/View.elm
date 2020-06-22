module Prima.Pyxis.Form.Example.View exposing (view)

import Browser
import Html exposing (Html)
import Html.Attributes as Attrs
import Prima.Pyxis.Container as Container
import Prima.Pyxis.Form as Form
import Prima.Pyxis.Form.Example.FieldConfig as Config
import Prima.Pyxis.Form.Example.Model exposing (FormData, Model, Msg(..))
import Prima.Pyxis.Helpers as Helpers


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Form component" (appBody model)


appBody : Model -> List (Html Msg)
appBody model =
    [ Helpers.pyxisStyle
    , Helpers.pyxisIconSetStyle
    , Container.row
        |> Container.withContent
            [ model
                |> formConfig
                |> Form.render model.formData
            ]
        |> Container.render
    ]


formConfig : Model -> Form.Form FormData Msg
formConfig model =
    let
        userIcon =
            Html.i [ Attrs.class "icon-plus" ] []
    in
    model.form
        |> Form.withFieldsAndLegend
            (Form.legendWithPrependableHtml
                "Login"
                [ userIcon ]
            )
            [ [ Config.usernameGroupConfig
              , Config.passwordGroupConfig
              ]
            , [ Config.usernameWithTooltipConfig model.formData.uiState.usernameTooltipVisible
              ]
            ]
        |> Form.withFieldsAndLegend
            (Form.legendWithAppendableHtml
                "User profile"
                [ userIcon ]
            )
            [ [ Config.birthDateCompoundConfig
              ]
            , [ Config.birthDateConfig
              ]
            ]
        |> Form.withFields
            [ Config.fiscalCodeGroupConfig
            ]
        |> Form.withFieldsAndLegend
            (Form.legendWithAppendableHtml
                "Privacy"
                [ userIcon ]
            )
            [ [ Config.privacyConfig
              ]
            , [ Config.userPrivacyMarketingConfig
              ]
            ]
        |> Form.withFields
            [ Config.userPrivacyThirdPartConfig
            ]
        |> Form.withFields
            [ Config.guideTypeConfig
            ]
        |> Form.withFields
            [ Config.powerSourceConfig model.formData.powerSourceSelect
            ]
        |> Form.withFields
            [ Config.countryAutocompleteConfig model.formData.countryAutocomplete
            ]
        |> Form.withFields
            [ Config.countrySelectConfig model.formData.countrySelectWithFilter
            ]
        |> Form.withFields
            [ Config.checkboxConfig
            ]
        |> Form.withFields
            [ Config.radioButtonConfig
            ]
        |> Form.withFields
            [ Config.textAreaConfig
            ]
