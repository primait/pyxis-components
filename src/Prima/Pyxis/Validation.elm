module Validation exposing (Validation(..))

import Regex


type Validation model
    = NotEmpty String
    | Expression Regex.Regex String
    | Custom (model -> Bool) String
