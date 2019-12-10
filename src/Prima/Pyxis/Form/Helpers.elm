module Prima.Pyxis.Form.Helpers exposing (..)

import Prima.Pyxis.Form.Validation as Validation
import Prima.Pyxis.Helpers as H


executeValidation : (Validation.Type -> Bool) -> model -> List (Validation.Validation model) -> List Bool
executeValidation mapper model validations =
    validations
        |> List.filter (mapper << Validation.pickType)
        |> List.map Validation.pickFunction
        |> List.map (H.flip identity model)
