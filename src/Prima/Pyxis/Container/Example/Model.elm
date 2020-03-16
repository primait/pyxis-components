module Prima.Pyxis.Container.Example.Model exposing
    ( Model
    , Msg(..)
    , initialModel
    , updateMessage
    )


type Msg
    = OnClick
    | OnDoubleClick
    | OnMouseEnter
    | OnMouseLeave
    | OnMouseOver
    | OnMouseOut
    | OnBlur
    | OnFocus


type alias Model =
    { eventMessage : String
    }


initialModel : Model
initialModel =
    { eventMessage = "" }


updateMessage : String -> Model -> Model
updateMessage message model =
    { model | eventMessage = message }
