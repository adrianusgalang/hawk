class HealthzController < ApplicationController
  def index
		render json: { ok: true , node: "It's alive!"}
	end
end
