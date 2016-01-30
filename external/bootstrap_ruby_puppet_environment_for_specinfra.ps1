$puppet_env = @{ 
  'statedir' = $null;
  'confdir'  = $null;
  'lastrunfile' = $null;
  'lastrunreport'  = $null;
}
$puppet_env.keys.Clone() | foreach-object { 
$env_key = $_
$puppet_env[$env_key] = iex "puppet config print ${env_key}"
}


$puppet_env['basedir'] = (((iex 'cmd.exe /c where.exe puppet.bat') -replace 'bin\\puppet.bat' ,'' ) -replace '\\$', ''  ) -replace '\\', '/'
$env:PUPPET_BASEDIR = $puppet_env['basedir'] -replace '/', '\'
write-host -foreground 'yellow' ('setting PUPPET_BASEDIR={0}' -f $env:PUPPET_BASEDIR ) 
$puppet_env | format-table -autosize
$env:PATH = "$env:PUPPET_BASEDIR\puppet\bin;$env:PUPPET_BASEDIR\facter\bin;$env:PUPPET_BASEDIR\hiera\bin;$env:PUPPET_BASEDIR\bin;$env:PUPPET_BASEDIR\sys\ruby\bin;$env:PUPPET_BASEDIR\sys\tools\bin;${env:PATH};"
write-host -foreground 'yellow' ('setting PATH={0}' -f $env:PATH )
$status = iex 'ruby.exe -v'
write-host -foreground 'yellow' $status
# REM Set the RUBY LOAD_PATH using the RUBYLIB environment variable
$ruby_libs = @()
@(
'puppet',
'facter',
'hiera') | foreach-object {
$app = $_
$ruby_libs += "$($puppet_env['basedir'])/${app}/lib"
}
$env:RUBYLIB = $ruby_libs -join ';'
write-host -foreground 'yellow' ('setting RUBYLIB={0}' -f $env:RUBYLIB )
$env:RUBYOPT = 'rubygems' 
write-host -foreground 'yellow' ('setting RUBYOPT={0}' -f $env:RUBYOPT )

#
@"
require 'yaml'
require 'puppet'
require 'pp'


# parse YAML string
check = YAML.load(<<-'EOF'
---
answer: 42
EOF
)
puts "check=#{check}"


# Emit YAML
check = YAML.dump({'answer'=>42}) 
puts "check=#{check}"

"@ |out-file './test.rb' -encoding ascii
iex  "ruby ./test.rb"
