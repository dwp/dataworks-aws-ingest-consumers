variable "costcode" {
  type    = string
  default = ""
}

variable "assume_role" {
  type        = string
  default     = "ci"
  description = "IAM role assumed by Concourse when running Terraform"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "k2hb_version" {
  description = "Kafka to HBase JAR release version"
  type        = string
}

variable "al2_hardened_ami_id" {
  description = "The AMI ID of the latest/pinned Hardened AMI AL2 Image"
  type        = string
}

variable "k2hb_main_ec2_size" {
  default = {
    development = "t3.medium"
    qa          = "t3.medium"
    integration = "t3.medium"
    preprod     = "c5.xlarge"
    production  = "c5.xlarge"
  }
}

variable "k2hb_equality_ec2_size" {
  default = {
    development = "t3.medium"
    qa          = "t3.medium"
    integration = "t3.medium"
    preprod     = "c5.large"
    production  = "c5.large"
  }
}

variable "k2hb_audit_ec2_size" {
  default = {
    development = "t3.medium"
    qa          = "t3.medium"
    integration = "t3.medium"
    preprod     = "c5.xlarge"
    production  = "c5.xlarge"
  }
}

variable "k2hb_main_max_memory_allocation" {
  default = {
    development = "-Xmx1g"
    qa          = "-Xmx1g"
    integration = "-Xmx1g"
    preprod     = "-Xmx4g"
    production  = "-Xmx4g"
  }
}

variable "k2hb_equality_max_memory_allocation" {
  default = {
    development = "-Xmx1g"
    qa          = "-Xmx1g"
    integration = "-Xmx1g"
    preprod     = "-Xmx2g"
    production  = "-Xmx2g"
  }
}

variable "k2hb_audit_max_memory_allocation" {
  default = {
    development = "-Xmx1g"
    qa          = "-Xmx1g"
    integration = "-Xmx1g"
    preprod     = "-Xmx4g"
    production  = "-Xmx4g"
  }
}

variable "k2hb_main_london_asg_desired" {
  description = "Desired k2hb ha consumer asg size. UC Prod HA Cluster has 20 partitions, and we need spares. We can have at most 30 to fit in the subnets, as changes with create-before-destroy mean we need double headroom"
  default = {
    development = 2  //stubbed env
    qa          = 2  //stubbed env
    integration = 2  //stubbed env
    preprod     = 0  // Run ad-hoc when needed
    production  = 20
  }
}

variable "k2hb_main_london_asg_max" {
  description = "Max k2hb ha consumer asg size. UC Prod HA Cluster has 20 partitions, and we need spares. We can have at most 30 to fit in the subnets, as changes with create-before-destroy mean we need double headroom"
  default = {
    development = 2  //stubbed env
    qa          = 2  //stubbed env
    integration = 2  //stubbed env
    preprod     = 10
    production  = 20
  }
}

variable "k2hb_main_dedicated_london_asg_desired" {
  description = "Desired dedicated k2hb ha consumer asg size. UC Prod HA Cluster has 20 partitions, and we need spares. We can have at most 30 to fit in the subnets, as changes with create-before-destroy mean we need double headroom"
  default = {
    development = 1  //stubbed env
    qa          = 1  //stubbed env
    integration = 1  //stubbed env
    preprod     = 0  // Run ad-hoc when needed
    production  = 20
  }
}

variable "k2hb_main_dedicated_london_asg_max" {
  description = "Max dedicated k2hb ha consumer asg size. UC Prod HA Cluster has 20 partitions, and we need spares. We can have at most 30 to fit in the subnets, as changes with create-before-destroy mean we need double headroom"
  default = {
    development = 1  //stubbed env
    qa          = 1  //stubbed env
    integration = 1  //stubbed env
    preprod     = 20
    production  = 20
  }
}

variable "k2hb_equality_london_asg_desired" {
  description = "Desired k2hb equality asg size. Connects to ha cluster."
  default = {
    development = 1 //stubbed env
    qa          = 1 //stubbed env
    integration = 1 //stubbed env
    preprod     = 0 // Run ad-hoc when needed
    production  = 1
  }
}

variable "k2hb_equality_london_asg_max" {
  description = "Max k2hb equality asg size. Connects to ha cluster."
  default = {
    development = 1 //stubbed env
    qa          = 1 //stubbed env
    integration = 1 //stubbed env
    preprod     = 1
    production  = 1
  }
}

variable "k2hb_audit_london_asg_desired" {
  description = "Desired k2hb equality asg size. Connects to ha cluster."
  default = {
    development = 1  //stubbed env
    qa          = 1  //stubbed env
    integration = 1  //stubbed env
    preprod     = 0  // Run ad-hoc when needed
    production  = 20
  }
}

variable "k2hb_audit_london_asg_max" {
  description = "Max k2hb equality asg size. Connects to ha cluster."
  default = {
    development = 1  //stubbed env
    qa          = 1  //stubbed env
    integration = 1  //stubbed env
    preprod     = 20
    production  = 20
  }
}

variable "ecs_hardened_ami_id" {
  description = "The AMI ID of the latest/pinned Hardened AMI AL2 Image"
  type        = string
}

variable "image_version" {
  description = "Container tag values."
  default = {
    corporate-storage-coalescer = "0.0.36"
  }
}
