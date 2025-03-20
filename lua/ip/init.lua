local M = {}

M.replace_selection_with_ip = function()
  local s_buf = vim.api.nvim_get_current_buf()
  vim.cmd('normal! gv')
  local s_pos = vim.fn.getpos("'<")
  local e_pos = vim.fn.getpos("'>")

  local s_row, s_col = s_pos[2] - 1, s_pos[3] - 1
  local e_row, e_col = e_pos[2] - 1, e_pos[3]

  print("s_row:", s_row, "s_col:", s_col, "e_row:", e_row, "e_col:", e_col)

  -- Evitar errores en selección de una sola línea
  if s_row == e_row and s_col > e_col then
    s_col, e_col = e_col, s_col
  end

  -- Obtener la IP pública con curl
  local handle = io.popen("curl -s ifconfig.io")
  local ip_address = handle:read("*a"):gsub("\n", "")
  handle:close()

  -- Si no se puede obtener la IP, usar un mensaje por defecto
  if ip_address == "" then
    ip_address = "No IP found"
  end

  -- Reemplazar el texto seleccionado con la IP pública
  vim.api.nvim_buf_set_text(s_buf, s_row, s_col, e_row, e_col, { ip_address })

  -- Salir del modo visual
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "x", false)
end

-- Asignar la función a un atajo en modo visual (<leader><leader>ip para reemplazar selección con la IP)
M.setup = function()
  vim.keymap.set(
    "v",
    "<leader><leader>ip",
    M.replace_selection_with_ip,
    { noremap = true, silent = true, desc = "Replace selected text with public IP" }
  )
end

return M
