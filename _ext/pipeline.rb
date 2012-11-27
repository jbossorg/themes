require 'js_minifier'
require 'css_minifier'
require 'html_minifier'
require 'file_merger'

Awestruct::Extensions::Pipeline.new do
  helper Awestruct::Extensions::Partial
  transformer Awestruct::Extensions::JsMinifier.new
  transformer Awestruct::Extensions::CssMinifier.new
  transformer Awestruct::Extensions::HtmlMinifier.new
  extension Awestruct::Extensions::FileMerger.new
end

