variable "instances" {
    type = list(object({
        name = string
        type = string
        ami = string
    }))
    description = "EC2 instances"
}
