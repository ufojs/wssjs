var os = require('os')
module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    uglify: {
      build: {
        src: 'lib/wss.bundle.js',
        dest: 'lib/wss.bundle.min.js'
      }
    },
    browserify: {
      dist: {
        files: {
          'lib/wss.bundle.js': ['src/wss.coffee'],
        },
        options: {
          transform: ['coffeeify'],
          browserifyOptions: {
            extensions: ['.coffee']
          },
          bundleOptions: {
            standalone: 'ufo'
          }
        }
      }
    },
    mochaTest: {
      test: {
        options: {
          require: 'coffee-script/register'
        },
        src: ['test/*.coffee']
      }
    },
    karma: {
      unit: {
        configFile: 'integration-test/karma.conf.js'
      }
    },
    shell: {
      copyStack: {
        command: function() {
          return 'cp lib/wss.bundle.js integration-test/chrome-app/';
        }
      },
      runchrome: {
        command: function() {
          var chrome = null;
          var currentOS = os.type();
          if(currentOS=='Darwin')
            chrome = '/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome';
          return chrome + ' --load-and-launch-app=integration-test/chrome-app --user-data-dir=/tmp/testufo';
        }
      }
    },
    watch: {
      test: {
        files: ['test/*.coffee', 'src/*.coffee'],
        tasks: 'mochaTest'
      }
    },
    clean: ['lib/', 'node_modules']
  });

  grunt.loadNpmTasks('grunt-karma');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('unit-test', ['mochaTest']);
  grunt.registerTask('compile', ['browserify', 'uglify']);
  grunt.registerTask('integration-test', ['shell:copyStack', 'karma']);
  grunt.registerTask('run-chrome', ['unit-test', 'compile', 'integration-test', 'shell:runchrome']);
  grunt.registerTask('develop', ['watch:test']);

  grunt.registerTask('default', ['compile']);
};
