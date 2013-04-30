require 'active_support/concern'

module ActiveModularity
  module Modulize
    extend ActiveSupport::Concern
    included do
      modulize!
      singleton_class.alias_method_chain :inherited, :modularity
    end

    module ClassMethods
      def inherited_with_modularity(subclass)
        inherited_without_modularity(subclass).tap do
          subclass.modulize!
        end
      end
      
      def modulize!
        return if self == ActiveRecord::Base
        modulize_reflections!
        self.store_full_sti_class = false
        force_sti_base!
      end
      
      # fix inner module single table inheritance
      def find_sti_class(type_name)
        module_name = self.name.deconstantize
        if type_name && module_name.present?
          type_name = "#{module_name}::#{type_name}"
        end
        super
      end
      
      # fix inner module sti base class
      def force_sti_base!
        if ActiveRecord::Base != superclass &&
           !self.abstract_class? &&
           superclass.descends_from_active_record? &&
           superclass.name == name.demodulize &&
           columns_hash.include?(inheritance_column)
          singleton_class.send(:define_method, :descends_from_active_record?) { true }
          true
        else
          false
        end
      end
      
      # fix inner module reflections
      def modulize_reflections!
        self.reflections = Hash[superclass.reflections.map{|k,v| [k, modulize_reflection(v)]}]
      end
      
      def modulize_reflection(reflection)
        return reflection if reflection.active_record != superclass
        return reflection unless reflection.kind_of?(ActiveRecord::Reflection::AssociationReflection)
        modulized_reflection = reflection.dup
        modulized_reflection.instance_variable_set(:@active_record, self)
        modulized_reflection.instance_variable_set(:@class_name, nil)
        modulized_reflection.instance_variable_set(:@klass, nil)
        modulized_reflection.instance_variable_set(:@foreign_key, reflection.foreign_key)
        modulized_reflection
      end
    end
  end
end
