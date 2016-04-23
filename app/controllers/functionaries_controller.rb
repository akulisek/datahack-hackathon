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

  def gains_json
    json = { "gains" => []}
    @functionary = Functionary.find(params[:id])
    previous = 0
    @functionary.gains.includes(:proclamation).each do |gain|
      value = gain.convert_value_to_eur
      json["gains"].push({"value" => value + previous, "year" => gain.proclamation.year})
      previous = value
    end

    respond_to do |format|
      format.json { render :json => json }
    end
  end

  def gains__per_year_json
    json = { "gains" => []}
    @functionary = Functionary.find(params[:id])
    total = 0
    @functionary.gains.includes(:proclamation).each do |gain|
      value = gain.convert_value_to_eur
      total += value
    end
    json["gains"].push({"total_value" => total})

    respond_to do |format|
      format.json { render :json => json }
    end
  end

  def total_gains_json
    json = { "gains" => []}
    @functionary = Functionary.find(params[:id])
    total = 0
    @functionary.gains.includes(:proclamation).each do |gain|
      value = gain.convert_value_to_eur
      total += value
    end
    json["gains"].push({"total_value" => total})

    respond_to do |format|
      format.json { render :json => json }
    end
  end

  private

end
