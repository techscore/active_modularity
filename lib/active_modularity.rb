require "active_modularity/version"
require 'active_modularity/modulize'
require 'active_support'

module ActiveModularity
  def acts_as_modularity
    include ActiveModularity::Modulize
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:extend, ActiveModularity)
end