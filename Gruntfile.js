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
    mochacli: {
      options: {
        compilers: ['coffee:coffee-script/register'],
        files: ['test/*.coffee']
      },
      test: {
        options: {
          reporter: 'spec'
        }
      },
      coverage: {
        options: {
          reporter: 'html-cov',
          require: ['./test/register-handler.js'],
          save: '/tmp/wssjs-coverage.html'
        }
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
      },
      coverageresult: {
        command: function() {
          var command = null;
          var currentOS = os.type();
          if(currentOS=='Darwin')
            command = 'open'
          return command + ' /tmp/wssjs-coverage.html'
        }
      }
    },
    watch: {
      test: {
        files: ['test/*.coffee', 'src/*.coffee'],
        tasks: 'mochacli:test'
      }
    },
    clean: ['lib/', 'node_modules']
  });

  grunt.loadNpmTasks('grunt-karma');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-mocha-cli');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('unit-test', ['mochacli:test']);
  grunt.registerTask('compile', ['browserify', 'uglify']);
  grunt.registerTask('integration-test', ['shell:copyStack', 'karma']);
  grunt.registerTask('run-chrome', ['unit-test', 'compile', 'integration-test', 'shell:runchrome']);
  grunt.registerTask('develop', ['watch:test']);
  grunt.registerTask('coverage', ['mochacli:coverage', 'shell:coverageresult']);

  grunt.registerTask('default', ['compile']);
};
