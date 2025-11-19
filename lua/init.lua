local M = {}

-- Función auxiliar para normalizar rangos
local function normalize_range(s_row, s_col, e_row, e_col)
	if s_row > e_row or (s_row == e_row and s_col > e_col) then
		return e_row, e_col, s_row, s_col
	end
	return s_row, s_col, e_row, e_col
end

M.replace_selection_with_ip = function()
	local s_buf = vim.api.nvim_get_current_buf()

	-- Activar la selección visual
	-- Asegurar que la selección está sincronizada
	vim.cmd("normal! v") -- Forzar entrada a modo visual
	vim.cmd("normal! gv") -- Sincronización tras vt/
	local s_pos = vim.fn.getpos("'<")
	local e_pos = vim.fn.getpos("'>")
	local s_row, s_col = s_pos[2] - 1, s_pos[3] - 1
	local e_row, e_col = e_pos[2] - 1, e_pos[3]

	-- Comprobar si las posiciones son válidas
	if s_row < 0 or e_row < 0 then
		vim.api.nvim_err_writeln("Invalid selection")
		return
	end

	-- Normalizar rangos
	s_row, s_col, e_row, e_col = normalize_range(s_row, s_col, e_row, e_col)
	print("s_row:", s_row, "s_col:", s_col, "e_row:", e_row, "e_col:", e_col)

	-- Obtener la IP pública con curl
	local handle = io.popen("curl -s ifconfig.io")
	local ip_address = handle:read("*a"):gsub("\n", "")
	handle:close()

	if ip_address == "" then
		ip_address = "No IP found"
	end

	-- Reemplazar el texto seleccionado con la IP
	vim.api.nvim_buf_set_text(s_buf, s_row, s_col, e_row, e_col, { ip_address })
	-- Mover el cursor de vuelta al inicio de la selección
	vim.api.nvim_win_set_cursor(0, { s_row + 1, s_col })
	-- Salir del modo visual
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "x", false)
end

-- Asignar la función a un atajo en modo visual
M.setup = function()
	vim.keymap.set(
		"v",
		"<leader><leader>ip",
		M.replace_selection_with_ip,
		{ noremap = true, silent = true, desc = "Replace selected text with public IP" }
	)
end

return M
