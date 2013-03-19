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
require 'rncp/networking'
require 'stringio'
require 'fileutils'
require 'zlib'
require 'archive/tar/minitar'
require 'tempfile'

module RNCP
  class NcpListener
    include RNCP::Networking

    def initialize
    end

    def listen
      puts "[#] rncp Listener: creating new connection"
      l = bind_tcp
      puts "[*] waiting for connections"      

      sock, info = l.accept
      printf "[*] connection from %s:%s\n", info.ip_address, info.ip_port
      puts "[*] receiving..."

      data = ""
      while (sock.eof? == false)
        data += sock.gets()
      end

      sgz = Zlib::GzipReader.new(StringIO.new(data))
      tar = Archive::Tar::Minitar::Input.new sgz

      tar.each do |entry|
        puts "[*] #{entry.name}"
        tar.extract_entry "./", entry
      end

      puts "[*] received: "

      puts "[#] finished"
      sock.close
      l.close

    end
  end
end