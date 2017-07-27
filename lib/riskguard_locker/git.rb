module  RiskguardLocker
  class Git
    
    attr_reader :ruta
    
    def initialize(repo = :riskguard2)
      @repo = repo.to_s
      @parametros_riskguard_locker = ParametrosRiskguardLocker.new
      @ruta = case @repo
              when 'riskguard2'
                @parametros_riskguard_locker.ruta_riskguard2
              else # Para los motores
                @parametros_riskguard_locker.ruta_motor(@repo)
              end
    end
    
    def branch_actual
      sh = <<-SH
      cd #{@ruta};
      git rev-parse --abbrev-ref HEAD;
      SH
      `#{sh}`.chomp
    end
    
    def commit_actual
      sh = <<-SH
      cd #{@ruta};
      git rev-parse HEAD;
      SH
      `#{sh}`.chomp      
    end
    
    def exportar_repo(ruta_exportacion)
      sh = <<-SH
      cd #{@ruta};
      rm -rf #{ruta_exportacion};
      mkdir -p #{ruta_exportacion};
      git checkout-index -f -a --prefix=#{ruta_exportacion}/;
      #{generar_archivo_version(ruta_exportacion)}
      SH
      `#{sh}`.chomp  
    end
    
    def generar_archivo_version(ruta_exportacion)
      <<-SH
      echo "==\nREPOSITORIO: #{@repo}" > #{ruta_exportacion}/VERSION.txt
      echo "VERSION: #{commit_actual} BRANCH: #{branch_actual}" >> #{ruta_exportacion}/VERSION.txt
      echo "FECHA DE EMPAQUETADO: #{Time.now} \n==" >> #{ruta_exportacion}/VERSION.txt
      SH
    end
    
    def releases
      sh = <<-SH
      cd #{@ruta};
      git tag -l
      SH
      `#{sh}`.split("\n")
    end    
    
  end
end
