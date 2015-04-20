if ENV["ENABLE_FUTURE_POLICIES"]
  Whitehall.future_policies_enabled = true
else
  Whitehall.future_policies_enabled = false
end