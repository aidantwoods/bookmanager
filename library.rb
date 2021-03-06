require_relative 'book'
require 'yaml'

# Books are stored internally as Book objects, but are saved as pure
# hashes.
class Library
  attr_reader :books, :filenae
  def initialize(filename=nil)
    @filename = filename
    if File.exist?(@filename)
      @books = YAML.load_file(@filename).map do |book|
        Book.new(book)
      end
    else
      @books = []
    end
  end

  def add(opts)
    @books << Book.new(opts)
  end

  # Return a book matching all filters
  def get(opts)
    filtered = @books

    if opts[:uuid]
      filtered = filtered.find_all do |b|
        b.uuid.start_with?(opts[:uuid].downcase)
      end
    end

    if opts[:title]
      filtered = filtered.find_all do |b|
        b.title.downcase.include?(opts[:title].downcase)
      end
    end

    if opts[:author]
      filtered = filtered.find_all do |b|
        name = opts[:author].downcase
        b.author.downcase.include?(name) ||
          b.coauthors.any? { |c| c.downcase.include?(name) }
      end
    end

    filtered
  end

  def to_yaml
    @books.map { |book| book.to_h }.to_yaml
  end

  def save
    File.open(@filename, 'w') do |f|
      f.puts to_yaml
    end
  end
end
