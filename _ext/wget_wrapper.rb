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
#      createGitIgnoreFiles: true
#      urls:
#        - http://static.jboss.org/theme/css/bootstrap-community.js
#        - http://static.jboss.org/theme/js/bootstrap-community.js
#        - http://static.jboss.org/theme/fonts/titilliumtext/
#        - http://static.jboss.org/theme/images/common/
#
#   Note: 'enabled' and 'createGitIgnoreFiles' properties default to 'true' if not defined.
#
##

require 'uri'

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

        # Checking whether .gitignore files should be created (default)
        createGitIgnoreFiles = true;
        if !site.wget['createGitIgnoreFiles'].nil? and !( site.wget['createGitIgnoreFiles'].to_s.eql?("true") )
          createGitIgnoreFiles = false;
        end

        # Getting urls from site.yml
        urls = site.wget['urls']

        # Paths for .gitignore files
        directories = Array.new

        # Iterate over each defined url, add up all of them and collect root paths for .gitignore files.
        urlsStr = ''
        urls.each do |url|
          urlsStr += " "+url.to_s

          if (createGitIgnoreFiles)

            uri = URI(url)
            path = uri.path
            splitPath = path.to_s.split("/")
            if (splitPath.size>0 and !directories.include?(splitPath[1].to_s))
              directories.push(splitPath[1].to_s)
            end
          end

        end

        command = "wget --no-remove-listing -nv -r --no-host-directories --no-parent -N"+urlsStr

        if system (command)
          print "Content downloaded.\n"
        else
          print "At least some of content from specified URLs was not reachable.\n"
        end

        # Create .gitignore files if directories were downloaded successfully.
        if (createGitIgnoreFiles)

          directories.each do |directory|

            dirPath = File.join(".",directory)

            # Checking if the directory itself exists, if not it means that probably wget failed to download it.
            if (!File.exist?(dirPath) or !File.directory?dirPath)
              next
            end

            gitIgnoreFilePath = File.join(dirPath,".gitignore")

            # Checking if .gitignore file already exists
            if (File.exist?(gitIgnoreFilePath))
               next
            end

            gitIgnoreFile = File.new(gitIgnoreFilePath,"w")
            gitIgnoreFile.write("*\n")
            gitIgnoreFile.close

          end

        end

      end

    end
  end
end
