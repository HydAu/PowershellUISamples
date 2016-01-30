require 'yaml'
# http://stackoverflow.com/questions/13750342/yamlload-raises-undefined-class-module-error
require 'puppet'
# https://docs.puppetlabs.com/puppet/4.3/reference/yard/Puppet/Transaction/Report.html
# https://searchcode.com/codesearch/view/74280954/
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


data = File.read('./last_run_report.yaml')

puppet_transaction_report = YAML.load(data)
# pp puppet_transaction_report
#<Puppet::Transaction::Report:0x2304708>

raw_summary =  puppet_transaction_report.raw_summary
# pp raw_summary
# {"version"=>{"config"=>1453471083, "puppet"=>"3.8.5"},
# "resources"=>
#  {"changed"=>3,
#   "failed"=>0,
#   "failed_to_restart"=>0,
#   "out_of_sync"=>3,
#   "restarted"=>0,
#   "scheduled"=>0,
#   "skipped"=>8,
#   "total"=>12},
# "time"=>
#  {"config_retrieval"=>1.234395,
#   "exec"=>13.062496,
#   "reboot"=>0.0,
#   "total"=>14.296890999999999,
#   "last_run"=>1454178802},
# "changes"=>{"total"=>3},
# "events"=>{"failure"=>0, "success"=>3, "total"=>3}}
#

puppet_transaction_report_yaml_properties = puppet_transaction_report.to_yaml_properties
# pp puppet_transaction_report_yaml_properties

#[:@metrics,
# :@logs,
# :@resource_statuses,
# :@host,
# :@time,
# :@kind,
# :@report_format,
# :@puppet_version,
# :@configuration_version,
# :@transaction_uuid,
# :@environment,
# :@status]

puppet_resource_statuses = puppet_transaction_report.resource_statuses
# pp puppet_resource_statuses.keys
# ["Exec[puppet_log_rename_run_command_key]",
#  "Exec[destroy_registry_key]",
#  "Exec[create_registry_key]",
#  "Reboot[testrun]",
#  "Exec[after_reboot]",
#  "Schedule[puppet]",
#  "Schedule[hourly]",
#  "Schedule[daily]",
#  "Schedule[weekly]",
#  "Schedule[monthly]",
#  "Schedule[never]",
#  "Filebucket[puppet]"]

puppet_resource_status = puppet_transaction_report.resource_statuses["Reboot[testrun]"]
# pp puppet_resource_status
# #<Puppet::Resource::Status:0x22c7820
#  @change_count=1,
#  @changed=true,
#  @containment_path=["Stage[main]", "Main", "Reboot[testrun]"],
#  @evaluation_time=0.0,
#  @events=[defined 'when' as 'pending'],
#  @failed=false,
#  @file="C:/modules/site/reboot/tests/reboot_autoupdate_windows_2012_20152.pp",
#  @line=38,
#  @out_of_sync=true,
#  @out_of_sync_count=1,
#  @resource="Reboot[testrun]",
#  @resource_type="Reboot",
#  @skipped=false,
#  @tags=#<Puppet::Util::TagSet: {"reboot", "testrun", "class"}>,
#  @time="2016-01-22T13:58:27.201073000+00:00",
#  @title="testrun">

puppet_resource_events = puppet_resource_status.events
# pp puppet_resource_events
# [defined 'when' as 'pending']
# compute_status
# puppet_resource_status.out_of_sync_count
# puppet_resource_status.change_count
# puppet_resource_status.skipped

logs = puppet_transaction_report.logs
# pp logs
# [executed successfully,
# executed successfully,
# defined 'when' as 'pending',
# Applied catalog in 13.11 seconds]

status = puppet_transaction_report.status
# pp status
# "changed"

# def exit_status
#    status = 0
#    status |= 2 if @metrics["changes"]["total"] > 0
#    status |= 4 if @metrics["resources"]["failed"] > 0
#    status
#  end

metrics = puppet_transaction_report.metrics
# pp metrics
# {"resources"=>
#   #<Puppet::Util::Metric:0x22ef3c0
#    @label="Resources",
#    @name="resources",
#    @values=
#     [["total", "Total", 12],
#      ["skipped", "Skipped", 8],
#      ["failed", "Failed", 0],
#      ["failed_to_restart", "Failed to restart", 0],
#      ["restarted", "Restarted", 0],
#      ["changed", "Changed", 3],
#      ["out_of_sync", "Out of sync", 3],
#      ["scheduled", "Scheduled", 0]]>,
#  "time"=>
#   #<Puppet::Util::Metric:0x22edd70
#    @label="Time",
#    @name="time",
#    @values=
#     [["exec", "Exec", 13.062496],
#      ["reboot", "Reboot", 0.0],
#      ["config_retrieval", "Config retrieval", 1.234395],
#      ["total", "Total", 14.296890999999999]]>,
#  "changes"=>
#   #<Puppet::Util::Metric:0x22ecf48
#    @label="Changes",
#    @name="changes",
#    @values=[["total", "Total", 3]]>,
#  "events"=>
#   #<Puppet::Util::Metric:0x22eca50
#    @label="Events",
#    @name="events",
#    @values=
#     [["total", "Total", 3],
#      ["failure", "Failure", 0],
#      ["success", "Success", 3]]>}
