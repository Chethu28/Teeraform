# Setting Environment Variable:

```
export VARIABLE_NAME=value
```
# Using in Terraform:

```
variable "variable_name" {
  description = "Description of the variable"
  type        = string
  default     = getenv("VARIABLE_NAME")
}

resource "example_resource" "example" {
  example_property = var.variable_name
}

```

# using it in directly in tf file

```
resource "example_resource" "example" {
  example_property = getenv("VARIABLE_NAME")
}
```
