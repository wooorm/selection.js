# Selection
## by [@wooorm](https://github.com/wooorm)

**Table of Contents**

- [Instantiation](#instantiation)
- [Events](#events)
	- [**selection** (Event)](#selection-event)
	- [**deselection** (Event)](#deselection-event)
- [Methods](#methods)
	- [**get** (Method)](#get-method)
	- [**getTop**, **getBottom**, **getStart**, **getEnd** (Method)](#gettop-getbottom-getstart-getend-method)
	- [**clear** (Method)](#clear-method)
	- [**has** (Method)](#has-method)
	- [**set** (Method)](#set-method)

_Selection.js_ is a JavaScript module wrapping around the DOM text selection 
API. The module was created with the intention to be used on articles for the 
purpose of allowing readers to notify the writer about editorial errors (style,
grammar, &c.), and not intended to manipulate the selection (although) 
_selection.js_ could be used for those means.

The module is pretty small (~7kb uncompressed, ~3kb compressed, ~1kb gzipped) 
and supports most modern browsers (Internet Explorer 9 and higher).

The module relies on the following methods:

- `addEventListener` & `removeEventListener`: Chrome, Firefox, IE 9, Opera 7, 
Safari.
- `initCustomEvent`: Chrome, Firefox 6, IE 9, Opera unknown, Safari.
- `getSelection`: Most browsers, IE 9.
- `textContent`: Chrome, Firefox, IE 9, Opera, Safari.
- `compareDocumentPosition`: Chrome, Firefox, IE 9, Opera, Safari.

Overall the module should work in Chrome, Firefox, IE 9, Opera 7, and Safari. 
Note that several well-implemented DOM level 2 methods are used (things like 
`firstChild`, and `childNodes`).

## Instantiation

Authors can instantiate the module by calling `Selection` as a constructor with
an optional window object. If the result of calling `Selection` equals `false`,
`getSelection` was not available in the window object and the module can't 
work.

	selection = new Selection

Here `Selection` is instantiated with the global object of the first frame.

	selection = new Selection frames[ 0 ]

In the following example `Selection` is instantiated. If supported, we'll 
listen to `selection` and `deselection` events.

	selection = new Selection
	
	if selection
		do selection.listen
		# Some more code...

## Events
The main feature of _selection.js_ is it's ability to fire events for 
selections. _Selection.js_ fires the `selection` event when the user selects 
text (by double clicking on a word for example, or when using the the arrow 
keys to extend a selection), and fires `deselection` when the user deselects 
text (e.g. when a click outside a selection occurs). These events are 
dispatched on the global space provided to the `Selection` constructor.

You can start listening to events by calling `listen`, and stop listening by 
calling `ignore`.

In the following example, we listen to selection events. When the first 
selection happens, we call `console.log` with the `value` of the selection. 
Following that, we stop listening to selection events.

	do selection.listen
	
	window.addEventListener 'selection', ( event ) ->
		console.log event.detail.value
		do selection.ignore

### **selection** (Event)
The `detail` property on the event object passed to `selection` listeners 
contains returns a selection object (see "Get"), extended with:

- `originalEvent` (Type `Event`): The original event, for example a MouseEvent 
if the selection happened by clicking on a word.

### **deselection** (Event)
The `detail` property on the event object passed to `deselection` listeners 
contains the following properties:

- `originalEvent` (Type `Event`): The original event, for example a MouseEvent 
if the selection happened by clicking outside a current selection.

## Methods

### **get** (Method)
The `get` method on an instance of `Selection` returns an object containing the
following properties:

- `value` (Type `String`, default `undefined`):<br/>
A string representing what the user selected.
- `$start` (Type `Node`, default `undefined`):<br/>
A node representing where the selection began.
- `startOffset` (Type `Number`, default `undefined`):<br/>
The position of the character in `$start` where the selection began.
- `$end` (Type `Node`, default `undefined`):<br/>
A node representing where the selection ended.
- `endOffset` (Type `Number`, default `undefined`):<br/>
The position of the character in `$end` where the selection ended.
- `$top` (Type `Node`, default `undefined`):<br/>
Either `$start` or `$end`, depending on which came before.
- `topOffset` (Type `Number`, default `undefined`):<br/>
Either `startOffset` or `endOffset`, depending on which came before.
- `$bottom` (Type `Node`, default `undefined`):<br/>
Either `$start` or `$end`, depending on which came after.
- `bottomOffset` (Type `Number`, default `undefined`):<br/>
Either `startOffset` or `endOffset`, depending on which came after.

### **getTop**, **getBottom**, **getStart**, **getEnd** (Method)
The `getTop`, `getBottom`, `getStart`, and `getEnd` methods on an instance of 
`Selection` returns an object containing the following properties:

- `$node` (Type `Node`): A node corresponding to the requested value in `get`.
- `offset` (Type `Number`): A number corresponding to the requested value in 
`get`.

### **clear** (Method)
The `clear` method removes a selection, and returns the instance of 
`Selection`.

### **has** (Method)
The `has` method returns `true` when the global space provided to the `Selection`
constructor has a selection, and `false` otherwise.

### **set** (Method)
The `set` method allows the developer to programmatically set a selection, and 
returns the instance of `Selection`. Set takes the following arguments:

- `$top`: (Type `Node`) A DOM node representing the top of the selection.
- `topOffset` (Type `Number`, default `0`): The indice of the starting 
character.
- `$bottom` (Type `Node`, default: [*]): A DOM node representing the bottom element of the 
selection.
- `bottomOffset` (Type `Number`, default: [**]): The indice of the ending character.

[*]: If `$top` has a first- and last child, `$bottom` will default to 
`$top.lastChild` and `$top` will be set to `$top.firstChild`, otherwise, 
`$bottom` will default to `$top`.

[**]: If `$bottom` is not a text node then `bottomOffset` will default to 
`$bottom.childNodes.length`, otherwise `bottomOffset` will default to 
`$bottom.textContent.length`.
