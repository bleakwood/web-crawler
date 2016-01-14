require "selenium-webdriver"
require "pry-byebug"
require 'timers'

def collect_data
	driver = Selenium::WebDriver.for :firefox
	driver.navigate.to "https://mp.weixin.qq.com"

	element = driver.find_element(:name, 'account')
	element.send_keys "danna@beamalliance.com"
	element = driver.find_element(:name, 'password')
	element.send_keys ""

	driver.find_element(:id, 'loginBt').click

	wait = Selenium::WebDriver::Wait.new(:timeout => 5)
	wait.until { driver.find_element(:id => "menuBar").displayed? }

	link = driver.find_element(:link_text, '图文分析')
	link.click

	wait.until { driver.find_element(:id => "js_articles_items").displayed? }

	fname = "sample.txt"
	somefile = File.open(fname, "a")
	begin
		somefile.puts Time.now.strftime("%m-%d %H:%M")
		items = driver.find_elements(:css, '.appmsg_chart_abstract')
		items.each do |item|
			title = item.find_element(:class, 'sub_title').text
			somefile.puts title
			view_counts_array = item.find_elements(:css, '.td2 em')
			description_array = ["送达人数", "图文页阅读人数", "原文页阅读人数", "转发+收藏人数"]
			(0..3).each do |i|
				somefile.puts description_array[i]
				somefile.puts view_counts_array[i].text
			end
		end
	rescue Exception => e
		puts "#{e.class} with message: #{e.message}"
	  puts e.backtrace.join("\n")
	ensure
		somefile.close
		driver.quit
	end
end

collect_data

timers = Timers::Group.new
five_second_timer = timers.every(3600) { collect_data }
loop { timers.wait }