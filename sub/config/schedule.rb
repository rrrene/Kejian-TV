# -*- encoding : utf-8 -*-
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
#whenever --clear-crontab

set :output,  {:error => "#{Whenever.path}/log_#{environment}/cron_error_log.log", :standard => "#{Whenever.path}/log_#{environment}/cron_log.log"}

case @environment
when 'production'
    every 1.day,:at=>'3:00 am' do
        command "echo hi"
        # runner ""
    end

    every :sunday,:at=>'4:00 am' do
        command "echo hi"
        #runner ""
    end

    every :month,:at=>'start of the month at 4:30am' do
        command "echo hi"
        #runner ""
    end
when 'sub_ibeike_staging'
    every 1.day,:at=>'3:00 am' do
        command "echo hi"
        # runner ""
    end

    every :sunday,:at=>'4:00 am' do
        command "echo hi"
        #runner ""
    end

    every :month,:at=>'start of the month at 4:30am' do
        command "echo hi"
        #runner ""
    end
when 'sub_cnu_dev'
    every 5.minutes do
        command 'echo hi'
    end
end
