variable "region" {
  default = "ap-south-1"
}

variable "key_name" {
  description = "AWS Key Pair name created from console or CLI"
  default     = "kedar-key" # or whatever name you gave
}
