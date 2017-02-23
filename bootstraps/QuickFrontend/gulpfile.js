'use strict';

var gulp = require('gulp')
    , sourcemaps = require('gulp-sourcemaps')
    , sass = require('gulp-sass')
    , concat = require('gulp-concat');

var browserSync = require('browser-sync').create();


gulp.task('copy', function(){
  gulp.src('./node_modules/normalize.css/normalize.css')
    .pipe(gulp.dest('./sass/'));
});

gulp.task('sass', function () {
    return gulp.src('./sass/**/*.scss')
        .pipe(sourcemaps.init())
        .pipe(sass({
            outputStyle: 'nested',
            precision: 10
        }))
        .on('error', function(err){
          console.log(err.message);
          this.end();
        })
        .pipe(sourcemaps.write())
        .pipe(gulp.dest('./css'))
        .pipe(browserSync.stream());
});

gulp.task('build-js', function(){
    return gulp.src('js/src/*.js')
        .pipe(sourcemaps.init())
        .pipe(concat('main.js'))
        .pipe(sourcemaps.write())
        .pipe(gulp.dest('js'))
        .pipe(browserSync.stream());
});

gulp.task('serve', ['sass', 'build-js', 'copy'], function() {
    browserSync.init({
        port: 3001,
        server: {
          baseDir: './'
        },
        browser: "google chrome"
    });
    gulp.task('copy');
    gulp.watch('./sass/**/*.scss', ['sass']);
    gulp.watch('./js/**/*.js', ['build-js']);
    gulp.watch("*.html").on('change', browserSync.reload);
});

// Default (main) task 
gulp.task('default', ['serve']);

