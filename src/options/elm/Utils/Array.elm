module Utils.Array exposing (removeAtIndex)

import Array exposing (Array)


removeAtIndex : Int -> Array a -> Array a
removeAtIndex index src =
    let
        before =
            Array.slice 0 index src

        after =
            Array.slice (index + 1) (Array.length src) src
    in
        Array.append before after
