module Tarte
  
  module Errors
    class Base < Exception; end
    class NotValidAssociationMask < Errors::Base; end
    class NotValidValidationOptions < Errors::Base; end
  end

  module BakedInAssociations
    #LEDO: add finders? add verifications?
    
    def has_one_baked_in(association_name, methods = nil)
      names_constant = association_name.to_s.pluralize.upcase
      
      write_inheritable_array(:has_one_baked_in_attributes, [association_name])
      
      class_eval <<-EOV
        #{names_constant} = #{methods[:names].inspect}

        def #{association_name}=(value)
          self.#{association_name}_code = #{names_constant}.index(value)
        end

        def #{association_name}
          #{names_constant}[#{association_name}_code]
        end

        def #{association_name}_was
          #{names_constant}[self.#{association_name}_code_was]
        end
        
        def #{association_name}_changed?
          self.#{association_name}_code_changed?
        end
        
        #LEDO: this group has to support group definitions
        def #{association_name}_codes_for(names)
          if names.class == Array
            names.map{|n| #{names_constant}.index(n)}
          else
            #{names_constant}_GROUPS_CODES[names]
          end
        end
      EOV
      
      #LEDO: Add a group options and quet methods and finders
      
      #LEDO: ADD scopes for finder methods
      methods[:names].each_with_index do |value, code|
        class_eval <<-EOV
          def #{value}
            self.#{association_name}_code = #{code}
          end

          def #{value}?
            self.#{association_name}_code == #{code}
          end

          def #{value}!
            update_attribute(:#{association_name}_code, #{code})
          end
          
          def #{association_name}_changed_to_#{value}?
            self.#{association_name}_code_changed? && self.#{association_name}_code == #{code}
          end
        EOV
      end
      
      if methods[:groups]
        hash_with_codes = methods[:groups].merge do |group, member_names|
          member_names.map{|n| methods[:names].index(n)}
        end
        class_eval <<-EOV
          #{names_constant}_GROUPS_CODES = #{hash_with_codes.inspect}
        EOV
      end
      
    end
    
    def has_many_baked_in(association_name, methods = nil)
      names_constant = association_name.to_s.upcase
      methods[:verb] ||= :has
      
      write_inheritable_hash(:has_many_baked_in_attributes, association_name => methods[:verb])
      
      class_eval <<-EOV
        #{names_constant} = #{methods[:names].inspect}
      
        def #{association_name}=(values)
          new_mask = (values & #{names_constant}).map { |v| 2**#{names_constant}.index(v) }.sum
          raise(Tarte::Errors::NotValidAssociationMask) if new_mask >= #{2**methods[:names].size}
          
          self.#{association_name}_mask = new_mask
        end
        
        def #{association_name}
          #{names_constant}.reject { |v| ((self.#{association_name}_mask || 0) & 2**#{names_constant}.index(v)).zero? }
        end
        
        def #{association_name}_were
          #{names_constant}.reject { |v| ((self.#{association_name}_mask_was || 0) & 2**#{names_constant}.index(v)).zero? }
        end
        
        def #{association_name}_changed?
          self.#{association_name}_mask_changed?
        end
        
        #LEDO: this method has to support group definitions
        def #{association_name}_mask_for(names)
          if names.class == Array
            new_mask = (names & #{names_constant}).map { |v| 2**#{names_constant}.index(v.to_sym) }.sum
            raise(Tarte::Errors::NotValidAssociationMask) if new_mask >= #{2**methods[:names].size}
            new_mask
          else
            #{names_constant}_GROUPS_MASKS[names]
          end
          
        end
      EOV

      #LEDO: ADD scopes for finder methods
      # :conditions => ["attribute_mask & ? > 0", 2**index]
      methods[:names].each_with_index do |value, index|
        class_eval <<-EOV
          def #{methods[:verb]}_#{value}?
            self.#{association_name}_mask & #{2**index} > 0
          end
        EOV
      end
      
      # Converts arrays of options into masks.
      if methods[:groups]
        hash_with_masks = methods[:groups].merge do |group, member_names|
          (member_names & methods[:names]).map { |m| 2**methods[:names].index(m.to_sym) }.sum
        end
        class_eval <<-EOV
          #{names_constant}_GROUPS_MASKS = #{hash_with_masks.inspect}
        EOV
      end
    end
  end
end