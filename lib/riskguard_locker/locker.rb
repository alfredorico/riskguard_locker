module RiskguardLocker
  class Locker
    def initialize(opciones)
      @rubyencoder_lock = opciones[:lock]
      @configuracion_cliente = ConfiguracionesClientes.new(opciones[:cliente], opciones[:ambiente])
      @motores = opciones[:motores]
      @ruby_version = opciones[:ruby_version]
      @parametros_riskguard_locker = ParametrosRiskguardLocker.new
      @rubyencoder = Rubyencoder.new({configuracion_cliente: @configuracion_cliente, ruby_version: @ruby_version})
    end

    def empaquetar
      limpiar_directorio_empaquetados
      # Generar un único archivo de licencia para todos los componentes
      @rubyencoder.generar_archivo_licencia if @rubyencoder_lock
      case @motores.first
      when 'lic'
         # Ya se generó el archivo de licencia. 
         # Debe declararse la opción para que no caiga en el else del case.
      when 'all'
        empaquetar_full
      when 'riskguard'
        empaquetar_riskguard
      else
        empaquetar_motores(@motores)
      end
      # Empaquetar todo lo generado en un bz2 excepto si genero el archivo de licencia-------------------
      generar_full_bz2 unless @motores.first == 'lic' 
    end

    def generar_gemas_motores_base
      @parametros_riskguard_locker.motores_base.each do |motor|
        generar_gema(motor)
      end
    end

    def generar_gemas_motores_comprados
      @configuracion_cliente.motores_comprados.each do |motor|
        generar_gema(motor)
      end
    end

    def ruta_motor_a_empaquetar(motor)
      File.join(@configuracion_cliente.directorio_empaquetado_cliente,motor)
    end

    def empaquetar_riskguard
      git = Git.new(:riskguard2)
      git.exportar_repo(@configuracion_cliente.directorio_empaquetado_riskguard)
      system <<-SH
        cd #{@configuracion_cliente.directorio_empaquetado_riskguard};
        echo "#{ajustar_gemfile}" >> Gemfile;
        rm -rf tmp/*;
        #{comando_rubyencoder}
        mkdir tmp
        touch tmp/restart.txt
        chmod 777 tmp/restart.txt
        cd ..;
        tar -zcf #{@configuracion_cliente.obtener(:carpeta)}.tar.gz ./#{@configuracion_cliente.obtener(:carpeta)};
        rm -rf #{@configuracion_cliente.directorio_empaquetado_riskguard};
      SH
    end

    def limpiar_directorio_empaquetados
      system <<-SH
      mkdir -p #{@configuracion_cliente.directorio_empaquetado_cliente};
      cd #{@configuracion_cliente.directorio_empaquetado_cliente};
      rm -rf *;
      SH
    end

    def empaquetar_full
      # Generar gemas y tar.gz del proyecto padre riskguard2 -----------------------------------
      generar_gemas_motores_base
      generar_gemas_motores_comprados
      empaquetar_riskguard
    end

    def empaquetar_motores(motores)
      motores.each do |motor|
        generar_gema(motor)
      end
    end
    
    def generar_full_bz2
      sh = <<-SH
      cd #{@configuracion_cliente.directorio_empaquetado_cliente};
      tar -jcf riskguard.tar.bz2 ./*.gem ./*.gz ./*.lic 2> /dev/null;
      rm -f *.gem;
      rm -f *.gz;
      rm -f *.lic;
      SH
      system sh
    end

    def generar_gema(motor)
      git = Git.new(motor)
      git.exportar_repo(ruta_motor_a_empaquetar(motor))
      sh = <<-SH
        cd #{ruta_motor_a_empaquetar(motor)};
        # ------------------------------------------------------------------------------
        # Para el motor estilos:
        # La condición 2>/dev/null es para otros motores que no tienen el directorio y
        # evitar que se muestre el error.
        cp #{@configuracion_cliente.logo_cliente} ./vendor/assets/images/ 2>/dev/null;
        cp #{@configuracion_cliente.logo_producto} ./vendor/assets/images/ 2>/dev/null;
        # ------------------------------------------------------------------------------
        #{comando_rubyencoder}
        gem build #{motor}.gemspec;
        mv *.gem ../;
        cd ../;
        rm -rf #{ruta_motor_a_empaquetar(motor)};
      SH
      system sh
    end

    private
    def comando_rubyencoder
      @rubyencoder.comando_rubyencoder if @rubyencoder_lock
    end

    def ajustar_gemfile
      ruby = <<-RB
      if ENV['RAILS_ENV'] == 'production'
        group :production do
          gem 'baseweb','2.0.0'
          gem 'db','2.0.0'
          gem 'estilos','2.0.0'
          gem 'util','2.0.0'
      RB
      @configuracion_cliente.motores_comprados.each do |motor|
        ruby << "    gem '#{motor}','2.0.0' \n"
      end
      ruby << <<-RB
        end
      end
      RB
    end

  end
end
