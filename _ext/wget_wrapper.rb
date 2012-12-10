##
#
# Awestruct::Extensions:WgetWrapper is a classic type of awestruct extension.
# If configured in project pipeline and site.yml, it will download content from listed URLs.
#
# Configuration:
#
# 1. configure the extension in the project pipeline.rb:
#    - add wget_wrapper dependency:
#
#      require 'wget_wrapper'
#
#    - put the extension initialization in the initialization itself:
#
#      extension Awestruct::Extensions::WgetWrapper.new
#
# 2. This is an example site.yml configuration:
#
#    wget:
#      enabled: true
#      urls:
#        - http://static.jboss.org/theme/css/bootstrap-community.js
#        - http://static.jboss.org/theme/js/bootstrap-community.js
#        - http://static.jboss.org/theme/fonts/titilliumtext/
#        - http://static.jboss.org/theme/images/common/
#
##

module Awestruct
  module Extensions
    class WgetWrapper

      def execute(site)

        # Checking whether a correct configuration is provided
        if site.wget.nil? or site.wget['urls'].nil?
          print "WgetWrapper extension is not properly configured in site.yml.\n"
          return
        end

        # Checking if it's enabled(default)
        if !site.wget['enabled'].nil? and !( site.wget['enabled'].to_s.eql?("true") )
          return
        end

        # Reading site.yml parameters
        urls = site.wget['urls']

        # Iterate over each defined file and add up all content in 'output' variable
        urlsStr = ''
        urls.each do |url|
          urlsStr += " "+url.to_s
        end

        command = "wget --no-remove-listing -nv -r --no-host-directories --no-parent -N"+urlsStr

        if system (command)
          print "Content downloaded.\n"
        else
          print "At least some of content from specified URLs was not reachable.\n"
        end

      end

    end
  end
end
