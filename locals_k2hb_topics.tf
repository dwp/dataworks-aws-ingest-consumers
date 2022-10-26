locals {

  kafka_consumer_main_topics_regex = {
    //match any "db.*" collections i.e. db.aa.bb, with only two literal dots allowed
    //DW-4748 & DW-4827 - Allow extra dot in last matcher group for db.crypto.encryptedData.unencrypted
    development = "^(db[.]{1}[-\\w]+[.]{1}[-.\\w]+)$"
    qa          = "^(db[.]{1}[-\\w]+[.]{1}[-.\\w]+)$"
    integration = "^(db[.]{1}[-\\w]+[.]{1}[-.\\w]+)$"
    preprod     = "^(db[.]{1}[-\\w]+[.]{1}[-.\\w]+)$"
    production  = "^(db[.]{1}[-\\w]+[.]{1}[-.\\w]+)$"
  }

  kafka_consumer_topics_dedicated = {
    // These are topics that are processed by other ASGs, and should be excluded from processing in main, above
    main_dedicated = {
      development = ["db[.]claimant-history[.]claimHistoryEntry", "db[.]agent-core[.]systemWorkGroupAllocation", "db[.]core[.]wizard", "db[.]data-acceptance[.]pendingAuthorisationCache", "db[.]claimant-history[.]resolvedProperties", "db[.]agent-core[.]caseLoadEvent", "db[.]deductions[.]estimatedDeductions", "db[.]team-core[.]recalculateAgentStats", "db[.]core[.]disclosureData", "db[.]core[.]contract", "db[.]agent-core[.]agentToDo", "db[.]core[.]toDo", "db[.]core[.]statement"]
      qa          = ["db[.]claimant-history[.]claimHistoryEntry", "db[.]agent-core[.]systemWorkGroupAllocation", "db[.]core[.]wizard", "db[.]data-acceptance[.]pendingAuthorisationCache", "db[.]claimant-history[.]resolvedProperties", "db[.]agent-core[.]caseLoadEvent", "db[.]deductions[.]estimatedDeductions", "db[.]team-core[.]recalculateAgentStats", "db[.]core[.]disclosureData", "db[.]core[.]contract", "db[.]agent-core[.]agentToDo", "db[.]core[.]toDo", "db[.]core[.]statement"]
      integration = ["db[.]claimant-history[.]claimHistoryEntry", "db[.]agent-core[.]systemWorkGroupAllocation", "db[.]core[.]wizard", "db[.]data-acceptance[.]pendingAuthorisationCache", "db[.]claimant-history[.]resolvedProperties", "db[.]agent-core[.]caseLoadEvent", "db[.]deductions[.]estimatedDeductions", "db[.]team-core[.]recalculateAgentStats", "db[.]core[.]disclosureData", "db[.]core[.]contract", "db[.]agent-core[.]agentToDo", "db[.]core[.]toDo", "db[.]core[.]statement"]
      preprod     = ["db[.]claimant-history[.]claimHistoryEntry", "db[.]agent-core[.]systemWorkGroupAllocation", "db[.]core[.]wizard", "db[.]data-acceptance[.]pendingAuthorisationCache", "db[.]claimant-history[.]resolvedProperties", "db[.]agent-core[.]caseLoadEvent", "db[.]deductions[.]estimatedDeductions", "db[.]team-core[.]recalculateAgentStats", "db[.]core[.]disclosureData", "db[.]core[.]contract", "db[.]agent-core[.]agentToDo", "db[.]core[.]toDo", "db[.]core[.]statement"]
      production  = ["db[.]claimant-history[.]claimHistoryEntry", "db[.]agent-core[.]systemWorkGroupAllocation", "db[.]core[.]wizard", "db[.]data-acceptance[.]pendingAuthorisationCache", "db[.]claimant-history[.]resolvedProperties", "db[.]agent-core[.]caseLoadEvent", "db[.]deductions[.]estimatedDeductions", "db[.]team-core[.]recalculateAgentStats", "db[.]core[.]disclosureData", "db[.]core[.]contract", "db[.]agent-core[.]agentToDo", "db[.]core[.]toDo", "db[.]core[.]statement"]
    }

    equality = {
      development = ["data[.]equality", "data[.]equality-ni"]
      qa          = ["data[.]equality", "data[.]equality-ni"]
      integration = ["data[.]equality", "data[.]equality-ni"]
      preprod     = ["data[.]equality", "data[.]equality-ni"]
      production  = ["data[.]equality"]
    }

    audit = {
      development = ["data[.]businessAudit"]
      qa          = ["data[.]businessAudit"]
      integration = ["data[.]businessAudit"]
      preprod     = ["data[.]businessAudit"]
      production  = ["data[.]businessAudit"]

    }

    s3only = {
      development = ["db[.]calculator[.]calculationParts"]
      qa          = ["db[.]calculator[.]calculationParts"]
      integration = ["db[.]calculator[.]calculationParts"]
      preprod     = ["db[.]calculator[.]calculationParts"]
      production  = ["db[.]calculator[.]calculationParts"]
    }
  }

  kafka_consumer_main_topic_exclusion_regex = {
    // Parses local.kafka_consumer_topics_dedicated for all topics per env
    //    flattens list of lists, joins with pipe before placing into regex.
    // effect: any topic added to `local.kafka_consumer_topics_dedicated` will also be added to the
    //    local.kafka_consumer_main_topic_exclusion_regex - and will not be processed by the "main-london" ASG
    for
    k, v in local.kafka_consumer_main_topics_regex :
    k => format("^(%s)$", join("|", flatten([for i in local.kafka_consumer_topics_dedicated : i[k]])))
  }

  kafka_consumer_hbase_bypass_topics_regex = {
    // Collections with HBase table names matching this pattern will not be written to HBase
    // *** must match hbase table name, not kafka topic *** //
    audit = {
      // audit collection should bypass hbase
      development = ""
      qa          = ""
      integration = "^(data:businessAudit)$"
      preprod     = "^(data:businessAudit)$"
      production  = "^(data:businessAudit)$"
    }

    main_dedicated = {
      development = ""
      qa          = ""
      integration = ""
      preprod     = ""
      production  = ""
    }

    s3only = {
      development = ""
      qa          = ""
      integration = ".*"
      preprod     = ".*"
      production  = ".*"
    }
  }

  kafka_consumer_main_dedicated_topics_regex = {
    // provides full regex for topic expressions listed above
    for env, topics in local.kafka_consumer_topics_dedicated.main_dedicated : env => format("^(%s)$", join("|", topics))
  }

  kafka_consumer_equality_topics_regex = {
    // provides full regex for topic expressions listed above
    for env, topics in local.kafka_consumer_topics_dedicated.equality : env => format("^(%s)$", join("|", topics))
  }

  kafka_consumer_audit_topics_regex = {
    // provides full regex for topic expressions listed above
    for env, topics in local.kafka_consumer_topics_dedicated.audit : env => format("^(%s)$", join("|", topics))
  }

  kafka_consumer_s3only_topics_regex = {
    // provides full regex for topic expressions listed above
    for env, topics in local.kafka_consumer_topics_dedicated.s3only : env => format("^(%s)$", join("|", topics))
  }
}
