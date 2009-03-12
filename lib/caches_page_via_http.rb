module ActionController
  module Caching
    module Pages
      module ClassMethods
        def expire_page(path)
          # NOOP
        end

        def cache_page(content, path)
          # NOOP
        end

        def caches_page(*actions)
          return unless perform_caching
          options = actions.respond_to?(:extract_options!) ? actions.extract_options! : {}
          after_filter({:only => actions}.merge(options)) do |c|
            c.response.headers['Cache-Control'] = 'public, max-age=300'
            c.response.headers.delete('cookie') # caching the page means no cookies
          end
        end
      end
    end
  end
end