
variable "cluster_name" {
  description = "The name to use for all the cluster resouses"
  type        = string

}

variable "db_remote_state_bucket" {
  description = "The name of s3 bucket for the database's remote state"
  type        = string

}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in s3 bucket"
  type        = string


}