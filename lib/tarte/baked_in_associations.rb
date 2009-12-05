module Tarte
  
  def self.included(base)
    base.extend BakedInAssociations
  end
  
  module BakedInAssociations
    #LEDO: add finders? add verifications?
    
    def has_one_baked_in(association_name, methods = nil)
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

          def #{association_name}_changed_to_#{status}?
            self.#{association_name}_code_changed? && self.#{association_name}_code == #{code}
          end
        EOV
      end
      
      alias_method "#{association_name}_code_changed?".to_sym, "#{association_name}_changed?".to_sym
    end
    
    def has_many_baked_in(association_name, methods = nil)
      names_constant = association_name.upcase
      methods[:verb] ||= :has
      class_eval <<-EOV
        #{names_constant.upcase} = #{methods[:names]}
      
        def #{association_name}=(values)
          self.#{association_name}_mask = (values & #{names_constant}).map { |v| 2**#{names_constant}.index(v.to_sym) }.sum
          raise(TartErrors::NotValidAssociationMask) if self.#{association_name}_mask >= #{names_constant.size}
        end
        
        def #{association_name}
          #{names_constant}.reject { |v| ((self.#{association_name}_mask || 0) & 2**#{names_constant}.index(v)).zero? }
        end
        
        def #{association_name}_changed_to_#{status}?
          self.#{association_name}_code_changed? && self.#{association_name}_code == #{code}
        end
      EOV

      methods[:names].each_with_index do |value, index|
        class_eval <<-EOV
          def #{methods[:verb]}_#{value}?
            self.#{association_name}_mask & #{2**index} > 0
          end
        EOV
      end
      
      alias_method "#{association_name}_mask_changed?".to_sym, "#{association_name}_changed?".to_sym
    end
  end
  
end