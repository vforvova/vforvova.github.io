gulp = require 'gulp'

parameters = require '../config/parameters.coffee'

coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gutil = require 'gulp-util'
slim = require 'gulp-slim'
sass = require 'gulp-ruby-sass'
uglify = require 'gulp-uglify'
manifest = require 'gulp-manifest'
rev = require 'gulp-rev'
serve = require 'gulp-serve'
postcss = require 'gulp-postcss'
autoprefixer = require 'autoprefixer-core'
bowerSrc = require 'gulp-bower-src'

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

gulp.task 'css', ->
  processors = [
    autoprefixer { browsers: ['last 1 version'] }
  ]
  gulp.src "#{parameters.web_path}/app.css"
    .pipe postcss processors
    .pipe gulp.dest parameters.web_path

gulp.task 'vendor', ->
  gulp.src "#{parameters.vendor_path}/**/*.js"
  .pipe concat parameters.vendor_main_file
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

gulp.task 'bower', ->
  bowerSrc().pipe gulp.dest parameters.web_path

gulp.task 'build', ['sass', 'css', 'minify', 'slim', 'assets']

gulp.task 'watch', ['build'], ->
  gulp.watch "#{parameters.app_path}/**/*.coffee", ['coffee']
  gulp.watch "#{parameters.app_path}/**/*.sass", ['sass']
  gulp.watch "#{parameters.app_path}/*.slim", ['slim']
  gulp.watch parameters.assets_path, ['assets']

gulp.task 'serve', ['watch'], serve parameters.web_path
