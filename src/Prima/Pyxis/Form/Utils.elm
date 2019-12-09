module Prima.Pyxis.Form.Utils exposing (renderGroupAppend, renderGroupPrepend)

import Html exposing (Html)
import Html.Attributes as Attrs


renderGroupAppend : List (Html msg) -> Html msg
renderGroupAppend =
    Html.div
        [ Attrs.class "m-form-input-group__append"
        ]


renderGroupPrepend : List (Html msg) -> Html msg
renderGroupPrepend =
    Html.div
        [ Attrs.class "m-form-input-group__prepend"
        ]
