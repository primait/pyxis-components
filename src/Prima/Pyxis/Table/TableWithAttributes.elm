module Prima.Pyxis.Table.TableWithAttributes exposing (..)

import Html exposing (Attribute, Html)


type alias AttributeConfiguration msg =
    { position : AttributeConfigurationPosition
    , attributes : List (Attribute msg)
    }


type AttributeConfigurationPosition
    = AttributePositionBody
    | AttributePositionHeader
    | AttributePositionTable


headerAttributes : List (Attribute msg) -> AttributeConfiguration msg
headerAttributes =
    AttributeConfiguration AttributePositionHeader


bodyAttributes : List (Attribute msg) -> AttributeConfiguration msg
bodyAttributes =
    AttributeConfiguration AttributePositionBody


tableAttributes : List (Attribute msg) -> AttributeConfiguration msg
tableAttributes =
    AttributeConfiguration AttributePositionTable
