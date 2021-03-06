class RequiredMaterialReserveForm
    include Virtus
    include VirtusFormHelpers
    include ModelErrorTrapping
    include RailsHelpers

    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :required_material, Boolean

    attr_accessor :reserve
  
    def self.build_from_params(controller)
      reserve = ReserveSearch.new.get(controller.params[:id])
      self.new(reserve, controller.params[:required_material_reserve_form])
    end
  
    def initialize(reserve, update_params)
      @reserve = reserve
      set_attributes_from_model(@reserve)
      set_attributes_from_params(update_params)
    end
  
    def update_reserve_required_material!(*additions)
      if valid?
        persist!(additions[0])
        true
      else
        return false
      end
    end
  
    private
  
    def persist!(*additions)
      if self.attributes.key?(:required_material) && additions.present?
        value = 'Yes'
        if self.attributes.fetch(:required_material, false) == false
          value = 'No'
        end
        Message.create({'creator'=>additions[0],
          'content'=>"Required material changed to #{value}.",
          'request_id'=>@reserve.id})
      end
      @reserve.attributes = self.attributes
      @reserve.save!
  
      ReserveCheckIsComplete.new(@reserve).check!
    end
  
  end