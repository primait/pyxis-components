module Prima.Pyxis.Shared.Interceptor exposing
    ( Interceptor(..)
    , targetContainsClass
    , targetWithId
    )

{-| Internal use only
-}


type Interceptor
    = ContainsClass String
    | WithId String


{-| Intercepts a target that contains given class
-}
targetContainsClass : String -> Interceptor
targetContainsClass className =
    ContainsClass className


{-| Intercepts a target that has given id
-}
targetWithId : String -> Interceptor
targetWithId id =
    WithId id
