variable "route_string" {
	type = string
	default = "10.0.0.0/24,10.0.1.0/24"
}

variable "tskey" {
	type = string
	desdescription = "Tailscale Authentication Key"	
}

variable "subnet_id" {
	type = string
}

variable "secgroup_id" {
	type = string
}