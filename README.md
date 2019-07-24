# Pyxis UI components written in `elm`

Prima Design System public package for `elm`.
It helps to build scalable UIs by mantaining consistency between design and components across different apps.

Written in `elm@0.19`.

By using `elm`'s type system we can predict behaviors of our components and test them, building strong, scalable ecosystem for our design. 

## Common usage patterns

#### Do
- *Always* use this package by defining namespaced `alias`es.
- *Always* keep documentation up-to-date while developing new features or changing `api`s.
- *Always* create an `Example.elm` which shows up what the component you created does.
- *Always* update the `frontend` team and consider with them the need to `tag` a new `release` of `Pyxis`.

#### Don't
- *Never* use exposing-all  (`exposing (..)`) operator.
- *Never* name modules with plural. For instance  `Accordions` is *bad*. `Accordion` is *good*.
- *Never* repeat namespace in exposed methods. For instance `Accordion.initAccordion` is *bad*. `Accordion.init` is *good*.

Example:

    import Prima.Pyxis.Accordion.Accordion as Accordion exposing (Config, State, Accordion)
    ...
    
    view : Model -> List (Html Msg) 
	view model =
	   Accordion.render model.accordionState model.accordionConfig 
	   
	...


## Publishing package
Run the following commands after you had committed your work: 
	
- `./node_modules/.bin/elm bump`
- Follow terminal advices to write documentation and confirm the package update (if needed)
- `./node_modules/.bin/elm publish`

## Testing package
Run the `./node_modules/.bin/elm reactor` command. 
It will start a local server which points to  `http://localhost:8000` .
You can now navigate through the examples and test your work before publishing it.