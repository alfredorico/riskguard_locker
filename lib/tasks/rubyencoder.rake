#encoding: utf-8
params = YAML.load_file("#{Rails.root}/utilitarios/parametros_cerrar_codigo.yml")

desc "Cerrar código para los clientes"
task :cerrar_codigo, :cliente, :ambiente  do |t, args|  
  #args.with_defaults(:cliente => "master", :ambiente => "desarrollo")
  args = Hash.new 
  clientes =  params["clientes"].map {|c,v| c }
  ambientes = params["ambientes"]

  puts "CLIENTES:"
  puts "---------"
  clientes.each {|c| puts "* #{c}"}
  print "Introduzca cliente: "
  args[:cliente] = STDIN.gets.chomp
  raise "Cliente no se encuentra definido. Las opciones son: #{clientes.join(' ')}" unless clientes.include? args[:cliente]  

  puts "\nAMBIENTE:"
  puts "---------"
  ambientes.each {|a| puts "* #{a}"}
  print "Introduzca ambiente: "
  args[:ambiente] = STDIN.gets.chomp
  raise "Ambiente inválido. Las opciones son: #{ambientes.join(' ')}" unless ambientes.include? args[:ambiente]  

  puts "\nRELEASE:"
  puts '---------'
  current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
  releases = `git tag -l`.split("\n").map {|x| x.slice! "brmsuite-riskguard-"; x }.reverse
  puts "* #{current_branch}  --> (Current Branch)"
  releases.each {|r| puts "* #{r}"}
  releases.unshift current_branch
  print 'Introduzca release: '
  args[:release] = STDIN.gets.chomp
  raise "Release inválido. Las opciones son: #{releases.join(' |')}" unless releases.include? args[:release]  
  unless args[:release].eql? current_branch
    args[:release] = "brmsuite-riskguard-#{args[:release]}"
  end

  
  # Configuración del cliente:
  carpeta = params["clientes"][ args[:cliente] ][ args[:ambiente] ]["carpeta"] # Ej: riskguard  o brmsuite-riskguard
  projid = params["clientes"][ args[:cliente] ][ args[:ambiente] ]["projid"]
  projkey =  params["clientes"][ args[:cliente] ][ args[:ambiente] ]["projkey"]
  mac = params["clientes"][ args[:cliente] ][ args[:ambiente] ]["mac"]
  expire = params["clientes"][ args[:cliente] ][ args[:ambiente] ]["expire"]
  archivo_licencia = params["clientes"][ args[:cliente] ][ args[:ambiente] ]["archivo_licencia"]
  #------------------------------------------------------------------------------
  
  directorio_generado_cliente = "$HOME/#{params["ubicacion"]}/#{args[:cliente]}/#{carpeta}" #Ej: $HOME/brmsuite-riskguard-cerrado/master/

  configuraciones_clientes = "#{Rails.root}/utilitarios/configuraciones_clientes"
  comandos = <<-CADENA
    cd $HOME 
    rm -rf #{directorio_generado_cliente} 
    mkdir -p #{directorio_generado_cliente} 
    cd #{Rails.root} 
    branche_actual=$(git rev-parse --abbrev-ref HEAD)
    commit_actual=$(git rev-parse HEAD)
    git checkout #{args[:release]} 
    branche_cambiado=$(git rev-parse --abbrev-ref HEAD)
    git checkout-index -f -a --prefix=#{directorio_generado_cliente}/ 
    cp #{configuraciones_clientes}/#{args[:cliente]}/assets/5_imagen_institucional.css #{directorio_generado_cliente}/app/assets/stylesheets/ 
    cp #{configuraciones_clientes}/#{args[:cliente]}/assets/rails_admin_imagen_institucional.css #{directorio_generado_cliente}/app/assets/stylesheets/ 
    cp #{configuraciones_clientes}/#{args[:cliente]}/assets/logo_banco.png #{directorio_generado_cliente}/app/assets/images/imagen_institucional/   
    # En caso de que opensinergia venda riskguard -----------------
    cp #{configuraciones_clientes}/#{args[:cliente]}/assets/logo_riskguard.png #{directorio_generado_cliente}/app/assets/images/ 2>/dev/null
    cp #{configuraciones_clientes}/#{args[:cliente]}/assets/favicon.ico #{directorio_generado_cliente}/app/public/ 2>/dev/null
    # Fin logo opensinergia riskguard -------------------
    cp -r #{configuraciones_clientes}/#{args[:cliente]}/db/*.sql #{directorio_generado_cliente}/db/configuracion_cliente/ 
    files=$(ls #{configuraciones_clientes}/#{args[:cliente]}/db/*.rb  2> /dev/null | wc -l)
    # Parche para aplicar las transformaciones
    cp -r #{configuraciones_clientes}/#{args[:cliente]}/rb/transformaciones.rb #{directorio_generado_cliente}/app/models/
    # Optimizacion del proceso de carga - Para mibanco se mantiene la versión vieja
    if [ -f #{configuraciones_clientes}/#{args[:cliente]}/rb/depurar_archivo.rb ] ; then cp #{configuraciones_clientes}/#{args[:cliente]}/rb/depurar_archivo.rb #{directorio_generado_cliente}/app/models/proceso_de_carga/ ; fi
    git checkout $branche_actual 
    if [ "$files" != "0" ];  then cp -r #{configuraciones_clientes}/#{args[:cliente]}/db/*.rb #{directorio_generado_cliente}/db/migrate/; fi            
    cd #{directorio_generado_cliente}/ 
    #{'echo "==\nVERSION DE DESARROLLO - BRANCH: $branche_cambiado COMMIT: $commit_actual al `date`\n=="> VERSION.txt' }
    rm -rf lib/tasks/rubyencoder.rake 
    rm -rf utilitarios/ 
    rake assets:precompile 
    rm -rf tmp/*
    rubyencoder --ruby 1.9.2 --encoding UTF-8 --projid "#{projid}" --projkey "#{projkey}" --external #{archivo_licencia} -b- --rails -r -x "modificar_gemas/*" "*.rb" 
    licgen --projid "#{projid}" --projkey "#{projkey}" --mac #{mac} --expire #{expire} #{archivo_licencia} 
    cp -r /usr/local/rubyencoder/rgloader .
    cd .. 
    tar -zcf #{carpeta}.tar.gz ./#{carpeta} 
    rm -rf ./#{carpeta} 
    cd #{Rails.root}
  CADENA
  #puts comandos
  system comandos
end
