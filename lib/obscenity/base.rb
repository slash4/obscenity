module Obscenity
  class Base
    class << self

      def blacklist
        @blacklist ||= set_list_content(Obscenity.config.blacklist)
      end

      def blacklist=(value)
        @blacklist = value == :default ? set_list_content(Obscenity::Config.new.blacklist) : value
      end

      def whitelist
        @whitelist ||= set_list_content(Obscenity.config.whitelist)
      end

      def whitelist=(value)
        @whitelist = value == :default ? set_list_content(Obscenity::Config.new.whitelist) : value
      end

      def profane?(text)
        return(false) unless text.to_s.size >= 3
        blacklist.each do |foul|
          return(true) if text =~ /\b#{foul}\b/i && !whitelist.include?(foul)
        end
        false
      end

      def sanitize(text, obj=nil)
        return(text) unless text.to_s.size >= 3
        obj.country_code = 'GB' if obj.country_code.nil?

        puts "SANITIZE" if Rails.env.development?
        puts blacklist if Rails.env.development?
        puts blacklist.nil? if Rails.env.development?
        puts blacklist.is_a?(Array) if Rails.env.development?

        if (blacklist.is_a?(Array) || blacklist.nil?)
          puts "DEBUG"
          puts (blacklist.is_a?(Array) || blacklist.nil?)
          puts blacklist.nil? if Rails.env.development?
          puts blacklist.is_a?(Array) if Rails.env.development?
          blacklist = {}
        end

        puts "SANITIZE" if Rails.env.development?
        puts blacklist if Rails.env.development?
        puts blacklist.nil? if Rails.env.development?
        puts blacklist.is_a?(Array) if Rails.env.development?

        blacklist[obj.country_code.to_sym] = [] if blacklist[obj.country_code.to_sym].nil?

        puts "SANITIZE" if Rails.env.development?
        puts blacklist if Rails.env.development?
        puts blacklist.nil? if Rails.env.development?
        puts blacklist.is_a?(Array) if Rails.env.development?

        blacklist[obj.country_code.to_sym].each do |foul|
          text.gsub!(/\b#{foul}\b/i, replace(foul))
        end


        @scoped_replacement = nil
        text
      end

      def replacement(chars)
        @scoped_replacement = chars
        self
      end

      def offensive(text)
        words = []
        return(words) unless text.to_s.size >= 3
        blacklist.each do |foul|
          words << foul if text =~ /\b#{foul}\b/i && !whitelist.include?(foul)
        end
        words.uniq
      end

      def replace(word)
        content = @scoped_replacement || Obscenity.config.replacement
        case content
        when :vowels then word.gsub(/[aeiou]/i, '*')
        when :stars  then '*' * word.size
        when :nonconsonants then word.gsub(/[^bcdfghjklmnpqrstvwxyz]/i, '*')
        when :default, :garbled then '$@!#%'
        else content
        end
      end

      private
      def set_list_content(list)
        case list
        when Array then list
        when Hash then list
        when String, Pathname then YAML.load_file( list.to_s )
        else []
        end
      end

    end
  end
end
