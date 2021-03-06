require 'yaml'

module SiteData
  class AuthorData
    attr_reader :path, :basepath

    def initialize(test_path = nil)
      @test_path = test_path
      @basepath = @test_path ? @test_path : Dir.pwd
      @path = File.join(@basepath, '_authors')
    end

    def update(author_file, key, value)
      author_path = create_file_path(author_file)
      if File.exist? author_path
        updated_file = update_file(author_path, key, value)
        if updated_file[:changed]
          write_update(author_path, updated_file[:file], key, value)
        end
      else
        puts "#{author_file} does not exist.".red
      end
    end

    def fetch(name, key)
      if self.exists? name
        YAML.load_file("#{@path}/#{name}.md")[key]
      end
    end

    def exists?(name)
      File.exist? "#{@path}/#{name}.md"
    end

    def create_file_path(file)
      path = File.join(@path, file)
      File.extname(path).empty? ? "#{path}.md" : path
    end

    private

    def update_file(author_path, key, value)
      frontmatter = File.read(author_path)[frontmatter_regex]
      frontmatter_yml = YAML.load(frontmatter)
      if frontmatter_yml[key] != value
        frontmatter_yml[key] = value
        frontmatter_new = YAML.dump(frontmatter_yml) << "---\n\n"
        { file: File.read(author_path).gsub(frontmatter, frontmatter_new),
          changed: true }
      else
        { file: frontmatter, changed: false }
      end
    end

    def write_update(author_path, updated_file, key, value)
      unless updated_file.empty?
        puts "updating #{author_path} to `#{key}: #{value}`".yellow
        File.write(author_path, updated_file)
      end
    end

    def frontmatter_regex
      /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m
    end
  end
end
