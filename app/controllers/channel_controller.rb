class ChannelController < ApplicationController

	def index
		
		@channel = Channel.all
		render json: @channel.map do |channel|
      channel.to_hash
    end.to_json
		puts 'masuk get channel listß'
  end

end
