#!/usr/bin/env ruby

require 'rubygems'
require 'aws-sdk'

def createDest(destination_s3_bucket,destination_s3_region)
  s3 = AWS::S3.new(:region => destination_s3_region)
  bucket = s3.buckets[destination_s3_bucket]
  if bucket.exists?
    puts "Bucket #{destination_s3_bucket} already exists."
  else
    puts "Creating bucket #{destination_s3_bucket}."
    bucket = s3.buckets.create(destination_s3_bucket)
  end
end

def syncBuckets(destination_s3_bucket,source_s3_bucket,destination_s3_region,source_s3_region)
  cmd = `aws s3 sync s3://#{source_s3_bucket} s3://#{destination_s3_bucket}`
  puts cmd
end

source_s3_region = 'us-east-1'
destination_s3_region = 'us-west-2'
source_s3_bucket = 'source_s3_bucket'
destination_s3_bucket = 'destination-bucket-backup'

s3 = AWS::S3.new(
      :access_key_id => 'AWS_KEY',
      :secrete_access_key => 'AWS_SEC)KEY'
)

createDest(destination_s3_bucket,destination_s3_region)
syncBuckets(destination_s3_bucket,source_s3_bucket,destination_s3_region,source_s3_region)
