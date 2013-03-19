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
require 'rncp/version'

require 'clamp'

require 'rncp/listen_cmd'

module RNCP
  def self.version_string
    "RNCP version #{RNCP::VERSION}"
  end

  module Cli
    class CommandLineRunner < Clamp::Command
      self.default_subcommand = "listen"

      subcommand 'listen', "runs in listener mode, waits for connection", ListenCommand
    end
  end # Cli
end
