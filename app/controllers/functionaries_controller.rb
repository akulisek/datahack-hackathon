class FunctionariesController < ApplicationController

  def index
    @filterrific = initialize_filterrific(
        Functionary,
        params[:filterrific],
        select_options: {
            sorted_by: Functionary.options_for_sorted_by
        }
    ) or return
    @functionaries = @filterrific.find.page(params[:users_page]).per(10)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @functionary = Functionary.find(params[:id])
  end

  private

end
