# frozen_string_literal: true

module DataSets
  class ResponsibleEditorsController < DataSetsController
    before_action :find_data_set
    before_action :find_responsible_editor, only: :update

    def show; end

    def edit
      @responsible_editors = AccountRole.find_by(name: 'Content Manager').accounts
    end

    def update
      if @responsible_editor.nil? || @responsible_editor.roles.find_by(name: 'Content Manager')
        @data_set.update(responsible_editor: @responsible_editor)
      else
        flash.now[:error] = { responsible_editor: :error }
      end

      render 'data_sets/responsible_editors/show'
    end

    private

    def find_responsible_editor
      @responsible_editor = Account.find_by(id: params[:responsible_editor][:id])
    end
  end
end
