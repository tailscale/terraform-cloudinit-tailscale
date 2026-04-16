plugin "terraform" {
    enabled = true
    version = "0.5.0"
    source  = "github.com/terraform-linters/tflint-ruleset-terraform"
    preset  = "all"
}

rule "terraform_standard_module_structure" {
  enabled = false  # Fails on context.tf
}
