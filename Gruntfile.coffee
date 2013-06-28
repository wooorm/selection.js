module.exports = ( grunt ) ->

	pkg = grunt.file.readJSON 'package.json'
	
	grunt.config.init
		'pkg' : pkg
		'meta' :
			'src' : './_source/selection.litcoffee'
			'dest' : './_destination/selection.js'
			'destMin' : './_destination/selection.min.js'
		'banner' : [ '/*! <%= pkg.name %> - v<%= pkg.version %> - ',
			'<%= grunt.template.today("yyyy-mm-dd") %>\n',
			'<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>',
			'* Copyright (c) <%= grunt.template.today("yyyy") %> ',
			'<%= pkg.author.name %>; Licensed ',
			'<%= _.pluck(pkg.licenses, "type").join(", ") %> */\n' ].join( '' )
		'coffee' :
			'brew' :
				'src' : '<%= meta.src %>'
				'dest' : '<%= meta.dest %>'
				'options' :
					'separator' : ';\n'
					'bare' : true
		'uglify' :
			'repulsify':
				'src' : '<%= meta.dest %>'
				'dest' : '<%= meta.destMin %>'
				'options' :
					'banner' : '<%= banner %>'
		# Note: Concat overwrites the coffee-compiled file.
		'concat' :
			'merge':
				'src' : '<%= meta.dest %>'
				'dest' : '<%= meta.dest %>'
				'options' :
					'banner' : '<%= banner %>'
		'watch' :
			'observe' :
				'files' : '<%= meta.src %>'
				'tasks' : [ 'default' ]
				'options' :
					'interrupt' : true

	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadTasks './tasks/'

	grunt.registerTask 'parse', [ 'coffee:brew' ]

	grunt.registerTask 'distribute', [ 'concat:merge', 'uglify:repulsify', 'prettifyLiterateCoffeeScript' ]

	grunt.registerTask 'default', [ 'parse', 'distribute' ]

