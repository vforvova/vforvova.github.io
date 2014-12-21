gulp = require 'gulp'

parameters = require './config/parameters.coffee'

coffee  = require 'gulp-coffee'
concat  = require 'gulp-concat'
gutil   = require 'gulp-util'
slim    = require 'gulp-slim'
sass    = require 'gulp-sass'
bowerFiles    = require 'gulp-bower-files'
uglify  = require 'gulp-uglify'

gulp.task 'coffee', ->
  gulp.src "#{parameters.app_path}/**/*.coffee"
  .pipe coffee bare: true
  .pipe concat parameters.app_main_file
  .pipe gulp.dest "#{parameters.web_path}/js"
  .on 'error', gutil.log

gulp.task 'slim', ->
  gulp.src "#{parameters.app_path}/**/*.slim"
  .pipe slim pretty: true
  .pipe gulp.dest parameters.web_path
  .on 'error', gutil.log


gulp.task 'sass', ->
  gulp.src parameters.styles_main_file
  .pipe sass()
  .pipe gulp.dest "#{parameters.web_path}/css"
  .on 'error', gutil.log

gulp.task 'vendor', ->
  gulp.src "#{parameters.vendor_path}/**/*.js"
  .pipe concat parameters.vendor_main_file
  .pipe gulp.dest "#{parameters.web_path}/js"
  .on 'error', gutil.log

gulp.task 'bower', ->
  bowerFiles()
  .pipe filter '**/*.js'
  .pipe concat parameters.bower_main_file
  .pipe gulp.dest "#{parameters.web_path}/js"
  .on 'error', gutil.log

gulp.task 'minify', ['vendor', 'bower', 'coffee'], ->
  gulp.src "#{parameters.web_path}/js/**.js"
  .pipe uglify outSourceMap: true
  .pipe gulp.dest "#{parameters.web_path}/js"
  .on 'error', gutil.log

gulp.task 'assets', ->
  gulp.src "#{parameters.assets_path}/**"
  .pipe gulp.dest parameters.web_path
  .on 'error', gutil.log
