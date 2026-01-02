local M = {}

function M.compose_up_service()
  -- Find docker-compose.yml in cwd
  local compose_file = vim.fn.findfile('docker-compose.yml', '.;')

  if compose_file == '' then
    vim.notify('docker-compose.yml not found', vim.log.levels.ERROR)
    return
  end

  local cmd =
    'awk \'/^services:/ { in_services=1; next } in_services && /^  [^[:space:]]+:/ { sub(/^  /, "", $0); sub(/:.*/, "", $0); print; next } in_services && /^[^[:space:]]/ { in_services=0 }\' docker-compose.yml'

  local services = vim.fn.systemlist(cmd)

  if vim.v.shell_error ~= 0 or #services == 0 then
    vim.notify('Failed to read services from docker-compose.yml', vim.log.levels.ERROR)
    return
  end

  -- Popup selector
  vim.ui.select(services, {
    prompt = 'docker compose up service:',
  }, function(choice)
    if not choice then
      return
    end

    -- Run docker compose up asynchronously
    local up_cmd = string.format('docker compose up %s', vim.fn.shellescape(choice))

    vim.notify('Running: ' .. up_cmd)
    vim.fn.jobstart(up_cmd, { detach = true })
  end)
end

return M
