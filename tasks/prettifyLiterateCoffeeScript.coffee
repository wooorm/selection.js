module.exports = ( grunt ) ->
	grunt.registerTask 'prettifyLiterateCoffeeScript', 'On before build', ->
		
		{ Markdown } = require 'node-markdown'
		{ minify } = require 'html-minifier'
		fs = require 'fs'
		coffee = require 'coffee-script'
		
		literateCoffeeToCoffee = ( string ) ->
			re = /\s+/
			
			lines = string.split '\n'
			result = []
			
			iterator = -1
			length = lines.length
			
			while ++iterator < length
				line = lines[ iterator ]
				
				if '#' is line.trim().charAt 0 then continue
				
				if '' is do line.trim then line = ''
				
				if not line and not previousLine then continue
				
				result.push line
				previousLine = line
				
			result = result.join '\n'
			result.replace /\t/g, '    '
		
		content = fs.readFileSync './_source/selection.litcoffee', 'utf8'
		readme = fs.readFileSync './README.md', 'utf8'
		script = coffee.helpers.invertLiterate content
		
		content = readme + '\n' + content
		
		pkg = grunt.config.data.pkg
		
		keywords = ( pkg.keywords || [] ).join ', '
		description = pkg.description || ''
		author = pkg.author.name || pkg.author || ''
		title = pkg.name || ''
		
		html = [ '<!doctype html>'
				, '<html>'
				, '\t<head>'
				, '\t\t<meta charset="utf-8">'
				, '\t\t<title>', title, '</title>'
				, '\t\t<meta name="description" content="' + description + '" />'
				, '\t\t<meta name="keywords" content="' + keywords + '" />'
				, '\t\t<meta name="author" content="' + author + '" />'
				, '\t\t<link rel="stylesheet" href="./client.css" type="text/css" charset="utf-8">'
				, '\t</head>'
				, '\t<body>'
				, '\t\t<section class="codelet">'
				, '\t\t\t<pre><code>'
				, literateCoffeeToCoffee( script ).replace( /&/g, '&amp;' ).replace( /</g, '&lt;' ).replace( />/g, '&gt;' )
				, '\t\t\t</code></pre>'
				, '\t\t\t<button>Show Code</button>'
				, '\t\t</section>'
				, '\t\t<article class="article">'
				, Markdown( content )
				, '\t\t</article>'
				, "\t\t<script src=./client.js></script>"
				, '\t</body>'
				, '</html>' ].join '\n'
		
		html_ = minify html,
			'removeComments' : true
			'removeCommentsFromCDATA' : true
			'removeCDATASectionsFromCDATA' : true
			'collapseWhitespace' : true
			'collapseBooleanAttributes' : true
			'removeAttributeQuotes' : true
			'useShortDoctype' : true
			'removeEmptyAttributes' : true
		
		fs.writeFileSync './_about/index.html', html
		