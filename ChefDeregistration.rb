#!/usr/bin/env ruby
# 
# Look at the SQS queue for instance that have terminated then deregister from chef

require 'fog'
require 'json'
require 'logger'


aws_key_id = "AWS_ACCESS_KEY"
aws_secret_key = "AWS_SEC_KEY"
queue_url = "https://sqs.us-west-2.amazonaws.com/<ACCOUNT>/DeregQueue"
region = "us-west-2"

knife = "$PATH"

logger = Logger.new(STDOUT)
logger.level = Logger::INFO

sqs = Fog::AWS::SQS.new(
     :aws_access_key_id => aws_key_id,
     :aws_secret_access_key => aws_secret_key,
     :region => region
    )

begin
  puts "Looking at SQS queue"
  messages = sqs.receive_message(queue_url, { 'Attributes' => [], 'MaxNumberOfMessages' => 10 }).body['Message']
  unless messages.empty?
    messages.each do |m|
      begin
        body = JSON.parse(m['Body'])
        message = JSON.parse(body["Message"])
      rescue JSON::ParserError => e
        logger.error("Unable to parse JSON object")
        logger.error(e.message)
        next
      end

      begin
        if message["Event"].include? "autoscaling:EC2_INSTANCE_TERMINATE"
          instance_id = message["EC2InstanceId"]
          find_fqdn = "#{knife} search node 'instance_id:#{instance_id}\' -a ec2.instance_id | cut -d: -f1| sed -e 's/ec2.instance_id//'"
          find_fqdn.gsub(/\n/, "")
          puts "#{find_fqdn}"
          fqdn_resp = `#{find_fqdn}`
          puts "Found #{fqdn_resp} with instance id #{instance_id}"
          delete_node  = "#{knife} node delete #{fqdn_resp}"
          delete_client = "#{knife} client delete #{fqdn_resp}"
  
          output = `#{delete_node}`
          result=$?.success?
          if result != true
            logger.error("Failed to delete node #{fqdn_resp} #{instance_id}")
            logger.error(output)
          end

          output = `#{delete_client}`
          result=$?.success?
          if result != true
            logger.error("Failed to delete client #{fqdn_resp} #{instance_id}")
            logger.error(output)
          end

          logger.info("Node #{fqdn_resp} #{instance_id} deleted successfully")
          sqs.delete_message(queue_url, m['ReceiptHandle'])
        end
      rescue NoMethodError => e
        logger.error("Invalid message in queue")
        logger.error(e.message)
        next
      end
    end
  end
end while ! messages.empty?
