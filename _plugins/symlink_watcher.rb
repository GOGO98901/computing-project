# Copyright 2014 Google. All rights reserved.
# Available under an MIT license that can be found in the LICENSE file.

# The symlink_watcher plugin extends jekyll-watch to also listen for changes in
# any symlinked sub-directories.

require "find"
require "jekyll-watch"

module Jekyll
  module Watcher
    def build_listener_with_symlinks(site, options)
      src = options["source"]
      dirs = [src]
      Find.find(src).each do |f|
          if !f.include? "src"
            if !f.include? "packages"
              dirs << f if File.directory?(f) and File.symlink?(f)
            end
          end
      end

      require "listen"
      Listen.to(
        *dirs,
        :ignore => listen_ignore_paths(options),
        :force_polling => options['force_polling'],
        &(listen_handler(site))
      )
    end

    alias_method :build_listener_without_symlinks, :build_listener
    alias_method :build_listener, :build_listener_with_symlinks
  end
end
