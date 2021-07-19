variable "route_string" {
	type = string
	default = "10.0.0.0/24,10.0.1.0/24"
}

variable "vpc_id" {
	type = string
}

variable "tskey" {
	type = string
	description = "Tailscale Authentication Key"
}