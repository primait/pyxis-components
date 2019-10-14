module Prima.Pyxis.Form.Types exposing (..)

{-| Represents the `Form` configuration.
-}

import Html exposing (Attribute, Html)
import Prima.Pyxis.DatePicker as DatePicker
import Prima.Pyxis.Form.Event exposing (Event)
import Prima.Pyxis.Form.Validation exposing (Validation, ValidationType)


type Form model msg
    = Form (FormConfig model msg)


type alias FormConfig model msg =
    { state : FormState
    , renderer : List (FormRenderer model msg)
    }


{-| A list in which each item represents a row of the form.
Each row has is own list of fields (`FormField model msg`) which
will be rendered by the mapper function (`FormField model msg -> List (Html msg)`).
-}
type alias FormRenderer model msg =
    ( FormField model msg -> List (Html msg), List (FormField model msg) )


type FormState
    = Pristine
    | Touched
    | Submitted


type FormFieldGroup model msg
    = FormFieldGroup (FormFieldGroupConfig model msg) (List (Validation model))


type alias FormFieldGroupConfig model msg =
    { label : Label
    , fields : List (FormField model msg)
    }


{-| Represents the configuration of a single form field.
-}
type FormField model msg
    = FormField (FormFieldConfig model msg)


type FormFieldConfig model msg
    = FormFieldAutocompleteConfig (AutocompleteConfig model msg) (List (Validation model))
    | FormFieldCheckboxConfig (CheckboxConfig model msg) (List (Validation model))
    | FormFieldDatepickerConfig (DatepickerConfig model msg) (List (Validation model))
    | FormFieldPasswordConfig (PasswordConfig model msg) (List (Validation model))
    | FormFieldRadioConfig (RadioConfig model msg) (List (Validation model))
    | FormFieldSelectConfig (SelectConfig model msg) (List (Validation model))
    | FormFieldTextareaConfig (TextareaConfig model msg) (List (Validation model))
    | FormFieldTextConfig (TextConfig model msg) (List (Validation model))
    | FormFieldPureHtmlConfig (PureHtmlConfig msg)


{-| Represents the type of group which can wrap a form field.
Used to add a boxed icon in a form field (for instance the calendar icon of the datepicker).
-}
type InputGroup msg
    = Prepend (List (Html msg))
    | Append (List (Html msg))


type alias TextConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    }


type alias PasswordConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    }


type alias TextareaConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    }


type alias RadioConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    , options : List RadioOption
    }


type alias RadioOption =
    { label : Label
    , slug : Slug
    }


type alias CheckboxConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> List ( Slug, Bool )
    , events : List (Event msg)
    , options : List CheckboxOption
    }


type alias CheckboxOption =
    { label : Label
    , slug : Slug
    , isChecked : Bool
    }


type alias SelectConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , isDisabled : Bool
    , isOpen : Bool
    , placeholder : Maybe String
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , events : List (Event msg)
    , options : List SelectOption
    }


type alias SelectOption =
    { label : Label
    , slug : Slug
    }


type alias DatepickerConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , attrs : List (Attribute msg)
    , reader : model -> Maybe Value
    , datePickerTagger : DatePicker.Msg -> msg
    , events : List (Event msg)
    , instance : DatePicker.Model
    , showDatePicker : Bool
    }


type alias AutocompleteConfig model msg =
    { slug : Slug
    , label : Maybe Label
    , isOpen : Bool
    , noResults : Maybe Label
    , attrs : List (Attribute msg)
    , filterReader : model -> Maybe Value
    , choiceReader : model -> Maybe Value
    , events : List (Event msg)
    , options : List AutocompleteOption
    }


type alias AutocompleteOption =
    { label : Label
    , slug : Slug
    }


type alias PureHtmlConfig msg =
    { content : List (Html msg)
    }


{-| Alias for String. Useful to have easy-to-read signatures.
-}
type alias Slug =
    String


{-| Alias for String. Useful to have easy-to-read signatures.
-}
type alias Label =
    String


{-| Alias for String. Useful to have easy-to-read signatures.
-}
type alias Value =
    String


type RenderFieldMode
    = Group (Maybe ValidationType)
    | Single
