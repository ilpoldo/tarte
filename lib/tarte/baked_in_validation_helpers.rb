module Tarte  
  module BakedInValidationHelpers
    def validates_baked_in (*attr_names)
      configuration = {:on => :save}
      configuration.update(attr_names.extract_options!)
      codes_to_validate = attr_names.reject!{|attr_name| @@has_one_baked_in_attributes.include? attr_name}
      if codes_to_validate
        validates_code_of(codes_to_validate, configuration)
      else
        validates_mask_of(attr_names, configuration)
      end
    end
    
    def validates_code_of(attr_names, configuration)
      enum = configuration[:is] || configuration[:is_not]
      
      #LE-CHANGE: Doesn't make much sense, and if one appends only the name of a group the method should be able to support it.
      raise(ArgumentError, "An object with the method include? is required must be supplied as the :in option of the configuration hash") unless enum.respond_to?(:include?)
      
      if configuration[:is]
        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless send("#{attr_name}_codes_for".to_sym, enum).include? value
            record.errors.add(attr_name, :inclusion, :default => configuration[:message], :value => send(attr_name))
          end
        end
      else
        validates_each(attr_names, configuration) do |record, attr_name, value|
          if send("#{attr_name}_codes_for".to_sym, enum).include? value
            record.errors.add(attr_name, :exclusion, :default => configuration[:message], :value => send(attr_name))
          end
        end
      end
    end
    
    def validates_mask_of(attr_names, configuration)
      #LE-CHANGE: Doesn't make much sense
      raise(ArgumentError, "An object with the method include? is required must be supplied as the :in option of the configuration hash") unless enum.respond_to?(:include?)
      
      validates_each(attr_names, configuration) do |record, attr_name, value|
        verb = @@has_many_baked_in_attributes[attr_name]
        enum = configuration[verb] || configuration["#{verb}_not".to_sym]
        eql = configuration[:matches] || configuration[:does_not_match]
        
        if configuration[:matches]
          unless send("#{attr_name}_mask_for".to_sym, eql) == value
            record.errors.add(attr_name, :inclusion, :default => configuration[:message], :value => send(attr_name))
          end
        elsif configuration[:does_not_match]
          if send("#{attr_name}_mask_for".to_sym, eql) == value
            record.errors.add(attr_name, :inclusion, :default => configuration[:message], :value => send(attr_name))
          end
        elsif configuration[verb]
          unless send("#{attr_name}_mask_for".to_sym, enum) & value > 0
            record.errors.add(attr_name, :inclusion, :default => configuration[:message], :value => send(attr_name))
          end
        else
          if send("#{attr_name}_mask_for".to_sym, enum) & value > 0
            record.errors.add(attr_name, :exclusion, :default => configuration[:message], :value => send(attr_name))
          end
        end
      end
    end
    
  end
end
