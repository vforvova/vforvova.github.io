gulp = require 'gulp'

parameters = require '../config/parameters.coffee'

coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
gutil = require 'gulp-util'
slim = require 'gulp-slim'
sass = require 'gulp-sass'
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

gulp.task 'minify', ['vendor', 'bower', 'coffee'], ->
  gulp.src "#{parameters.web_path}/js/**.js"
  .pipe uglify outSourceMap: true
  .pipe gulp.dest "#{parameters.web_path}/js"
  .on 'error', gutil.log

gulp.task 'assets', ->
  gulp.src "#{parameters.assets_path}/**"
  .pipe gulp.dest parameters.web_path
  .on 'error', gutil.log

gulp.task 'manifest', ['vendor', 'slim', 'sass', 'coffee', 'minify'], ->
  gulp.src "#{parameters.web_path}/**"
  .pipe manifest(
    hash: true
    timestamp: false
    preferOnline: true
    fallback: [
      'api/picture/ images/placeholder.png'
    ]
    filename: parameters.manifest_file
    exclude: [
      parameters.manifest_file
      'robots.txt'
    ]
  )
  .pipe replace new RegExp('\/%20', 'g'), '/ '
  .pipe gulp.dest parameters.web_path

gulp.task 'assets', ['clean'], ->
  gulp.src "#{parameters.assets_path}/**"
  .pipe gulp.dest parameters.web_path
  .on 'error', gutil.log

gulp.task 'styles', ->
  gulp.src parameters.lstyles_main_file
  .pipe sass paths: [ path.join(__dirname) ]
  .pipe rev()
  .pipe gulp.dest "#{parameters.web_path}/css"
  .pipe rename 'rev-manifest-css.json'
  .pipe gulp.dest parameters.web_path
  .on 'error', gutil.log

gulp.task 'references', ['styles', 'slim'], ->
  revManifest = {}

  for fileName in fs.readdirSync parameters.web_path
    _.extend(
      revManifest,
      JSON.parse fs.readFileSync "#{parameters.web_path}/#{fileName}",
      'utf8' if /^(rev-manifest)/.test fileName
    )

  replacements = {}
  for oldFileName, revFileName of revManifest
    replacements[oldFileName.replace(parameters.app_path, '')] = revFileName.replace(parameters.app_path, '')

  gulpStream = gulp.src ["#{parameters.web_path}/index.html"]
  gulpStream.setMaxListeners 20
  for oldFileName, revFileName of replacements
    gulpStream.pipe replace new RegExp(oldFileName, 'g'), revFileName
  gulpStream.pipe gulp.dest parameters.web_path

gulp.task 'watch', ['build'], ->
  gulp.watch "#{parameters.app_path}/**/*.coffee", ['coffee' ]
  gulp.watch "#{parameters.app_path}/**/*.sass", ['styles', 'manifest', 'references']
  gulp.watch "#{parameters.app_path}/*.slim", ['slim', 'references']
  gulp.watch "#{parameters.app_path}/*/**/*.slim", ['templates']
  gulp.watch parameters.assets_path, ['assets']
  gulp.watch 'bower.json', ['vendors']

gulp.task 'serve', ['build'], serve parameters.web_path
