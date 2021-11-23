module Prima.PyxisV3.Form.Commons.KeyboardEvents exposing
    ( KeyCode(..)
    , toKeyCode
    , wentTooHigh
    , wentTooLow
    )


type KeyCode
    = UpKey
    | DownKey
    | EnterKey


toKeyCode : Int -> Maybe KeyCode
toKeyCode key =
    case key of
        38 ->
            Just UpKey

        40 ->
            Just DownKey

        13 ->
            Just EnterKey

        _ ->
            Nothing


wentTooLow : Int -> List a -> Bool
wentTooLow index list =
    index >= List.length list - 1


wentTooHigh : Int -> Bool
wentTooHigh index =
    index <= 0
