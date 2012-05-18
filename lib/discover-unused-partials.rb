module DiscoverUnusedPartials

  #TODO: Prepare to give directory by argument
  def self.find_in directory
    worker = PartialWorker.new

    existent = worker.existent_partials("app")
    used, dynamic = worker.used_partials("app")

    unless (existent & used) == existent
      unused = (existent - used)
      puts unused * "\n"
      if !dynamic.empty?
        puts "\nSome of the partials above might be loaded dynamically by the following lines of code:\n\n"
        dynamic.each do |d|
          puts "#{d[0]}: #{d[1]}"
        end
      end
    end
  end

  class PartialWorker
    @@filename = /[a-zA-Z\d_\/]+?/
    @@extension = /\.\w+/
    @@partial = /:partial\s*=>\s*|partial:\s*/
    @@render = /\brender\s*(?:\(\s*)?/

    def existent_partials root
      partials = []
      each_file(root) do |file|
        if file =~ /^.*\/_.*$/
          partials << file.strip
        end
      end

      partials.sort
    end

    def used_partials root
      partials = []
      dynamic = []
      each_file(root) do |file|
        File.open(file) do |f|
          f.each do |line|
            line.strip!
            if line =~ %r[(?:#@@partial|#@@render)(['"])/?(#@@filename)#@@extension*\1]
              match = $2
              if match.index("/")

                path = match.split('/')[0...-1].join('/')
                file_name = "_#{match.split('/')[-1]}"

                full_path = "app/views/#{path}/#{file_name}"
              else
                if file =~ /app\/controllers\/(.*)_controller.rb/
                  full_path = "app/views/#{$1}/_#{match}"
                else
                  full_path = "#{file.split('/')[0...-1].join('/')}/_#{match}"
                end
              end
              partials << check_extension_path(full_path)
            elsif line =~ /#@@partial|#@@render["']/
              dynamic << [file, line]
            end
          end
        end
      end
      [partials.uniq.sort, dynamic]
    end

    def check_extension_path(file)
      if File.exists? file + ".html.erb"
        file += ".html.erb"
      elsif File.exists? file + ".html.haml"
        file += ".html.haml"
      else
        file += ".rhtml"
      end
      file
    end

    def each_file(root, &block)
      files = Dir.glob("#{root}/*")
      files.each do |file|
        if File.directory? file
          next if file =~ %r[^app/assets]
          each_file(file) {|file| yield file}
        else
          yield file
        end
      end
    end
  end
end
