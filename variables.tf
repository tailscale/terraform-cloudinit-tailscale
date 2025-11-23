variable "base64_encode" {
  description = "Whether to base64 encode the cloud-init data"
  type        = bool
  default     = true
}

variable "gzip" {
  description = "Whether to gzip the cloud-init data"
  type        = bool
  default     = false
}

variable "enable_ssh" {
  description = "Enable SSH access via Tailscale"
  type        = bool
  default     = false
}

variable "hostname" {
  description = "Hostname of the instance"
  type        = string
  default     = ""
}

variable "accept_dns" {
  description = "Accept DNS configuration from Tailscale"
  type        = bool
  default     = true
}

variable "accept_routes" {
  description = "Accept routes from Tailscale"
  type        = bool
  default     = false
}

variable "advertise_connector" {
  description = "Advertise this node as an app connector"
  type        = bool
  default     = false
}

variable "advertise_exit_node" {
  description = "Offer to be an exit node for internet traffic for the tailnet"
  type        = bool
  default     = false
}

variable "advertise_routes" {
  description = "Routes to advertise to other nodes"
  type        = list(string)
  default     = []
}

variable "advertise_tags" {
  description = "ACL tags to request; each must start with 'tag:' (e.g. 'tag:eng,tag:montreal,tag:ssh')"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.advertise_tags) == 0 || alltrue([for tag in var.advertise_tags : startswith(tag, "tag:")])
    error_message = "Each item in advertise_tags must start with 'tag:'."
  }
}

variable "auth_key" {
  description = "Node authorization key; if it begins with 'file:', then it's a path to a file containing the authkey"
  type        = string
  default     = ""
  sensitive   = true
}

variable "exit_node" {
  description = "Tailscale exit node (IP or base name) for internet traffic"
  type        = string
  default     = ""
}

variable "exit_node_allow_lan_access" {
  description = "Allow direct access to the local network when routing traffic via an exit node"
  type        = bool
  default     = false
}

variable "force_reauth" {
  description = "force reauthentication"
  type        = bool
  default     = false
}

variable "json" {
  description = "output in JSON format"
  type        = bool
  default     = false
}

variable "login_server" {
  description = "base URL of control server"
  type        = string
  default     = "https://controlplane.tailscale.com"
}

variable "operator" {
  description = "Unix username to allow to operate on tailscaled without sudo"
  type        = string
  default     = ""
}

variable "reset" {
  description = "reset unspecified settings to their default values"
  type        = bool
  default     = false
}

variable "shields_up" {
  description = "don't allow incoming connections"
  type        = bool
  default     = false
}

variable "timeout" {
  description = "maximum amount of time to wait for tailscaled to enter a Running state"
  type        = string
  default     = "0s"
}

variable "netfilter_mode" {
  description = "netfilter mode"
  type        = string
  default     = "on"

  validation {
    condition     = contains(["on", "nodivert", "off"], var.netfilter_mode)
    error_message = "Allowed values for netfilter_mode are \"on\", \"nodivert\", or \"off\"."
  }
}

variable "snat_subnet_routes" {
  description = "source NAT traffic to local routes advertised with --advertise-routes"
  type        = bool
  default     = true
}

variable "stateful_filtering" {
  description = "apply stateful filtering to forwarded packets"
  type        = bool
  default     = false
}

variable "max_retries" {
  description = "maximum number of retries to connect to the control server"
  type        = number
  default     = 3
}

variable "retry_delay" {
  description = "delay in seconds between retries to connect to the control server"
  type        = number
  default     = 5
}

variable "additional_parts" {
  description = "Additional user defined part blocks for the cloudinit_config data source"
  type = list(object({
    filename     = string
    content_type = optional(string)
    content      = optional(string)
    merge_type   = optional(string)
  }))
  default = []
}

variable "track" {
  description = "Version of the Tailscale client to install"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["stable", "unstable"], var.track)
    error_message = "Allowed values for track are \"stable\", \"unstable\""
  }
}

variable "relay_server_port" {
  description = "Port for the Tailscale relay server"
  type        = number
  default     = 7878
}

variable "tailscaled_flag_bird_socket" {
  description = "path of the bird unix socket"
  type        = string
  default     = ""
}

variable "tailscaled_flag_config" {
  description = "path to config file, or 'vm:user-data' to use the VM's user-data (EC2)"
  type        = string
  default     = ""
}

variable "tailscaled_flag_debug" {
  description = "listen address ([ip]:port) of optional debug server"
  type        = string
  default     = ""
}

variable "tailscaled_flag_encrypt_state" {
  description = "encrypt the state file on disk; uses TPM on Linux and Windows"
  type        = bool
  default     = false
}

variable "tailscaled_flag_no_logs_no_support" {
  description = "disable log uploads; this also disables any technical support"
  type        = bool
  default     = false
}

variable "tailscaled_flag_outbound_http_proxy_listen" {
  description = "optional [ip]:port to run an outbound HTTP proxy (e.g. \"localhost:8080\")"
  type        = string
  default     = ""
}

variable "tailscaled_flag_port" {
  description = "UDP port to listen on for WireGuard and peer-to-peer traffic; 0 means automatically select"
  type        = number
  default     = 41641
}

variable "tailscaled_flag_socket" {
  description = "path of the service unix socket"
  type        = string
  default     = "/run/tailscale/tailscaled.sock"
}

variable "tailscaled_flag_socks5_server" {
  description = "optional [ip]:port to run a SOCK5 server (e.g. \"localhost:1080\")"
  type        = string
  default     = ""
}

variable "tailscaled_flag_state" {
  description = "absolute path of state file; use 'kube:<secret-name>' to use Kubernetes secrets or 'arn:aws:ssm:...' to store in AWS SSM; use 'mem:' to not store state and register as an ephemeral node"
  type        = string
  default     = ""
}

variable "tailscaled_flag_statedir" {
  description = "path to directory for storage of config state, TLS certs, temporary incoming Taildrop files, etc."
  type        = string
  default     = "/var/lib/tailscale/tailscaled.state"
}

variable "tailscaled_flag_tun" {
  description = "tunnel interface name; use \"userspace-networking\" (beta) to not use TUN"
  type        = string
  default     = ""
}

variable "tailscaled_flag_verbose" {
  description = "log verbosity level; 0 is default, 1 or higher are increasingly verbose"
  type        = number
  default     = 0
}

variable "id_token" {
  description = "ID token from the identity provider to exchange with the control server for workload identity federation; if it begins with \"file:\", then it's a path to a file containing the token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "client_id" {
  description = "Client ID used to generate authkeys via workload identity federation"
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "Client Secret used to generate authkeys via OAuth; if it begins with \"file:\", then it's a path to a file containing the secret"
  type        = string
  default     = ""
  sensitive   = true
}
