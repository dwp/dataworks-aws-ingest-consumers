# K2HB Reconciliation Trimmer

## Running the trimmer ad-hoc
The trimmer runs on AWS Batch ad-hoc. You can kick it off per table, per environment using the pipeline here:
[k2hb-reconciliation-trimmer](https://ci.dataworks.dwp.gov.uk/teams/utility/pipelines/k2hb-reconciliation-trimmer)

## Log Groups
AWS Batch creates a log group for us when we create a compute environment. Each task ran on a compute environment creates a seperate log stream within the AWS Batch log group. You can find the log stream for the particular job you are interested in, by viewing the jobs details on the console.
All log streams are held under: `/aws/batch/job/k2hb_reconciliation_trimmer_job/`
