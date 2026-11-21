class OfferingTypesController < ApplicationController
  def index
    @types = OfferingType.all
    @new_type = OfferingType.new(counts_for_ldf: false)
  end

  def create
    type = OfferingType.new(type_params)
    type.position = (OfferingType.maximum(:position) || -1) + 1
    flash_result(type.save, type, "Offering type added.")
  end

  def update
    type = OfferingType.find(params[:id])
    flash_result(type.update(type_params), type, "Saved.")
  end

  def destroy
    type = OfferingType.find(params[:id])
    if type.contributions.exists?
      type.update!(active: false)
      redirect_to offering_types_path, notice: "#{type.name} has recorded amounts, so it was hidden instead of deleted."
    else
      type.destroy!
      redirect_to offering_types_path, notice: "Deleted."
    end
  end

  private

  def type_params = params.require(:offering_type).permit(:name, :counts_for_ldf, :active, :position)

  def flash_result(ok, type, msg)
    if ok
      redirect_to offering_types_path, notice: msg
    else
      redirect_to offering_types_path, alert: type.errors.full_messages.to_sentence
    end
  end
end
