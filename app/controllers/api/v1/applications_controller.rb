require "#{Rails.root}/app/models/dtos/application.rb"
require "#{Rails.root}/app/models/dtos/chat.rb"


module Api
    module V1
        class ApplicationsController < ApplicationController
            skip_before_action :verify_authenticity_token

            def_param_group :application do
                param :id, :number, desc: 'Application id'	  
                property :token, String, desc: 'Application unique token'  
                property :name, String, desc: 'Application name'
                param :chats_count, :number, desc: 'Number of chats belongs to the application'
                property :created_at, String, desc: 'Date of the application creation'  
                property :updated_at, String, desc: 'Last time the application was updated'
            end


            api :GET, '/applications/', 'Shows all applications'  
            returns array_of: :application, code: 200, desc: 'All applications'
            def index
                applications = Application.order('created_at DESC')
                applicationsDtos = Array.new
                applications.each do |application|
                    applicationsDtos.push(ApplicationDto.new(application))
                end

                render json: {status: "SUCCESS", data: applicationsDtos}, status: 200
            end

            
            api :GET, '/applications/<token>/chats', 'Shows all chats for this application'  
            returns array_of: :application, code: 200, desc: 'All chats'
            def chats
                application = Application.includes(:chats).where(:token => params[:token])
                if !application.exists?
                    render json: {status: "NOT_FOUND"}, status: 404
                    return
                end

                chats = application.first.chats
                chats_dto = Array.new
                chats.each do |chat|
                    chats_dto.push(ChatDto.new(chat))
                end
                
                render json: {data: chats_dto}, status: 200
            end

            
            api :GET, '/applications/<token>', 'Shows application'  
            returns array_of: :application, code: 200, desc: 'Single Application'
            def show
                application = Application.where(:token => params[:id])
                if application.exists?
                    render json: {status: "SUCCESS", data: ApplicationDto.new(application.first)}, status: 200
                else
                    render json: {status: "NOT_FOUND"}, status: 404
                end
            end
            
            api :POST, '/application/', 'Create a new application'  
            returns :application, code: 201, desc: 'Created application'  
            param_group :application
            def create                  
                application = Application.new(application_params)
                application.token = generate_token
                if application.save
                    render json: {status: "SUCCESS", data: ApplicationDto.new(application)}, status: 201
                else
                    render json: {status: "ERROR", data: application.errors}, status: 400
                end
            end

            
            api :DELETE, '/applications/<token>', 'Delete applications'  
            returns array_of: :application, code: 200, desc: 'Deleted application'
            def destroy
                application = Application.where(:token => params[:id])
                if application.exists?
                    application.first.destroy
                    render json: {status: "SUCCESS"}, status: 200
                else
                    render json: {status: "NOT_FOUND"}, status: 404
                end
            end

            
            api :PUT, '/applications/<token>', 'Update application'  
            returns array_of: :application, code: 200, desc: 'Updated applications'
            def update
                application = Application.where(params[:id])
                if application.exists?
                    if application.update_attributes(application_params)
                        render json: {data: application},status: 200
                    end
                end
                render json: {data: application.errors},status: 400
            end

            
            private
            def generate_token
                loop do
                    token = SecureRandom.hex(15)
                    break token unless Application.where(token: token).exists?
                end
            end
            def application_params
                params.permit(:name)
            end
        end
    end
end