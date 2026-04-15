variables {
  auth_key      = "tskey-auth-k0123456789abcdefghijklmnopqrstuv"
  base64_encode = false
  gzip          = false
}

run "default_rendering_preserves_direct_values_and_omits_relay_port" {
  command = plan

  assert {
    condition     = strcontains(output.rendered, "printf '%s' \"$value\"")
    error_message = "Expected resolve_value to preserve direct values exactly."
  }

  assert {
    condition     = !strcontains(output.rendered, "--relay-server-port=")
    error_message = "Expected relay_server_port to be omitted when unset."
  }
}

run "explicit_relay_port_is_rendered" {
  command = plan

  variables {
    relay_server_port = 7676
  }

  assert {
    condition     = strcontains(output.rendered, "--relay-server-port=\"7676\"")
    error_message = "Expected relay_server_port to be rendered when explicitly set."
  }
}

run "invalid_relay_port_is_rejected" {
  command = plan

  variables {
    relay_server_port = 65536
  }

  expect_failures = [var.relay_server_port]
}
