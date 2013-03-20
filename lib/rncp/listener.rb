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
    end # listen

    def poll
      addr = nil
      msock = join_multicast
      puts "[*] waiting for something-cast"
      loop do
        begin
          data, addr = msock.recvfrom 1024
          if addr[1] == RNCP::PORT
            puts "[*] found pusher at #{addr[3]}:#{addr[1]}"
            puts "[#] Anouncement: #{data}"
            break
          else
            puts "[?] received garbase from #{addr}"
          end
        rescue Execeptione => e
          puts "exception #{e}"
        end # begin
      end #loop

      msock.close if msock.nil? == false

      sock = TCPSocket::new addr[3], addr[1]
      sock.send "I am ready!", 0

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
    end # poll

  end # NcpListener
end # RNCP
