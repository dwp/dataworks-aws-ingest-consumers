import sys
from awsglue.transforms import *
from awsglue.dynamicframe import DynamicFrame
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.types import *
from pyspark.sql.functions import concat, col, lit, when, sum, lower, split, broadcast, desc, min, max

args = getResolvedOptions(sys.argv, ['JOB_NAME', 'cut_off_time_start', 'cut_off_time_end', 'margin_of_error', 'import_type', 'snapshot_type', 'import_prefix', 'export_prefix'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
spark.conf.set("spark.sql.broadcastTimeout", -1)
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

marginOfError = lit(args['margin_of_error']).cast(LongType())
startTime = lit(args['cut_off_time_start']).cast(LongType())
snapshot_type = args['snapshot_type']
import_type = args['import_type']
import_prefix = args['import_prefix']
export_prefix = args['export_prefix']

database_name = "${database_name}"
import_s3_location = "s3://" + "${manifest_bucket_id}" + "/" + import_prefix + "/"
export_s3_location = "s3://" + "${manifest_bucket_id}" + "/" + export_prefix + "/"
missing_imports_table_name = "${table_name_missing_imports_parquet}_" + import_type + "_" + snapshot_type
missing_exports_table_name = "${table_name_missing_exports_parquet}_" + import_type + "_" + snapshot_type
mismatched_table_name = "${table_name_mismatched_timestamps_parquet}_" + import_type + "_" + snapshot_type
counts_table_name = "${table_name_counts_parquet}_" + import_type + "_" + snapshot_type

datasourceImport = glueContext.create_dynamic_frame.from_options(connection_type="s3", 
connection_options = {"paths": [import_s3_location], "useS3ListImplementation":True,"recurse":True}, 
format="csv",
format_options={
    "withHeader": False,
    "separator": "|"
})

datasourceExport = glueContext.create_dynamic_frame.from_options(connection_type="s3", 
connection_options = {"paths": [export_s3_location], "useS3ListImplementation":True,"recurse":True}, 
format="csv",
format_options={
    "withHeader": False,
    "separator": "|"
})

datasourceImport.printSchema()
datasourceExport.printSchema()

applymappingImport = ApplyMapping.apply(frame = datasourceImport, mappings = [("col0", "string", "id", "string"), 
                   ("col1", "string", "import_timestamp", "long"), ("col2", "string", "database", "string"), 
                   ("col3", "string", "collection", "string"), ("col5", "string", "import_component", "string"), 
                   ("col4", "string", "import_source", "string"), ("col7", "string", "import_type", "string")])

applymappingExport = ApplyMapping.apply(frame = datasourceExport, mappings = [("col6", "string", "id", "string"), 
                   ("col1", "string", "export_timestamp", "long"), ("col2", "string", "database", "string"), 
                   ("col3", "string", "collection", "string"), ("col5", "string", "export_component", "string"), 
                   ("col4", "string", "export_source", "string"), ("col7", "string", "export_type", "string")])

importDynamicFrame = applymappingImport.toDF()
exportDynamicFrame = applymappingExport.toDF()

filteredWithinMarginOfErrorImport = importDynamicFrame.filter(importDynamicFrame["import_timestamp"] <= marginOfError)
filteredWithinMarginOfErrorExport = exportDynamicFrame.filter(exportDynamicFrame["export_timestamp"] <= marginOfError)

filteredBeforeStartTimeCutOffImport = filteredWithinMarginOfErrorImport.filter((startTime == 0) | (filteredWithinMarginOfErrorImport["import_timestamp"] >= startTime))
filteredBeforeStartTimeCutOffExport = filteredWithinMarginOfErrorExport.filter((startTime == 0) | (filteredWithinMarginOfErrorExport["export_timestamp"] >= startTime))

filteredBeforeStartTimeCutOffImport = filteredBeforeStartTimeCutOffImport.repartition(col('database'), col('collection'), col('id'))
filteredBeforeStartTimeCutOffExport = filteredBeforeStartTimeCutOffExport.repartition(col('database'), col('collection'), col('id'))

importDynamicFrameNoDuplicates = filteredBeforeStartTimeCutOffImport.orderBy(desc("import_timestamp")).dropDuplicates(["id", "database", "collection"])

joinedDataFrame = importDynamicFrameNoDuplicates.join(filteredBeforeStartTimeCutOffExport, ["database", "collection", "id"], how='fullouter')

joinedDataFrameWithNewColumns = joinedDataFrame.withColumn('cut_off_time_end', lit(args['cut_off_time_end'])) \
.withColumn("earliest_timestamp", \
    when((col('export_timestamp').isNull()) | \
    (col('import_timestamp') < \
    col('export_timestamp')), \
    col('import_timestamp')).otherwise(col('export_timestamp'))) \
.withColumn("latest_timestamp", \
    when((col('export_timestamp').isNull()) | \
    (col('import_timestamp') > \
    col('export_timestamp')), \
    col('import_timestamp')).otherwise(col('export_timestamp'))) \
.withColumn("earliest_manifest", \
    when(col('export_timestamp') == \
    col('import_timestamp'), "both").otherwise(when((col('export_timestamp').isNull()) | \
    (col('import_timestamp') < col('export_timestamp')), \
    col('import_source')).otherwise(col('export_source')))) \
.withColumn("database_collection", \
    concat(col('database'), lit("."), col('collection')))

collectionsInBothManifests = joinedDataFrameWithNewColumns.filter(joinedDataFrameWithNewColumns["import_source"].isNotNull() & \
    joinedDataFrameWithNewColumns["export_source"].isNotNull()).select("database_collection").dropDuplicates().cache()

filteredMissingImport = joinedDataFrameWithNewColumns.where(col("import_source").isNull())
filteredMissingImportJoined = filteredMissingImport \
        .join( \
            broadcast(collectionsInBothManifests), \
            filteredMissingImport["database_collection"] == collectionsInBothManifests["database_collection"], \
            how='leftsemi')
            
filteredMissingExport = joinedDataFrameWithNewColumns.where(col("export_source").isNull())
filteredMissingExportJoined = filteredMissingExport \
        .join( \
            broadcast(collectionsInBothManifests), \
            filteredMissingExport["database_collection"] == collectionsInBothManifests["database_collection"], \
            how='leftsemi')

filteredMismatched = joinedDataFrameWithNewColumns.where((col("import_source").isNotNull()) & (col("export_source").isNotNull()) & (lower(col("earliest_manifest")) != 'both'))
filteredMismatchedJoined = filteredMismatched \
        .join( \
            broadcast(collectionsInBothManifests), \
            filteredMismatched["database_collection"] == collectionsInBothManifests["database_collection"], \
            how='leftsemi')
     
import_types = ['mongo_insert', 'mongo_update', 'mongo_delete', 'mongo_import']
cnt_cond = lambda cond: sum(when(cond, 1).otherwise(0))

allDatabasesAndCollections = joinedDataFrameWithNewColumns.groupBy("database_collection").agg(
    cnt_cond(col('import_source').isNotNull()).alias('imported_count'),
    cnt_cond(col('export_source').isNotNull()).alias('exported_count'),
    cnt_cond((col('export_source').isNotNull()) & (lower(col('export_component')) == 'hdi') | (lower(col('export_component')) == 'k2hb')).alias('exported_count_from_data_load'),
    cnt_cond((col('export_source').isNotNull()) & (lower(col('export_component')) != 'hdi') & (lower(col('export_component')) != 'k2hb')).alias('exported_count_from_streaming_feed'),
    cnt_cond((col('import_source').isNull()) & (col('export_source').isNotNull())).alias('missing_imported_count'),
    cnt_cond((col('export_source').isNull()) & (col('import_source').isNotNull())).alias('missing_exported_count'),
    cnt_cond((col('import_source').isNotNull()) & (col('export_source').isNotNull()) & (lower(col('earliest_manifest')) == 'import')).alias('mismatched_timestamps_earlier_in_import_count'),
    cnt_cond((col('import_source').isNotNull()) & (col('export_source').isNotNull()) & (lower(col('earliest_manifest')) == 'export')).alias('mismatched_timestamps_earlier_in_export_count'),
    min(col("import_timestamp")).alias('earliest_import_timestamp'),
    max(col("import_timestamp")).alias('latest_import_timestamp'),
    min(col("export_timestamp")).alias('earliest_export_timestamp'),
    max(col("export_timestamp")).alias('latest_export_timestamp')
)

allDatabasesAndCollectionsWithDatabase = allDatabasesAndCollections.withColumn('database', split(col('database_collection'), '\.').getItem(0))
allDatabasesAndCollectionsWithCollection = allDatabasesAndCollectionsWithDatabase.withColumn('collection', split(col('database_collection'), '\.').getItem(1))

dynamicFrameWithAllColumns = DynamicFrame.fromDF(joinedDataFrameWithNewColumns, glueContext, "dynamicFrameWithAllColumns")
dynamicFrameWithAllColumnsMissingImport = DynamicFrame.fromDF(filteredMissingImportJoined, glueContext, "dynamicFrameWithAllColumnsMissingImport")
dynamicFrameWithAllColumnsMissingExport = DynamicFrame.fromDF(filteredMissingExportJoined, glueContext, "dynamicFrameWithAllColumnsMissingExport")
dynamicFrameWithAllColumnsMismatched = DynamicFrame.fromDF(filteredMismatchedJoined, glueContext, "dynamicFrameWithAllColumnsMismatched")
dynamicFrameCounts = DynamicFrame.fromDF(allDatabasesAndCollectionsWithCollection, glueContext, "dynamicFrameCounts")

dynamicFrameSpecificFields = SelectFields.apply(frame = dynamicFrameWithAllColumns, paths = ["id", "database", "collection", 
                    "import_timestamp", "import_source", "import_component", "import_type", "export_timestamp", 
                    "export_source", "export_component", "export_type", "earliest_timestamp", "latest_timestamp", "earliest_manifest"])
dynamicFrameSpecificFieldsMissingImport = SelectFields.apply(frame = dynamicFrameWithAllColumnsMissingImport, paths = ["id", "database", "collection", 
                    "export_timestamp", "export_component", "export_type"])
dynamicFrameSpecificFieldsMissingExport = SelectFields.apply(frame = dynamicFrameWithAllColumnsMissingExport, paths = ["id", "database", "collection", 
                    "import_timestamp", "import_component", "import_type"])
dynamicFrameSpecificFieldsMismatched = SelectFields.apply(frame = dynamicFrameWithAllColumnsMismatched, paths = ["id", "database", "collection", 
                    "import_timestamp", "import_source", "import_component", "import_type", "export_timestamp", 
                    "export_source", "export_component", "export_type", "earliest_timestamp", "latest_timestamp", "earliest_manifest"])

fullTableOutputMissingImport = glueContext.write_dynamic_frame.from_catalog(frame = dynamicFrameSpecificFieldsMissingImport, 
                    database = database_name, table_name = missing_imports_table_name)
fullTableOutputMissingExport = glueContext.write_dynamic_frame.from_catalog(frame = dynamicFrameSpecificFieldsMissingExport, 
                    database = database_name, table_name = missing_exports_table_name)
fullTableOutputMismatched = glueContext.write_dynamic_frame.from_catalog(frame = dynamicFrameSpecificFieldsMismatched, 
                    database = database_name, table_name = mismatched_table_name)
fullTableOutputCounts = glueContext.write_dynamic_frame.from_catalog(frame = dynamicFrameCounts, 
                    database = database_name, table_name = counts_table_name)

job.commit()
