module Prima.Pyxis.DownloadButton.Icons exposing (renderIconDownload)

import Html exposing (Html, text)
import Html.Attributes as Attrs
import Svg


renderIconDownload : Html msg
renderIconDownload =
    Svg.node "svg"
        [ Attrs.attribute "role" "icon"
        , Attrs.attribute "xmlns" "http://www.w3.org/2000/svg"
        , Attrs.attribute "viewBox" "0 0 1024 1024"
        , Attrs.attribute "class" "btn--download__icon--svg"
        ]
        [ Svg.node "title" [] [ text "download" ]
        , Svg.node "path" [ Attrs.attribute "d" "M873.6 697.6c-12.8-6.4-25.6-3.2-32 9.6 0 0-73.6 118.4-211.2 118.4H396.8c-137.6 0-208-115.2-211.2-118.4-6.4-12.8-22.4-16-32-9.6-12.8 6.4-16 22.4-9.6 32 3.2 6.4 86.4 144 252.8 144h233.6c166.4 0 249.6-137.6 252.8-144 6.4-9.6 3.2-25.6-9.6-32zM496 694.4c6.4 3.2 9.6 6.4 16 6.4s12.8-3.2 16-6.4l195.2-176c9.6-9.6 9.6-25.6 3.2-35.2-9.6-9.6-25.6-9.6-35.2-3.2L537.6 617.6v-448c0-12.8-9.6-25.6-25.6-25.6-12.8 0-25.6 9.6-25.6 25.6v448L332.8 480c-9.6-9.6-25.6-9.6-35.2 3.2-9.6 9.6-9.6 25.6 3.2 35.2z" ] []
        ]
