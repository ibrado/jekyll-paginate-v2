module Jekyll
  module PaginateV2::Generator

    # 
    # Performs indexing of the posts or collection documents
    # as well as filtering said collections when requested by the defined filters.
    class PaginationIndexer
      #
      # Create a hash index for all post based on a key in the post.data table
      #
      def self.index_posts_by(all_posts, index_key)
        return nil if all_posts.nil?
        return all_posts if index_key.nil?
        index = {}
        for post in all_posts
          next if post.data.nil?
          next if !post.data.has_key?(index_key)
          next if post.data[index_key].nil?
          next if post.data[index_key].size <= 0
          next if post.data[index_key].to_s.strip.length == 0
          
          # Only tags and categories come as premade arrays, locale does not, so convert any data
          # elements that are strings into arrays
          post_data = post.data[index_key]
          if post_data.is_a?(String)
            post_data = post_data.split(/;|,|\s/)
          end
          
          for key in post_data
            key = key.to_s.downcase.strip
            # If the key is a delimetered list of values 
            # (meaning the user didn't use an array but a string with commas)
            for k_split in key.split(/;|,/)
              k_split = k_split.to_s.downcase.strip #Clean whitespace and junk
              if !index.has_key?(k_split)
                index[k_split.to_s] = []
              end
              index[k_split.to_s] << post
            end
          end
        end
        return index
      end # function index_posts_by
      
      #
      # Creates an intersection (only returns common elements)
      # between multiple arrays
      #
      def self.intersect_arrays(first, *rest)
        return nil if first.nil?
        return nil if rest.nil?
        
        intersect = first
        rest.each do |item|
          return [] if item.nil?
          intersect = intersect & item
        end
        return intersect
      end #function intersect_arrays
      
      #
      # Filters posts based on a keyed source_posts hash of indexed posts and performs a intersection of 
      # the two sets. Returns only posts that are common between all collections 
      #
      def self.read_config_value_and_filter_posts(config, config_key, posts, source_posts)
        return nil if posts.nil?
        return nil if source_posts.nil? # If the source is empty then simply don't do anything
        return posts if config.nil?
        return posts if !config.has_key?(config_key)
        return posts if config[config_key].nil?
        
        # Get the filter values from the config (this is the cat/tag/locale values that should be filtered on)
        
        # Get e.g. category and categories into a single array
        config_value = Utils.config_values(config, config_key)
          
        # Remove posts that don't have at least one required key
        posts.delete_if { |post|
          post_config = Utils.config_values(post.data, config_key)

          (config_value & post_config).empty?
        }
        
        # The fully filtered final post list
        return posts
      end #function read_config_value_and_filter_posts

    end #class PaginationIndexer

  end #module PaginateV2
end #module Jekyll
