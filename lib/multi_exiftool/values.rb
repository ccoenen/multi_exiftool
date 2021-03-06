# coding: utf-8
require 'date'
require 'set'

module MultiExiftool

  # Representing (tag, value) pairs of metadata.
  # Access via bracket-methods or dynamic method-interpreting via
  # method_missing.
  class Values

    attr_reader :tags

    def initialize values
      @values = {}
      @tags = Set.new
      values.map do |tag,val|
        @tags << tag
        val = val.kind_of?(Hash) ? Values.new(val) : val
        @values[Values.unify_tag(tag)] = val
      end
    end

    def [](tag)
      parse_value(@values[Values.unify_tag(tag)])
    end

    def self.unify_tag tag
      tag.gsub(/[-_]/, '').downcase
    end

    private

    def method_missing tag, *args, &block
      res = self[Values.unify_tag(tag.to_s)]
      if res && block_given?
        if block.arity > 0
          yield res
        else
          res.instance_eval &block
        end
      end
      res
    end

    def parse_value val
      return val unless val.kind_of?(String)
      case val
      when /^(\d{4}):(\d\d):(\d\d) (\d\d):(\d\d)(?::(\d\d))?([-+]\d\d:\d\d)?$/
        arr = $~.captures[0,6].map {|cap| cap.to_i}
        arr << $7 if $7
        Time.new(*arr)
      when %r(^(\d+)/(\d+)$)
        Rational($1, $2)
      else
        val
      end
    end

  end

end
