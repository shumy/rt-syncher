var gulp = require('gulp');
var exec = require('child_process').exec;

// Task and dependencies to convert ES6 to ES5 with babel;
var babel = require('babelify');
var browserify = require('browserify');
var source = require('vinyl-source-stream');

gulp.task('build', function() {
  var bundler = browserify('./src/js/rts-client.js', {
    standalone: 'rts-client',
    debug: false
  }).transform(babel);

  function rebundle() {
    bundler.bundle()
    .on('error', function(err) {
      console.error(err);
      this.emit('end');
    })
    .pipe(source('rts-client.js'))
    .pipe(gulp.dest('./target'));
  }

  rebundle();
});