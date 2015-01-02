gulp = require 'gulp'

parameters = require '../config/parameters.coffee'

coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gutil = require 'gulp-util'
slim = require 'gulp-slim'
sass = require 'gulp-ruby-sass'
bowerFiles = require 'main-bower-files'
uglify = require 'gulp-uglify'
manifest = require 'gulp-manifest'
rev = require 'gulp-rev'
serve = require 'gulp-serve'

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

gulp.task 'minify', ['vendor', 'coffee'], ->
  gulp.src "#{parameters.web_path}/js/**.js"
  .pipe uglify()
  .pipe gulp.dest "#{parameters.web_path}/js"
  .on 'error', gutil.log

gulp.task 'assets', ->
  gulp.src "#{parameters.assets_path}/**"
  .pipe gulp.dest parameters.web_path
  .on 'error', gutil.log

gulp.task 'build', ['sass', 'minify', 'slim', 'assets']

gulp.task 'watch', ['build'], ->
  gulp.watch "#{parameters.app_path}/**/*.coffee", ['coffee' ]
  gulp.watch "#{parameters.app_path}/**/*.sass", ['styles', 'manifest', 'references']
  gulp.watch "#{parameters.app_path}/*.slim", ['slim', 'references']
  gulp.watch "#{parameters.app_path}/*/**/*.slim", ['templates']
  gulp.watch parameters.assets_path, ['assets']
  gulp.watch 'bower.json', ['vendors']

gulp.task 'serve', ['build'], serve parameters.web_path
