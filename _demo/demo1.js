// Call `Selection` as a constructor, implicitly passing it the scope 
// `selection.js` is in.
selection = new Selection;

// Call `listen` of `selection` to enable events.
selection.listen();

// `filter` makes sure cyclic structures are loggable.
function filter( key, value )
{
	// If `value` is an instance of Node or Event, return the string value 
	// representing `value`.
	if ( value instanceof Node || value instanceof Event )
		return value.toString();
	
	// Otherwise, return `value`.
	return value;
};

// `punish` removes the users' selection.
function onPunish()
{
	console.log( 'Punnished!' );
	selection.clear();
}

function onSelection( event )
	{
		// Let `detail` be `detail` of `event`.
		detail = event.detail;
		
		// If the selected value equals `document.documentElement.innerText`, 
		// we punish the user by clearing his/her selections, or we just stop 
		// listening.
		// This works only in new Safari's and Chrome's, and is just an example:
		// Don't ever deny the user his/her right to select all the things.
		if ( detail.value === document.body.innerText )
		{
			// Based on randomness, we either...
			if ( Math.random() > 0.5 )
			{
				// ...punish the user (by removing this listener, and adding 
				// another)...
				console.log( 'Ha. You can\'t select anything anymore.' );
				removeEventListener( 'selection', onSelection );
				addEventListener( 'selection', onPunish );
			}
			// ...or we...
			else
			{
				// ...ignore him by not logging the results.
				console.log( 'Ha. I\'m not listening anymore...' );
				selection.ignore();
			}
			
			// And we return.
			return;
		}
		
		// Call `log` of `console` with `detailValue` and `detail`.
		console.log( 'selection = ' + JSON.stringify( detail, filter, '\t' ) );
		console.log( 'Expanden value: ', detail );
	}


// Call `addEventListener` with `"selection"` and `onSelection`.
addEventListener( 'selection', onSelection );

