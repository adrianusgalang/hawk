class ChannelController < ApplicationController
	skip_before_action :verify_authenticity_token, :only => [:index, :broadcast]
	def index
		
		@channel = Channel.all
		render json: @channel.map do |channel|
      channel.to_hash
    end.to_json
		puts 'masuk get channel listß'
	end
	
	def broadcast
		# puts params
		# puts params[:all_channel]
		# puts params[:channel][0]
		# puts params[:channel][1]
		# puts params[:message]
		cortabot = Cortabot.new()
		if params[:all_channel] == 0
			params[:channel].each do |r|
				# puts r
				cortabot.boardcast(r,params[:message])
			end
		else
			channel = Channel.all
			channel.each do |r|
				# puts r.telegram_channel
				cortabot.boardcast(r.telegram_channel,params[:message])
			end
		end

		@channel = Channel.all
		render json: @channel.map do |channel|
      channel.to_hash
		end.to_json

	end

end
