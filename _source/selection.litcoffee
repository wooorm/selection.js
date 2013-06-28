# Annotated Source

**Table of Contents**

- [Explicit Private variables](#explicit-private-variables)
- [Constructor](#constructor)
- [Prototype](#prototype)
	- [\_listener [implicitly private]](#_listener-implicitly-private)
	- [listen [public]](#listen-public)
	- [ignore [public]](#ignore-public)
	- [has [public]](#has-public)
	- [set [public]](#set-public)
	- [get [public]](#get-public)
	- [clear [public]](#clear-public)
	- [getStart [public]](#getstart-public)
	- [getEnd [public]](#getend-public)
	- [getTop [public]](#gettop-public)
	- [getBottom [public]](#getbottom-public)
	- [\_isPreceding [implicitly private]](#_ispreceding-implicitly-private)
	- [\_contains [implicitly private]](#_contains-implicitly-private)
	- [\_isText [implicitly private]](#_istext-implicitly-private)
	- [\_precedes [implicitly private]](#_precedes-implicitly-private)
	- [\_get [implicitly private]](#_get-implicitly-private)
- [Return value](#return-value)

Wrap the module in a method that either passes the constructor to `define` 
if AMD is available, or registers it on the current global space.

	(
		( factory ) ->


If `define` is of type `"function"`, and `amd` of `define` is truthy, call 
`define` with `factory`.

			if typeof define is 'function' and define.amd then define factory

Otherwise, let `@Selection` be the result of calling `factory`.

			else @Selection = do factory

	).call @, ->

## Explicit Private variables

Let `_global` reference the current context.
		
		_global = @


Let `_EVENTS` be a list of possible selection change events.
		
		_EVENTS = [ 'mouseup', 'keyup' ]


Let `_EMPTY_STRING` be an empty string.

		_EMPTY_STRING = ''

## Constructor

Let `Selection` be a constructor function, taking an optional context.

		Selection = ( global ) ->


If `global` is not passed, fall back to `_global`.

			global or global = _global


If the type of `getSelection` is not `"function"`, selection is not supported, 
so we return `false`.

			if typeof global.getSelection isnt 'function' then return false


Let `@_selection` be the result of calling `getSelection` on `global`.

			@_selection = do global.getSelection


Let `@global` reference `global`.

			@_global = global


Bind context `self` to `@_listener`.

			@_listener = => SelectionPrototype._listener.apply @, arguments


Let `@events` reference `EVENTS` (by default).

			@events = _EVENTS


Return `self`.

			@


## Prototype

		SelectionPrototype = Selection:: = {}


### _listener [implicitly private]
`_listener` is a method used as a event listener, dispatching `selection` 
events when the selection of user changes.

		SelectionPrototype._listener = ( _event ) ->


The body of `_listener` is wrapped in `setTimeout` with `timeout=0` (moving it 
to the end of the call-stack), because the actual selection changes only when 
bubbling is not prevented on the original event.

			setTimeout =>


Let `value` be the result of (implicitly) calling `toString` on the actual 
selection.
					
					value = _EMPTY_STRING + @_selection


If `value` equals `@_previousValue`, nothing has changed, so we return.

					if value is @_previousValue then return


If `value` equals an empty string, the user deselected a previous selection. 
Let `type` be `"deselection"` and `data` reference an empty object.

					if value is _EMPTY_STRING
						type = 'deselection'
						data = {}


Otherwise, Let `type` be `"selection"` and `data` reference the result of 
calling `@get`.

					else
						type = 'selection'
						data = do @get


Let `originalEvent` of `data` reference `event_` (the original event).

					data.originalEvent = _event


let `event` be the result of calling `createEvent` with `"CustomEvent"`, call 
`initCustomEvent` on `event` with type `type`, `canBubble="false"`, 
`cancelable=false`, and `data`.

					event = @_global.document.createEvent 'CustomEvent'
					event.initCustomEvent type, false, false, data


Call `dispatchEvent` on `@_global` with `event`.

					@_global.dispatchEvent event


Let `@_previousValue` be `value`.

					@_previousValue = value

				, 0


Return `self`.

			@


### listen [public]
A method attaching `_listener` to each `event` in `@events` on `document`.

		SelectionPrototype.listen = ->


Let `@_previousValue` be an empty string.

			@_previousValue = _EMPTY_STRING


Let `iterator` be `-1`, `events` reference `@events`, `length` be `length` 
of `events`, and `document` reference `document` of `@_global`.

			iterator = -1
			events = @events
			length = events.length
			document = @_global.document


While adding one to `iterator` is less than `length`...

			while ++iterator < length


Let `event` reference `iterator` of `events`.

				event = events[ iterator ]


Call `addEventListener` on `document` with `event`, `@_listener`, and `false`.

				document.addEventListener event, @_listener, false


Return `self`.

			@


### ignore [public]
A method detaching `_listener` to each `event` in `@events` on `document`.

		SelectionPrototype.ignore = ->


Let `iterator` be `-1`, `events` reference `@events`, `length` be `length` 
of `events`, and `document` be `document` of `@_global`.

			iterator = -1
			events = @events
			length = events.length
			document = @_global.document


While adding one to `iterator` is less than `length`...

			while ++iterator < length


Let `event` reference `iterator` of `events`.

				event = events[ iterator ]


Call `removeEventListener` on `document` with `event`, `@_listener`, and 
`false`.

				document.removeEventListener event, @_listener, false


Return `self`.

			@


### has [public]
A method detecting whether or not an actual selection is present.

		SelectionPrototype.has = ->


Let `selection` reference `@_selection`.

			selection = @_selection

Return whether `selection` is truthy, `focusNode` of `selection` is neither 
`null` nor `undefined`, and `anchorNode` of `selection` is neither `null` nor 
`undefined`.

			selection and selection.focusNode? and selection.anchorNode?


### set [public]
A method setting an actual selection, taking the following arguments:

- `$top`: A DOM node representing the top of the selection.
- `topOffset` (optional): The indice of the starting character.
- `$bottom` (optional): A DOM node representing the bottom element of the 
selection.
- `bottomOffset` (optional): The indice of the ending character.


		SelectionPrototype.set = ( $top, topOffset, $bottom, bottomOffset ) ->


Let `selection` reference `@_selection`.

			selection = @_selection


If `selection` is either `null` or `undefined`, return `false`.

			unless selection? then return false


If `$top` is either `null` or `undefined`, return `false`.

			unless $top? then return false


If `topOffset` is either `null` or `undefined`, let `topOffset` be `0`.

			unless topOffset? then topOffset = 0


If `$bottom` is `$top`, or if `$bottom` is either `null` or `undefined`...

			if $bottom is $top or not $bottom?


If `$top.firstChild` is neither `null` nor `undefined` and `$top.firstChild` is
neither `null` nor `undefined`, let `$bottom` reference the first child of 
`$top`, and `$top` the last.


				if $top.firstChild? and $top.lastChild?
					$bottom = $top.lastChild
					$top = $top.firstChild


Else, let `$bottom` reference `$top`.

				else
					$bottom = $top


If `bottomOffset` is either `null` or `undefined`...

			unless bottomOffset?


If `$bottom` is a textNode, let `bottomOffset` be `length` of `textContent` of 
`$bottom`.

				if @_isText $bottom
					bottomOffset = $bottom.textContent.length

Otherwise, if `childNodes` of `$bottom` is neither `null` nor `undefined`, let
`bottomOffset` be `length` of `$bottom.childNodes`.

				else if $bottom.childNodes?
					bottomOffset = $bottom.childNodes.length


Otherwise, let `bottomOffset` be `0`.

				else
					bottomOffset = 0


If `collapse` of `selection`, and `extend` of `selection` are both truthy...

			if selection.collapse and selection.extend


Call `collapse` on `selection` with `$top` and `topOffset` to move both 
`anchor` and `focus` points of the selectionRange to the specified point.

				selection.collapse $top, topOffset


Call `extend` on `selection` with `$bottom` and `bottomOffset` to move the 
focus point of the current selectionRange to the specified point.

				selection.extend $bottom, bottomOffset


Else (for browsers like IE9, &c)...

			else


Let `range` be the result of calling `createRange` of `document` of `@_global`.

				range = do @_global.document.createRange


Call `setStart` on `range` with `$top` and `topOffset`.

				range.setStart $top, topOffset


Call `setEnd` on `range` with `$bottom` and `bottomOffset`.

				range.setEnd $bottom, bottomOffset


Try (as IE9 sometimes might throw) to call `removeAllRanges` on `selection`.

				try ( do selection.removeAllRanges ) catch

Call `addRange` on `selection` with `range`.

				selection.addRange range


Return `self`.

			@


### get [public]
A method returning an object similar to an actual selection object.

		SelectionPrototype.get = ->


If the result of calling `@has` is falsey, return `false`.

			unless do @has then return false


Let `positions ` be the result of calling `@_get`.

			positions = do @_get


Let `value` of `positions` be the result of (implicitly) calling `toString` on 
the actual selection.
		
			positions.value = _EMPTY_STRING + @_selection


Return the `positions` object.

			positions


### clear [public]
Removes an actual selection.

		SelectionPrototype.clear = ->


Try (as IE9 sometimes might throw) to call `removeAllRanges` on `@_selection`.

			try ( do @_selection.removeAllRanges ) catch


Return `self`.

			@


### getStart [public]
Returns the anchor of the actual selection.

		SelectionPrototype.getStart = ->


Let `selection` reference `@_selection`.

			selection = @_selection


If `selection` is falsey, or `anchorNode` of `selection` is either `null` or 
`undefined`, return `false`.

			unless selection or not selection.anchorNode? then return false

Return an object with properties:

- `$node`: Referencing `anchorNode` of `selection`.
- `offset`: Referencing `anchorOffset` of `selection`.

			'$node' : selection.anchorNode
			'offset' : selection.anchorOffset


### getEnd [public]
Returns the end of the actual selection.

		SelectionPrototype.getEnd = ->


Let `selection` reference `@_selection`.

			selection = @_selection


If `selection` is falsey, or `focusNode` of `selection` is either `null` or 
`undefined`, return `false`.

			unless selection or not selection.focusNode? then return false


Return an object with properties:

- `$node`: Referencing `focusNode` of `selection`.
- `offset`: Referencing `focusOffset` of `selection`.

			'$node' : selection.focusNode
			'offset' : selection.focusOffset


### getTop [public]
Return either `focus` or `anchor` of the actual selection, depending on which 
position comes **first**.

		SelectionPrototype.getTop = ->


Let `positions` be the result of calling `@_get`.

			positions = do @_get


Return an object containing:

- `$node`: Referencing `$top` of `positions`.
- `offset`: Referencing `topOffset` of `positions`.

			'$node' : positions.$top
			'offset' : positions.topOffset


### getBottom [public]
Return either `focus` or `anchor` of the actual selection, depending on which 
position comes **last**.

		SelectionPrototype.getBottom = ->


Let `positions` be the result of calling `@_get`.

			positions = do @_get


Return an object containing:

- `$node`: Referencing `$bottom` of `positions`.
- `offset`: Referencing `bottomOffset` of `positions`.

			'$node' : positions.$bottom
			'offset' : positions.bottomOffset


### _isPreceding [implicitly private]
Returns whether `$firstNode` precedes `$secondNode`.

		SelectionPrototype._isPreceding = ( $firstNode, $secondNode ) ->
			$secondNode.compareDocumentPosition( $firstNode ) & 2


### _contains [implicitly private]
Returns whether `$secondNode` is positioned inside `$secondNode`.

		SelectionPrototype._contains = ( $firstNode, $secondNode ) ->
			$firstNode.compareDocumentPosition( $secondNode ) & 16


### _isText [implicitly private]
Returns whether `$node` is truthy, and `nodeType` of `$node` is `3`.

		SelectionPrototype._isText = ( $node ) ->
			$node and $node.nodeType is 3


### _precedes [implicitly private]
Returns `true` if start is before end (with a bias to start if they are 
both the same).

		SelectionPrototype._precedes = ( $top, top, $bottom, bottom ) ->

If `$top` equals `$bottom`, return whether `top` is smaller than or equal to 
`bottom`.

			if $top is $bottom then return top <= bottom


If the results of calling both `@_isText` with `$top`, and `@_isText` with 
`$bottom` are both truthy, return whether `$top` is preceding `$bottom`.

			if @_isText( $top ) and @_isText $bottom
				return @_isPreceding $top, $bottom


If the result of calling `@_isText` with `$top` is truthy, return the 
inverse of calling `@_precedes` with `$bottom`, `bottom`, `$top`, and 
`top`.

			if @_isText( $top ) and not @_isText $bottom
				return not @_precedes $bottom, bottom, $top, top


If calling `@_contains` with `$top` and `$bottom` return truthy, return the 
result of calling `@_isPreceding` with `$top` and `$bottom`.

			unless @_contains $top, $bottom
				return @_isPreceding $top, $bottom


If `length` of `childNodes` of `$top` is smaller than or equal to `top`, 
return `false`.

			if $top.childNodes.length <= top then return false


If `length` of `childNodes` of `$top` is smaller than or equal to `top`, 
return `false`.

			if $top.childNodes[ top ] is $bottom then return 0 <= bottom


Return the result of calling `@_isPreceding` with `top` of `childNodes` of 
`$top`, and `$bottom`.

			@_isPreceding $top.childNodes[ top ], $bottom


### _get [implicitly private]
Returns an object with:

- `$top`: Either `focus` or `anchor` of the actual selection, depending on 
which position comes **first**.
- `topOffset`: the offset belonging to `$top`.
- `$bottom`: Either `focus` or `anchor` of the actual selection, depending on 
which position comes **last**.
- `bottomOffset`: the offset belonging to `$bottom`.


		SelectionPrototype._get = ->


If the result of calling `@has` is falsey, return `false`.

			unless do @has then return false


Let `start` be the result of calling `@getStart`, and `end` be the result 
of calling `@getEnd`.

			start = do @getStart
			end = do @getEnd


If calling `@_precedes` with `$node` of `start`, `offset` of `start`, `$node` 
of `end`, and `offset` of `end` is truthy, let `top` be `start`, and `bottom` 
be `end`.

			if @_precedes start.$node, start.offset, end.$node, end.offset
				top = start
				bottom = end


Otherwise, let `top` be `end` and `bottom` be `start`.

			else
				top = end
				bottom = start


Return an flattened object of `start`, `end`, `top`, and `bottom`.

			'$start' :  start.$node
			'startOffset' : start.offset
			'$end' : end.$node
			'endOffset' : end.offset
			'$top' : top.$node
			'topOffset' : top.offset
			'$bottom' : bottom.$node
			'bottomOffset' : bottom.offset


## Return value
Return the constructor function `Selection`.

		return Selection