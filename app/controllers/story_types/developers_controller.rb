# frozen_string_literal: true

module StoryTypes
  class DevelopersController < StoryTypesController
    before_action :find_developer, only: :update

    def show; end

    def edit
      @developers = AccountRole.find_by(name: 'HLE Content Developer').accounts
    end

    def update
      @story_type.update!(developer: @developer)

      render 'story_types/developers/show'
    end

    private

    def find_developer
      @developer = Account.find_by(id: params[:developer][:id])
    end
  end
end
