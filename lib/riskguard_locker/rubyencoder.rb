module RiskguardLocker
  class Rubyencoder
    def initialize(parametros)
      @parametros_riskguard_locker = ParametrosRiskguardLocker.new
      @configuracion_cliente = parametros[:configuracion_cliente]
      @ruby_version = parametros[:ruby_version]
    end

    def generar_archivo_licencia
      system <<-SH
      cd #{@configuracion_cliente.directorio_empaquetado_cliente};
      licgen --projid "#{@configuracion_cliente.obtener(:projid)}" --projkey "#{@configuracion_cliente.obtener(:projkey)}" --mac #{@configuracion_cliente.obtener(:mac)} --expire #{@configuracion_cliente.obtener(:expire)} #{@configuracion_cliente.obtener(:archivo_licencia)}
      SH
    end

    def comando_rubyencoder
      <<-SH
      rubyencoder --ruby #{@ruby_version} --encoding UTF-8 \\
      --stop-on-error \\
      --projid  "#{@configuracion_cliente.obtener(:projid)}" \\
      --projkey "#{@configuracion_cliente.obtener(:projkey)}" \\
      --external #{@configuracion_cliente.obtener(:archivo_licencia)} -b- --rails -r "*.rb";
      licgen \\
      --projid  "#{@configuracion_cliente.obtener(:projid)}" \\
      --projkey "#{@configuracion_cliente.obtener(:projkey)}" \\
      --days 1 \\
      #{@configuracion_cliente.obtener(:archivo_licencia)}; # Se genera una licencia sin parametros de bloqueo
      cp -r /usr/local/rubyencoder/rgloader .
      SH
    end
  end
end
