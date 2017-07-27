require 'yaml'
require "erb"
require "riskguard_locker/version"
require "riskguard_locker/parametros_riskguard_locker"
require "riskguard_locker/git"
require "riskguard_locker/configuraciones_clientes"
require "riskguard_locker/rubyencoder"
require "riskguard_locker/locker"

module RiskguardLocker
  # Your code goes here...
  def self.lock(parametros_locker)
    Locker.new(parametros_locker).empaquetar
  end
end
