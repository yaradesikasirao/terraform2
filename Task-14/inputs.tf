variable "region" {
  type = string
  default = "us-east-2"
}

variable "zones" {
  type = list(string)
  default = ["a","b"]

}