// Call `Selection` as a constructor, implicitly passing it the scope 
// `selection.js` is in.
selection = new Selection;

// Call `listen` of `selection` to enable events.
selection.listen();

// On `"selection"`...
addEventListener( 'selection', function( event )
	{
		// Let `$start` be `$start` of `detail`.
		$start = event.detail.$start;
		
		// Let `$end` be `$end` of `detail`.
		$end = event.detail.$end;
		
		// If `$start` is truthy...
		if ( $start )
		{
			// ...and if `$start` is a text node...
			if ( $start.nodeType === 3 )
				// Let `$start` be its parent element.
				$start = $start.parentElement;
			
			// add class `highlight` to `$start`.
			$start.classList.add( 'highlight' );
		}
		
		// If `$end` is truthy...
		if ( $end )
		{
			// ...and if `$end` is a text node...
			if ( $end.nodeType === 3 )
				// Let `$end` be its parent element.
				$end = $end.parentElement;
			
			// Add class `highlight` to `$end`.
			$end.classList.add( 'highlight' );
		}
	}
);

addEventListener( 'deselection', function( event )
	{
		// Let `$highlights` be all elements with class `highlight`, `iterator` 
		// be -1, and `length` be `length` of `$highlights`.
		var $highlights = document.querySelectorAll( '.highlight' )
		  , iterator = -1
		  , length = $highlights.length
		  ;
		
		// While adding one to `iterator` is less than `length`.
		while ( ++iterator < length )
			// Remove class `highlight` of the element.
			$highlights[ iterator ].classList.remove( 'highlight' );
	}
);
