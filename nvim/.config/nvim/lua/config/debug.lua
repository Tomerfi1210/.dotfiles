local dap = require("dap")
local dapui = require("dapui")

vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DiagnosticError", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "L", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = ">", texthl = "DiagnosticOk", linehl = "Visual", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "X", texthl = "DiagnosticError", linehl = "", numhl = "" })

require("nvim-dap-virtual-text").setup({
	virt_text_pos = "eol",
})

dapui.setup({
	layouts = {
		{
			elements = {
				{ id = "scopes", size = 0.40 },
				{ id = "stacks", size = 0.30 },
				{ id = "breakpoints", size = 0.30 },
			},
			position = "right",
			size = 44,
		},
		{
			elements = {
				{ id = "repl", size = 0.50 },
				{ id = "console", size = 0.50 },
			},
			position = "bottom",
			size = 12,
		},
	},
	floating = {
		border = "rounded",
		mappings = { close = { "q", "<Esc>" } },
	},
})

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close({})
end

require("dap-go").setup({
	delve = {
		path = vim.fn.exepath("dlv") ~= "" and vim.fn.exepath("dlv") or "dlv",
	},
})

for index, config in ipairs(dap.configurations.go or {}) do
	if config.name == "Debug Package" then
		table.remove(dap.configurations.go, index)
		table.insert(dap.configurations.go, 1, config)
		break
	end
end

local debugpy = vim.fn.exepath("debugpy-adapter")
require("dap-python").setup(debugpy ~= "" and debugpy or "debugpy-adapter")

local function get_args(config)
	local args = type(config.args) == "function" and (config.args() or {}) or config.args or {}
	local args_string = type(args) == "table" and table.concat(args, " ") or args
	local copy = vim.deepcopy(config)

	copy.args = function()
		local input = vim.fn.input("Run with args: ", args_string)
		return require("dap.utils").splitstr(input)
	end

	return copy
end

vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug continue" })
vim.keymap.set("n", "<F17>", dap.continue, { desc = "Debug continue" })
vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug toggle breakpoint" })
vim.keymap.set("n", "<F21>", dap.toggle_breakpoint, { desc = "Debug toggle breakpoint" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug step over" })
vim.keymap.set("n", "<F22>", dap.step_over, { desc = "Debug step over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug step into" })
vim.keymap.set("n", "<F23>", dap.step_into, { desc = "Debug step into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug step out" })
vim.keymap.set("n", "<F24>", dap.step_out, { desc = "Debug step out" })
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional breakpoint" })
vim.keymap.set("n", "<leader>da", function()
	dap.continue({ before = get_args })
end, { desc = "Run with args" })
vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to cursor" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step out" })
vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Run last" })
vim.keymap.set("n", "<leader>dP", dap.pause, { desc = "Pause" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
vim.keymap.set("n", "<leader>du", function()
	dapui.toggle({})
end, { desc = "Toggle DAP UI" })
vim.keymap.set({ "n", "v" }, "<leader>de", dapui.eval, { desc = "Evaluate" })
