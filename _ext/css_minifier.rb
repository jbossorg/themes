require 'cssminify'

##
#
# Awestruct::Extensions:CssMinifier is a transformer type of awestruct extension.
# If configured in project pipeline and site.yml, it will compress CSS files.
#
# Required installed gems:
# - cssminify
#
# Configuration:
#
# 1. configure the extension in the project pipeline.rb:
#    - add css_minifier dependency:
#
#      require 'css_minifier'
#
#    - put the extension initialization in the initialization itself:
#
#      transformer Awestruct::Extensions::CssMinifier.new
#
# 2. In your site.yml add:
#
#    css_minifier:
#      enabled: true
#      fileSuffix: min
#
#    This setting is optional. 'enabled' defaults to 'true' and 'fileSuffix' defaults to an empty string.
#    Which implies minification of file content in place. If 'fileSuffix' is given then a new file is created.
#
##
module Awestruct
  module Extensions
    class CssMinifier

      def transform(site, page, input)

        # Checking if 'css_minifier' setting is provided and whether it's enabled.
        # By default, if it's not provided, we imply it's enabled.
        if !site.css_minifier.nil? and !site.css_minifier['enabled'].nil? and site.css_minifier['enabled'].to_s.eql?("false")
          return input
        end

        fileSuffix = nil
        if !site.css_minifier.nil? and !site.css_minifier['fileSuffix'].nil? and site.css_minifier['fileSuffix'].to_s.length>0
          fileSuffix = site.css_minifier['fileSuffix'].to_s
        end

        output = ''

        # Test if it's a CSS file.
        ext = File.extname(page.output_path)
        if !ext.empty?

          ext_txt = ext[1..-1]

          # Filtering out non-css files and those which were already minimized with added suffix.
          if ext_txt == "css" and ( fileSuffix.nil? or !File.fnmatch("*"+fileSuffix+".css",page.output_path) )
            print "Minifying css #{page.output_path} \n"
            output = CSSminify.compress(input)
          else
            return input
          end

        end

        # Depending whether file suffix was given we create a new file or minimize in place.
        if fileSuffix.nil?

          return output

        else

          oldFileName = File.basename(page.output_path).to_s

          # Create new file name with suffix added
          newFileName = oldFileName.slice(0..oldFileName.length-4)+fileSuffix+".css"
          newOutputPath = File.join(File.dirname(page.output_path.to_s),newFileName)

          # Create a temporary file with the merged content.
          tmpOutputPath = File.join( "./_tmp/" , newFileName)
          tmpOutputFile = File.new(tmpOutputPath,"w")
          tmpOutputFile.write(output)
          tmpOutputFile.close

          # Add the temporary file to the list of pages for rendering phase.
          newPage = site.engine.load_page(tmpOutputPath)
          newPage.source_path = tmpOutputPath
          newPage.output_path = newOutputPath
          site.pages << newPage

          # We return the input because we leave the original file untouched
          input
        end
      end
    end
  end
end
