require "./lib/minizork"
require "sinatra"
require "sinatra/partial"

class MiniZorkWeb < MiniZork
  #created in case any web-specific code needed,
  #though that apparenty hasn't been necessary
  def initialize
    super
  end
end

class MiniZorkApp < Sinatra::Base

  helpers do
    def reset
      settings.mzw = MiniZorkWeb.new
    end
  end
  
  set :mzw, MiniZorkWeb.new    

  get '/' do
    reset
    @mzw2 = settings.mzw
    erb :index, locals:{mzw2:@mzw2}
  end

  post '/' do
    command = params['clicked_command'].to_sym
    unless settings.mzw.game_over
      settings.mzw.play(command)
      if settings.mzw.output_hash[:move] == false
        @msg = "There is no exit to the #{command.to_s.upcase}!"
        erb :invalid_move, locals: {msg: @msg}
      else
        @mzw2 = settings.mzw
        #@exits = erb :exits
        erb :turn, locals: {mzw2: @mzw2}
      end
    end
  end
  
  get '/exits' do
    erb :exits, :layout => false
  end

  get '/info' do
    erb :info
  end
end

MiniZorkApp.run!