require 'json'
require 'base64'

module Streamer
  class SSE
    def initialize io
      @io = io
    end

    def write string
      @io.write "data: #{JSON.dump({ output: Base64.strict_encode64(string)})}\n\n"
    end

    def close
      @io.close
    end
  end
end
