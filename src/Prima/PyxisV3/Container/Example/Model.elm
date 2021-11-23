module Prima.PyxisV3.Container.Example.Model exposing
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
    , somethingElse : String
    }


initialModel : Model
initialModel =
    { eventMessage = "", somethingElse = "" }


updateMessage : String -> Model -> Model
updateMessage message model =
    { model | eventMessage = message }
