module RiskguardLocker
  class ConfiguracionesClientes

    CONFIGURACIONES_CLIENTES = File.expand_path("../../../config/estilos_clientes", __FILE__)

    def initialize(cliente, ambiente)
      @cliente = cliente.to_s
      @ambiente = ambiente.to_s
      @parametros_riskguard_locker = ParametrosRiskguardLocker.new
      @parametros_cliente = @parametros_riskguard_locker.parametros_cliente(@cliente).fetch(@ambiente)
    end

    def motores_cliente
      @parametros_riskguard_locker.parametros_cliente(@cliente).fetch('motores')
    end

    def obtener(parametro)
      @parametros_cliente.fetch(parametro.to_s)
    end

    def motores_comprados
      @parametros_riskguard_locker.parametros_cliente(@cliente).fetch('motores_comprados')
    end

    def directorio_configuraciones_cliente
      File.expand_path("../../../config/#{@cliente}", __FILE__)
    end

    def directorio_empaquetado_cliente
      File.join(@parametros_riskguard_locker.riskguard_empaquetado, @cliente, @ambiente)
    end

    def directorio_empaquetado_riskguard
      File.join(@parametros_riskguard_locker.riskguard_empaquetado, @cliente, @ambiente, obtener(:carpeta))
    end

    def logo_cliente
      File.join(CONFIGURACIONES_CLIENTES,@cliente,'logo_cliente.png')
    end

    def logo_producto
      File.join(CONFIGURACIONES_CLIENTES,@cliente,'logo_producto.png')
    end

  end
end
