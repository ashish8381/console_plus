Pod::Spec.new do |s|
  s.name             = 'console_plus'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for in-app debug console with floating button, log filtering, export, auto-scroll etc.'
  s.description      = <<-DESC
  console_plus is a Flutter plugin that shows logs inside the app during debug mode, with floating button access, export to file, log filtering, and more.
  DESC
  s.homepage         = 'https://github.com/ashish8381/console_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ashish' => 'ya0285981@gmail.com' }
  s.source           = { :path => '.' }

  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'

  s.dependency       'Flutter'
  s.platform         = :ios, '11.0'

  # Match Flutter plugin settings
  s.swift_version    = '5.0'
end
