# RNCP - a fast file copy tool for LANs port in Ruby
#
# Copyright (c) 2013 Jeff Parent
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
require 'zlib'
require 'archive/tar/minitar'
require 'stringio'

module RNCP
  # Module containing functions related to the file system and archive
  # compression/decompression.
  module Files
    # Recursively creates a list of all items (files/directories) found
    # in the path.
    # @param path [String] path to starting directory or file
    # @return [Array] flatten array of all contents of directory, or file
    def directory_list(path)
      return [path].flatten if File.directory?(path) == false

      data = []
      Dir["#{path}**/*", "#{path}**/.*"].each do |entry|
        next if entry[/^.*\/\.+$/]
        data << directory_list(entry)
      end
      return data.flatten
    end # directory_list

    # Creates a data string of a tar gzip file containing all files in
    # list. See {#untar} for decompression.
    # @param files [Arrray] list of files to add to archive
    # return [StringIO] data bytes of tar gzip archive.
    def tar(files)
      data = StringIO.new("")
      sgz = Zlib::GzipWriter.new(data)
      tar = Archive::Tar::Minitar::Output.new sgz

      puts "[#] start writing files"
      files.each do |f|
        directory_list(f).each do |entry|
          puts "[*] adding: #{entry}"
          Archive::Tar::Minitar.pack_file(entry, tar)
        end
      end

      sgz.flush
      sgz.close
      sgz = nil

      data.rewind
      return data
    end # tar

    # Decompresses a data string of a tar gzip archive to current working
    # directory. See {#tar} for compression.
    # @param data [String] data bytes of tar gzip archive
    def untar(data)
      sgz = Zlib::GzipReader.new(StringIO.new(data))
      tar = Archive::Tar::Minitar::Input.new sgz

      tar.each do |entry|
        puts "[*] #{entry.name}"
        tar.extract_entry "./", entry
      end

      sgz.close
    end # untar

  end # Files
end # RNCP
