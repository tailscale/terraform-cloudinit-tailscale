locals {
  # Validate that either auth_key or workload identity credentials are provided
  has_auth_key          = var.auth_key != ""
  has_workload_identity = var.id_token != "" && (var.client_id != "" || var.client_secret != "")
  has_workload_identity_audience = var.audience != "" && var.client_id != ""
  has_valid_auth        = local.has_auth_key || local.has_workload_identity || local.has_workload_identity_audience
}

data "cloudinit_config" "main" {
  gzip          = var.gzip
  base64_encode = var.base64_encode

  lifecycle {
    precondition {
      condition     = local.has_valid_auth
      error_message = "Either auth_key must be provided, or id_token with at least one of client_id or client_secret, or audience with client_id must be provided for workload identity federation."
    }
  }

  part {
    filename     = "ip_forwarding.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/files/ip_forwarding.sh")
  }

  part {
    filename     = "udp_offloads.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/files/udp_offloads.sh")
  }

  part {
    filename     = "install_tailscale.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/install_tailscale.sh.tmpl", {
      TRACK       = var.track
      MAX_RETRIES = var.max_retries
      RETRY_DELAY = var.retry_delay
    })
  }

  part {
    filename     = "configure_tailscaled.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/configure_tailscaled.sh.tmpl", {
      TAILSCALED_FLAG_BIRD_SOCKET                = var.tailscaled_flag_bird_socket
      TAILSCALED_FLAG_CONFIG                     = var.tailscaled_flag_config
      TAILSCALED_FLAG_DEBUG                      = var.tailscaled_flag_debug
      TAILSCALED_FLAG_ENCRYPT_STATE              = var.tailscaled_flag_encrypt_state
      TAILSCALED_FLAG_NO_LOGS_NO_SUPPORT         = var.tailscaled_flag_no_logs_no_support
      TAILSCALED_FLAG_OUTBOUND_HTTP_PROXY_LISTEN = var.tailscaled_flag_outbound_http_proxy_listen
      TAILSCALED_FLAG_PORT                       = var.tailscaled_flag_port
      TAILSCALED_FLAG_SOCKET                     = var.tailscaled_flag_socket
      TAILSCALED_FLAG_SOCKS5_SERVER              = var.tailscaled_flag_socks5_server
      TAILSCALED_FLAG_STATE                      = var.tailscaled_flag_state
      TAILSCALED_FLAG_STATEDIR                   = var.tailscaled_flag_statedir
      TAILSCALED_FLAG_TUN                        = var.tailscaled_flag_tun
      TAILSCALED_FLAG_VERBOSE                    = var.tailscaled_flag_verbose
    })
  }

  part {
    filename     = "setup_tailscale.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/setup_tailscale.sh.tmpl", {
      ADVERTISE_ROUTES           = join(",", var.advertise_routes)
      ADVERTISE_TAGS             = join(",", var.advertise_tags)
      ACCEPT_DNS                 = var.accept_dns
      ACCEPT_ROUTES              = var.accept_routes
      ADVERTISE_CONNECTOR        = var.advertise_connector
      ADVERTISE_EXIT_NODE        = var.advertise_exit_node
      HOSTNAME                   = var.hostname
      TAILSCALE_SSH              = var.enable_ssh
      AUTH_KEY                   = sensitive(var.auth_key)
      EXIT_NODE                  = var.exit_node
      EXIT_NODE_ALLOW_LAN_ACCESS = var.exit_node_allow_lan_access
      FORCE_REAUTH               = var.force_reauth
      JSON                       = var.json
      LOGIN_SERVER               = var.login_server
      OPERATOR                   = var.operator
      RESET                      = var.reset
      SHIELDS_UP                 = var.shields_up
      TIMEOUT                    = var.timeout
      SNAT_SUBNET_ROUTES         = var.snat_subnet_routes
      NETFILTER_MODE             = var.netfilter_mode
      STATEFUL_FILTERING         = var.stateful_filtering
      MAX_RETRIES                = var.max_retries
      RETRY_DELAY                = var.retry_delay
      RELAY_SERVER_PORT          = var.relay_server_port
      ID_TOKEN                   = sensitive(var.id_token)
      CLIENT_ID                  = var.client_id
      CLIENT_SECRET              = sensitive(var.client_secret)
      AUDIENCE                   = var.audience
    })
  }

  dynamic "part" {
    for_each = var.additional_parts
    content {
      filename     = part.value.filename
      content_type = part.value.content_type
      content      = part.value.content
    }
  }
}
