module DiscoverUnusedPartials

  #TODO: Prepare to give directory by argument
  def self.find_in directory
    worker = PartialWorker.new
    tree, dynamic = worker.used_partials("app")

    tree.each do |idx, level|
      indent = " " * idx*2
      h_indent = idx == 1 ? "" : "\n" + " "*(idx-1)*2

      if idx == 1
        puts "#{h_indent}The following partials are not referenced directly by any code:"
      else
        puts "#{h_indent}The following partials are only referenced directly by the partials above:"
      end
      level[:unused].sort.each do |partial|
        puts "#{indent}#{partial}"
      end
    end

    unless dynamic.empty?
      puts "\n\nSome of the partials above (at any level) might be referenced dynamically by the following lines of code:"
      dynamic.each do |file, lines|
        lines.each do |line|
          puts "  #{file}:#{line}"
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

      partials
    end

    def used_partials root
      files = []
      each_file(root) do |file|
        files << file
      end
      tree = {}
      level = 1
      existent = existent_partials(root)
      top_dynamic = nil
      loop do
        used, dynamic = process_partials(files)
        break if level > 1 && used.size == tree[level-1][:used].size
        tree[level] = {
          used: used,
        }
        if level == 1
          top_dynamic = dynamic
          tree[level][:unused] = existent - used
        else
          tree[level][:unused] = tree[level-1][:used] - used
        end
        break unless (files - tree[level][:unused]).size < files.size
        files -= tree[level][:unused]
        level += 1
      end
      [tree, top_dynamic]
    end

    def process_partials(files)
      partials = []
      dynamic = {}
      files.each do |file|
        #next unless FileTest.exists?(file)
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
              dynamic[file] ||= []
              dynamic[file] << line
            end
          end
        end
      end
      partials.uniq!
      [partials, dynamic]
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
