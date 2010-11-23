module Hapi::Command::Exec
  # run commands
  def run_default
  end

  def run_build
    puts "building!!!"
  end

  def run_list
    puts @hud.jobs.names
  end

  def run_config
    puts "configing!!!"
  end

  # helper commands
  def cmd_list
    command_list.map {|m| m.gsub(/^run_/, '')}
  end

  def command_list
    self.methods.select {|m| m =~ /^run_/}
  end

end
