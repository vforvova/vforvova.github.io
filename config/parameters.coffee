app_path = 'app'

config =
  app_path: app_path
  web_path: './'
  vendor_path: 'vendor'
  assets_path: "#{app_path}/assets"
  app_main_file: 'app.js'
  vendor_main_file: 'vendor.js'
  css_main_file: 'app.css'
  styles_main_file: "#{app_path}/app.sass"
  manifest_file: 'app.appcache'
  bower_folder: './bower_components'

module.exports = config
