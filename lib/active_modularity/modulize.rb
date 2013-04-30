require 'active_support/concern'

module ActiveModularity
  module Modulize
    extend ActiveSupport::Concern
    included do
      singleton_class.alias_method_chain :inherited, :modularity
    end

    module ClassMethods
      def inherited_with_modularity(subclass)
        inherited_without_modularity(subclass).tap do
          subclass.modulize_reflections!
          subclass.store_full_sti_class = false
          subclass.force_sti_base!
        end
      end
      
      # fix inner module single table inheritance
      def find_sti_class(type_name)
        if type_name && self.name =~ /^([A-Z][^:]*::)[^:]+$/
          type_name = $1 + type_name
        end
        super
      end
      
      # fix inner module sti base class
      def force_sti_base!
        if superclass.name == name.demodulize and !abstract_class? and columns_hash.include?(inheritance_column) 
          singleton_class.send(:define_method, :descends_from_active_record?) { true }
          return true
        end
        false
      end
      
      # fix inner module reflections
      def modulize_reflections!
        self.reflections = Hash[superclass.reflections.map{|k,v| [k, modulize_reflection(v)]}]
      end
      
      def modulize_reflection(reflection)
        return reflection if reflection.active_record != superclass
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
