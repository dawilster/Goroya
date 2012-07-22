class FetchController < ApplicationController
	include HTTParty
	require 'rdiscount'

	def index
		params[:id] = '3155667'
		@gist = Post.find('3155667')
		@content = @gist.content			
		@desc = @gist.name		
		@user = @gist.gist_id
		render :action => 'show'
	end

	def show
		if params[:up] == 'update'

			@response = HTTParty.get("https://api.github.com/gists/#{params[:id]}")		
			@gist = Post.find(params[:id])	
			@gist.name = @response["description"]		
			@response["files"].each do |file|
				@content = file[1]["content"]
			end		
			@gist.content = RDiscount.new(@content).to_html
			@gist.id = params[:id]
			@gist.gist_id = @response["user"]["login"]
			if @gist.save	
				# flash[:message] = "updated gist"		
			end		
		end
		if  Post.exists?(params[:id])
			@gist = Post.find(params[:id])
			@content = @gist.content			
			@desc = @gist.name
			@user = @gist.gist_id
		else
			@response = HTTParty.get("https://api.github.com/gists/#{params[:id]}")
			if @response["message"]
				render :file => "#{Rails.root}/public/404.html"
			else	
				@gist = Post.new
				@gist.name = @desc = @response["description"]
				@response["files"].each do |file|
					@content = file[1]["content"]
				end
				@gist.content = @content = RDiscount.new(@content).to_html
				@gist.id = params[:id]
				@gist.gist_id = @response["user"]["login"]
				@gist.save
			end
		end
		@page_title = @desc
	end

	def not_found

	end

	private

	def update_gist(id)
		gist = Post.find(id)
		response = HTTParty.get("https://api.github.com/gists/#{id}")
		gist.name = response["description"]
		response["files"].each do |file|
			text = file[1]["content"]
		end
		gist.content = RDiscount.new(text).to_html
		gist.save
	end

end
