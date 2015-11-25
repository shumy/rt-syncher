module.exports = function(config) {
  config.set({
    basePath: '',
    frameworks: ['mocha', 'browserify'],

    files: [
      'src/js/**/*.js',
      'src/test/**/*.spec.js'
    ],

    exclude: [
    ],

    preprocessors: {
      'src/js/**/*.js': ['browserify'],
      'src/test/**/*.spec.js': ['browserify']
    },

    browserify: {
      debug: true,
      transform: ['babelify']
    },

    reporters: ['mocha'],

    port: 9876,
    colors: true,

    //level of logging: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,

    autoWatch: true,

    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome'],

    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false
  });

};