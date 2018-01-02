# -*- coding: UTF-8 -*-
module DiscoverUnusedPartials

  def self.find options={}
    worker = PartialWorker.new options
    tree, dynamic = Dir.chdir(options[:root]){ worker.used_partials("app") }

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
      dynamic.sort.map do |file, lines|
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

    def initialize options
      @options = options
    end

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
      raise "#{Dir.pwd} does not have '#{root}' directory" unless File.directory? root
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
      partials = @options['keep'] || []
      dynamic = {}
      files.each do |file|
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
              if @options["dynamic"] && @options["dynamic"][file]
                partials += @options["dynamic"][file]
              else
                dynamic[file] ||= []
                dynamic[file] << line
              end
            end
          end
        end
      end
      partials.uniq!
      [partials, dynamic]
    end

    EXT = %w(.html.erb .text.erb .pdf.erb .erb .html.haml .text.haml .haml .rhtml .html.slim slim)
    def check_extension_path(file)
      "#{file}#{EXT.find{ |e| File.exists? file + e }}"
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
