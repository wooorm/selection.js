/*! selection.js - v0.0.1 - 2013-06-28
* https://github.com/wooorm/selection.js
* Copyright (c) 2013 wooorm; Licensed MIT */
(function(factory) {
  if (typeof define === 'function' && define.amd) {
    return define(factory);
  } else {
    return this.Selection = factory();
  }
}).call(this, function() {
  var Selection, SelectionPrototype, _EMPTY_STRING, _EVENTS, _global;
  _global = this;
  _EVENTS = ['mouseup', 'keyup'];
  _EMPTY_STRING = '';
  Selection = function(global) {
    var _this = this;
    global || (global = _global);
    if (typeof global.getSelection !== 'function') {
      return false;
    }
    this._selection = global.getSelection();
    this._global = global;
    this._listener = function() {
      return SelectionPrototype._listener.apply(_this, arguments);
    };
    this.events = _EVENTS;
    return this;
  };
  SelectionPrototype = Selection.prototype = {};
  SelectionPrototype._listener = function(_event) {
    var _this = this;
    setTimeout(function() {
      var data, event, type, value;
      value = _EMPTY_STRING + _this._selection;
      if (value === _this._previousValue) {
        return;
      }
      if (value === _EMPTY_STRING) {
        type = 'deselection';
        data = {};
      } else {
        type = 'selection';
        data = _this.get();
      }
      data.originalEvent = _event;
      event = _this._global.document.createEvent('CustomEvent');
      event.initCustomEvent(type, false, false, data);
      _this._global.dispatchEvent(event);
      return _this._previousValue = value;
    }, 0);
    return this;
  };
  SelectionPrototype.listen = function() {
    var document, event, events, iterator, length;
    this._previousValue = _EMPTY_STRING;
    iterator = -1;
    events = this.events;
    length = events.length;
    document = this._global.document;
    while (++iterator < length) {
      event = events[iterator];
      document.addEventListener(event, this._listener, false);
    }
    return this;
  };
  SelectionPrototype.ignore = function() {
    var document, event, events, iterator, length;
    iterator = -1;
    events = this.events;
    length = events.length;
    document = this._global.document;
    while (++iterator < length) {
      event = events[iterator];
      document.removeEventListener(event, this._listener, false);
    }
    return this;
  };
  SelectionPrototype.has = function() {
    var selection;
    selection = this._selection;
    return selection && (selection.focusNode != null) && (selection.anchorNode != null);
  };
  SelectionPrototype.set = function($top, topOffset, $bottom, bottomOffset) {
    var range, selection;
    selection = this._selection;
    if (selection == null) {
      return false;
    }
    if ($top == null) {
      return false;
    }
    if (topOffset == null) {
      topOffset = 0;
    }
    if ($bottom === $top || ($bottom == null)) {
      if (($top.firstChild != null) && ($top.lastChild != null)) {
        $bottom = $top.lastChild;
        $top = $top.firstChild;
      } else {
        $bottom = $top;
      }
    }
    if (bottomOffset == null) {
      if (this._isText($bottom)) {
        bottomOffset = $bottom.textContent.length;
      } else if ($bottom.childNodes != null) {
        bottomOffset = $bottom.childNodes.length;
      } else {
        bottomOffset = 0;
      }
    }
    if (selection.collapse && selection.extend) {
      selection.collapse($top, topOffset);
      selection.extend($bottom, bottomOffset);
    } else {
      range = this._global.document.createRange();
      range.setStart($top, topOffset);
      range.setEnd($bottom, bottomOffset);
      try {
        selection.removeAllRanges();
      } catch (_error) {

      }
      selection.addRange(range);
    }
    return this;
  };
  SelectionPrototype.get = function() {
    var positions;
    if (!this.has()) {
      return false;
    }
    positions = this._get();
    positions.value = _EMPTY_STRING + this._selection;
    return positions;
  };
  SelectionPrototype.clear = function() {
    try {
      this._selection.removeAllRanges();
    } catch (_error) {

    }
    return this;
  };
  SelectionPrototype.getStart = function() {
    var selection;
    selection = this._selection;
    if (!(selection || (selection.anchorNode == null))) {
      return false;
    }
    return {
      '$node': selection.anchorNode,
      'offset': selection.anchorOffset
    };
  };
  SelectionPrototype.getEnd = function() {
    var selection;
    selection = this._selection;
    if (!(selection || (selection.focusNode == null))) {
      return false;
    }
    return {
      '$node': selection.focusNode,
      'offset': selection.focusOffset
    };
  };
  SelectionPrototype.getTop = function() {
    var positions;
    positions = this._get();
    return {
      '$node': positions.$top,
      'offset': positions.topOffset
    };
  };
  SelectionPrototype.getBottom = function() {
    var positions;
    positions = this._get();
    return {
      '$node': positions.$bottom,
      'offset': positions.bottomOffset
    };
  };
  SelectionPrototype._isPreceding = function($firstNode, $secondNode) {
    return $secondNode.compareDocumentPosition($firstNode) & 2;
  };
  SelectionPrototype._contains = function($firstNode, $secondNode) {
    return $firstNode.compareDocumentPosition($secondNode) & 16;
  };
  SelectionPrototype._isText = function($node) {
    return $node && $node.nodeType === 3;
  };
  SelectionPrototype._precedes = function($top, top, $bottom, bottom) {
    if ($top === $bottom) {
      return top <= bottom;
    }
    if (this._isText($top) && this._isText($bottom)) {
      return this._isPreceding($top, $bottom);
    }
    if (this._isText($top) && !this._isText($bottom)) {
      return !this._precedes($bottom, bottom, $top, top);
    }
    if (!this._contains($top, $bottom)) {
      return this._isPreceding($top, $bottom);
    }
    if ($top.childNodes.length <= top) {
      return false;
    }
    if ($top.childNodes[top] === $bottom) {
      return 0 <= bottom;
    }
    return this._isPreceding($top.childNodes[top], $bottom);
  };
  SelectionPrototype._get = function() {
    var bottom, end, start, top;
    if (!this.has()) {
      return false;
    }
    start = this.getStart();
    end = this.getEnd();
    if (this._precedes(start.$node, start.offset, end.$node, end.offset)) {
      top = start;
      bottom = end;
    } else {
      top = end;
      bottom = start;
    }
    return {
      '$start': start.$node,
      'startOffset': start.offset,
      '$end': end.$node,
      'endOffset': end.offset,
      '$top': top.$node,
      'topOffset': top.offset,
      '$bottom': bottom.$node,
      'bottomOffset': bottom.offset
    };
  };
  return Selection;
});
