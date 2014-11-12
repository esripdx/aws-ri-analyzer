require 'bundler/setup'
Bundler.require
require 'optparse'

require 'json'

$auth_data = YAML.load_file 'auth.yml'

$account = false
$region = false

OptionParser.new do |opts|
  opts.on('-a', '--account ACCOUNT', 'The AWS account to use') do |a|
    $account = a
  end
  opts.on('-r', '--region REGION', 'The AWS region to use') do |r|
    $region = r
  end
end.parse!

regions = $auth_data.values.collect{|v| v.keys}.flatten.uniq.sort
usage = "Usage: bundle exec ruby #{$0} --account=#{$auth_data.keys.sort.join(',')} --region=#{regions.join(',')}"

if $account == false or $region == false
  puts usage
  exit 1
end

if $auth_data[$account] == nil
  puts "Error: Could not find credentials for account \"#{$account}\""
  puts usage
  exit 2
end

if $auth_data[$account][$region] == nil
  puts "Error: Could not find credentials for region \"#{$region}\" in account \"#{$account}\""
  puts usage
  exit 3
end

$auth = $auth_data[$account][$region]

AWS.config( :access_key_id=>$auth['access_key_id'], :secret_access_key=>$auth['secret_access_key'], :region=>$region )

ec2 = AWS.ec2

instances = ec2.instances.select{|instance| instance.status == :running}
reserved = ec2.reserved_instances.select{|ri| ri.state == 'active'}

puts "Collecting running instances"
running1 = []
running2 = []
instances.each do |instance|
  print "."
  running1 << instance.instance_type + "/" + instance.availability_zone
  running2 << instance.instance_type + "/" + instance.availability_zone
end
puts
puts

puts "Collecting purchased reserved instances"
purchased1 = []
purchased2 = []
reserved.each do |ri|
  ri.instance_count.times do
    print "."
    purchased1 << ri.instance_type + "/" + ri.availability_zone
    purchased2 << ri.instance_type + "/" + ri.availability_zone
  end
end
puts
puts

#########

puts "Purchased RIs that are not in use by any running EC2 instances:"
running1.each do |r|
  # find the index of the first element that matches the running instance
  i = purchased1.index r
  if !i.nil?
    purchased1.delete_at i
  end
end

purchased1.sort.each do |p|
  puts "  #{p}"
end
puts 

#########

puts "Running instances that are not yet reserved:"
purchased2.each do |p|
  i = running2.index p
  if !i.nil?
    running2.delete_at i
  end
end

running2.sort.each do |r|
  puts "  #{r}"
end
puts

#########

puts "Running Instances:"
puts
instances.sort{|x,y| x.instance_type <=> y.instance_type}.each do |instance|
  puts "  #{instance.instance_type}\t#{instance.availability_zone}\t#{instance.launch_time}\t#{instance.vpc_id}\t#{instance.tags['Name']}"
end
puts
puts

puts "Purchased Reserved Instances"
puts 
reserved.sort{|x,y| x.instance_type <=> y.instance_type}.each do |ri|
  ri.instance_count.times do
    puts "  #{ri.instance_type}\t#{ri.availability_zone}\t#{ri.offering_type}\t#{ri.product_description}"
  end
end
puts
