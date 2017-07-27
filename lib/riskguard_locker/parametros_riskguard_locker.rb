module RiskguardLocker
  class ParametrosRiskguardLocker

    PARAMETROS_RISKGUARD_LOCKER = YAML.load(ERB.new(File.read(File.expand_path("../../../config/parametros_riskguard_locker.yml", __FILE__))).result)

    def parametros_riskguard_locker
      @parametros_riskguard_locker ||= PARAMETROS_RISKGUARD_LOCKER
    end

    def clientes
      parametros_riskguard_locker["clientes"]
    end

    def riskguard_empaquetado
      parametros_riskguard_locker["riskguard_empaquetado"]
    end

    def ambientes
      parametros_riskguard_locker["ambientes"]
    end

    def motores_base
      parametros_riskguard_locker["motores_base"]
    end

    def motores
      parametros_riskguard_locker["ruta_motores"].keys
    end

    def motores_para_cerrar
      parametros_riskguard_locker["motores_para_cerrar"]
    end

    def ruta_motor(motor)
      parametros_riskguard_locker["ruta_motores"][motor.to_s]
    end

    def parametros_cliente(cliente)
      clientes[cliente.to_s]
    end

    def archivo_licencia
      parametros_riskguard_locker["archivo_licencia"]
    end

    # Códigos Fuentes ---------------------------------------------------
    # -------------------------------------------------------------------
    def ruta_baseweb
      parametros_riskguard_locker["ruta_baseweb"]
    end

    # Proyecto padre Riskguard2
    def ruta_riskguard2
      parametros_riskguard_locker["ruta_riskguard2"]
    end

    def listar_parametros
      puts 'Clientes:'
      puts '========='
      clientes.keys.each {|c| puts c}
      puts "\nAmbientes:"
      puts '========='
      ambientes.each {|a| puts a}
    end

  end
end
