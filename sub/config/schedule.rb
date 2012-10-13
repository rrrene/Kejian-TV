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
#sudo whenever --clear-crontab -uroot
#sudo whenever -uroot --set 'environment=sub_cnu_dev' --write-crontab


set :output,  {:error => "#{Whenever.path}/log_#{environment}/cron_error_log.log", :standard => "#{Whenever.path}/log_#{environment}/cron_log.log"}

case @environment
when 'production','sub_cnu','sub_ibeike'
    every 1.day,:at=>'3:00 am' do
        command "echo CwDaily.calculator"
        runner "CwDaily.calculator"
    end
    
    every 1.day,:at=>'4:00 am' do
        command "echo CwDaily.yesterday_cleaner"
        runner "CwDaily.yesterday_cleaner"
    end

    every :sunday,:at=>'5:00 am' do
        command "echo CwDaily.cleaner"
        runner "CwDaily.cleaner"
    end

    every :month,:at=>'start of the month at 4:30am' do
        command "echo CwDaily.last_month_milestone_check"
        runner "CwDaily.last_month_milestone_check"
    end
    
    every 1.month, :at => 'January 15th 4:30am' do
        command "echo CwDaily.half_month_milestone_check"
        runner "CwDaily.half_month_milestone_check"
    end

when 'sub_ibeike_staging','sub_cnu_staging'
    every 1.day,:at=>'3:00 am' do
        command "echo CwDaily.calculator"
        runner "CwDaily.calculator"
    end

    every :sunday,:at=>'4:00 am' do
        command "echo CwDaily.cleaner"
        runner "CwDaily.cleaner"
    end

    every :month,:at=>'start of the month at 4:30am' do
        command "echo CwDaily.last_month_milestone_check"
        runner "CwDaily.last_month_milestone_check"
    end
when 'sub_cnu_dev','sub_ibeike_dev'
    every 10.minutes do
        command "echo CwDaily.calculator"
        runner "CwDaily.calculator"
    end
    every 1.hour do
        command "echo CwDaily.cleaner"
        runner "CwDaily.cleaner"
    end
else
    every 10.minutes do
        command "echo CwDaily.cleaner"
        runner "CwDaily.cleaner"
    end
end
