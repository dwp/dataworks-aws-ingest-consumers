# DO NOT USE THIS REPO - MIGRATED TO GITLAB

# dataworks-aws-ingest-consumers

This repository contains the Terraform required to stand up the DataWorks Kafka Consumers from the upstream UC brokers.
Currently they run in managed AWS ASGs.

The code for the applications can be found in:
* [Kafka-to-HBase consumer code](https://github.com/dwp/kafka-to-hbase)

Details for the following components can be found in their own READMEs:
* [K2HB Reconciliation Trimmer](docs/k2hb-reconciliation-trimmer.md)

The core AWS Ingest infrastructure that these consumers run in is held within DWP private github.

## Repository setup.

After cloning this repo, please generate `terraform.tf` and `terraform.tfvars` files using
 
```
make bootstrap
```

You must also do this after every change to the terraform variables and inputs required by this repo.

## Concourse Pipelines

### dataworks-aws-ingest-consumers

This is the main pipeline that deploys the components held within this repository. Is is in the main AWS Concourse `dataworks` team. The files for this pipeline are in the `/ci` folder.

The pipeline self updates every time there is a merge to master, but to update manually from the repo, the following commands can be executed:

```
make concourse-login
make update-pipeline
```

## Batch coalescer

This repo also deploys the AWS batch infrastructure for the S3 file coalescer. This process runs daily over the files in S3 that are output as a result of K2HB. There are two types of files is runs over:

* The K2HB files that are created as backups of the files sent to HBase
* The manifests that K2HB produces

The purpose of this process is to coalesce the files in to larger files to make it easier for downstream systems to process them. K2HB produces millions of small files and this can cause problems for both the manifest comparison and the data loaders that use these processes.

Therefore this process attempts to produce files that are as close to 128Mb as possible.

The coalescer can be found at https://github.com/dwp/dataworks-corporate-storage-coalescence and details on the manifest comparison can be found at https://github.com/dwp/dataworks-behavioural-framework/blob/master/docs/aws_dataworks_manifest_comparison.md.

## K2HB insight stats

See also 
* [Kafka-to-HBase consumer code](https://github.com/dwp/kafka-to-hbase)
* The DataWorks AWS Ingest terraform

#### Number of containers seen in time period

For a stable system, should always be a whole fraction of the partitions in the upstream broker, as configured in the locals.tf.

   ```
  # k2hb number of containers seen in time period
  # ...for a stable system, sould always be the ESC main cluser's desired_tasks
  fields @timestamp, hostname
  | stats count_distinct(hostname) as number_containers by bin(10m) as time_slice
  | sort by time_slice asc
   ```

#### Total records processed in time period

   ```
  # k2hb total records processed and average duration in time period
  filter message = "Put record" 
  | stats floor((sum(size) / 1024) / 1024) as batch_total_records_mb, floor(((sum(size) / 1024) / 1024) / 1024) as batch_total_records_gb, floor((((sum(size) / 1024) / 1024) / 1024) / 1024) as batch_total_records_tb, count(*) as total_record_count
  ```

#### Total record counts and sizes per collection

   ```
  # k2hb record counts and sizes per collection
  filter message = "Put record" 
  | stats (floor(sum(size) / 1024)) as record_size_total_kb, (floor(sum(size) / count(*) / 1024)) as record_size_average_kb, count(*) as record_count by table
  | sort record_count desc, table
   ```

#### Records processed and timings per batch grouped by hour and write success, oldest first

   ```
  # k2hb min/avg/median/total per each hour (all containers)
  fields @timestamp, message, record_count, time_taken, succeeded
  | filter message = "Processed batch" 
  | stats sum(size) as batch_total_records, avg(time_taken) / 1000 as batch_avg_duration_sec, min(size) as batch_min_records, 
          avg(size) as batch_avg_records, median(size) as batch_median_records, max(size) as batch_max_records,
          min(time_taken) / 1000 as batch_min_duration_sec, median(time_taken) / 1000 as batch_median_duration_sec, 
          max(time_taken) / 1000 as batch_max_duration_sec by bin(1h) as time_slice, succeeded
  | sort by succeeded, time_slice asc
   ```

#### Records processed per hour per container, oldest first

   ```
  # k2hb min/avg/median/total record count and duration per each hour per container
  fields @timestamp, message, record_count, hostname, time_taken, succeeded
  | filter message = "Processed batch" 
  | stats sum(size) as batch_total_records, avg(time_taken) / 1000 as batch_avg_duration_sec, min(size) as batch_min_records, 
          avg(size) as batch_avg_records, median(size) as batch_median_records, max(size) as batch_max_records,
          min(time_taken) / 1000 as batch_min_duration_sec, median(time_taken) / 1000 as batch_median_duration_sec, 
          max(time_taken) / 1000 as batch_max_duration_sec by bin(1h) as time_slice, hostname, succeeded
  | sort by succeeded, time_slice asc, hostname
   ```

#### Errors and Exceptions seen (any log group, case insensitive)

Note: Can give a lot of false positives, see query below
   ```
   # errors in current log group
   # Can give a lot of false positives
   fields @timestamp, hostname, log_level, message, exception, @message
   | filter @message like /(?i)ERROR/ or message like /(?i)Exception/ #case insensitive
   | sort by @timestamp asc
   ```

#### Relevant errors and warnings (any log group)

   ```
   # relevant errors in current log group, any stream
   # excludes several red-herrings like the word "Error" in a topic_name
   fields @timestamp, hostname, log_level, message, exception, @message
   | filter message != "Subscribed to topic" 
       and message not like /Opening socket connection to server/
       and message not like /Setting newly assigned partitions/
       and message not like /Revoking previously assigned partitions/
       and message not like /Will not attempt to authenticate using SASL (unknown error)/
       and message not like /Setting offset for partition/
       and @message not like /Clock Unsynchronized/ 
       and @message not like /Use GNU Parted to correct GPT errors/ 
       and @message not like /InvalidSequenceTokenException/ 
       and @message not like /urandom warning/ 
       and @message not like /Warning: Keylock active/
       and @message not like /No datasource was provided...using a Map based JobRepository/  
       and @message not like /No transaction manager was provided, using a ResourcelessTransaction/
   | filter @message like /(?i)ERROR/ or message like /(?i)Exception/ #case insensitive
   | sort by @timestamp asc
   ```

#### Consumer lags
Note the "x 20" is based on there being 20 containers per env (see `locals.tf`).

   ```
   # k2hb max consumer group lag (no NaN)
   fields @timestamp, message, coalesce(lag, 0) as base_lag
   | filter message = "Max record lag" and base_lag != "NaN"
   | fields @timestamp, message, coalesce(base_lag, 0) as safe_lag
   | stats max(safe_lag) as lag_max_each, 
       (max(safe_lag) * 20) as estimated_max_group_lag by bin(1h) as time_slice 
   | sort by time_slice asc 
   ```

   ```
   # k2hb max consumer group lag per partition (no NaN)
   fields @timestamp, message, coalesce(lag, 0) as base_lag
   | filter message = "Max record lag" and base_lag != "NaN"
   | fields @timestamp, message, coalesce(base_lag, 0) as safe_lag
   | stats max(safe_lag) as lag_max_each by bin(1h) as time_slice, hostname
   | sort by time_slice asc, hostname asc
   ```

#### Failed batches

   ```
   # Failed batches per table caused by sanity check exceptions
   parse 'Failed to put batch Failed * action: org.apache.hadoop.hbase.exceptions.FailedSanityCheckException: Requested row out of range for doMiniBatchMutation on HRegion *,*servers with issues: *,*' as number_of_actions, table, middle, host, end
   | stats count(*) as number_per_table by table, host
   | sort number_per_table desc
   ```
   
   ```
   # Failed record writes by table, most first
   filter message = "Error writing record to HBase"
   | parse '*db.*:*' as data, table, data2
   | stats count(*) as write_failures by table
   | sort write_failures desc
   ```

#### Partitions seen

Note for some queries we use the hostname as a proxy as each consumer gets assigned different partition(s).
The `partitions` field is actually a list - but if our number of containers matches the number of partitions, they should get one each.

With one container we would see "0, 1, 2, 3, 4, 5". With three, "0, 1" and "2, 3" and "4, 5", and so on.

Seeing more than the desired Max Size in any time period, i.e. an hour, implies a consumer group re-balance occurred, as 
`count_distinct(partitions)` will see all the combinations that exist.

Seeing less (i.e. 1) means there is a problem as it the UC broker does not have the 20 expected any more.

   ```
   # k2hb number of partitions seen in time period
   fields @timestamp, message, partitions
   | filter message = "Partitions read from for topic"
   | stats count_distinct(partitions) as number_partitions by bin (1h) as time_slice
   | sort by time_slice desc
   ```

   ```
   # k2hb current partitions by container (approximated)
   fields @timestamp, partitions, hostname
   | filter message = "Partitions read from for topic"
   | stats max(partitions) as a_partition by hostname, bin (1h) as time_slice
   | sort by time_slice desc, a_partition asc, hostname
   ```

### Queries for k2hb running in ec2

   ```
   # All start, running and restarts:
   fields @message, @timestamp, message, status, hostname
   | filter message = "Starting K2HB"
     or message = "K2HB running"
     or message like /K2HB has stopped running/
   | display @timestamp, message, status, hostname
   ```

### Queries for k2hb put record counts

   ```
   # All records put by day per table - using data recieved
   filter message = "Put record"
   | fields message, table
   | stats count(key) by bin(24h) as date_received, table
   | sort date_received desc, table
   ```

   ```
   # All records put by day per table - using date in the record
   filter message = "Put record"
   | fields message, table, fromMillis(version) as version_date
   | stats count(key) by dateceil(version_date, 24h) as date_in_record, table
   | sort date_in_record desc, table
   ```

   ```
   # All records put, grouped by day, then date in record and table
   filter message = "Put record"
   | fields message, table, fromMillis(version) as version_date
   | stats count(key) as record_count by bin(24h) as loaded_on_date, dateceil(version_date, 24h) as date_in_record, table
   | sort loaded_on_date desc, date_in_record desc, table
   ```

# Queries for durations of inserts

   ```
   # k2hb min/avg/max duration per action
   filter time_taken != "" and message like /Put / and message != "Put record"
   | stats min(time_taken) as min_time, avg(time_taken) as average_time, max(time_taken) as max_time by message
   | sort average_time desc
   ```

# Processing lag
   
   ```
   # k2hb max processing lag by table for given time period
   filter message = "Put record" and time_since_last_modified != "" and time_since_last_modified > 3600
   | stats max(time_since_last_modified) as max_lag by table
   | sort table
   ```
