local function url_encode(value)
  return tostring(value):gsub("([^%w%-%._~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end)
end

local function databricks_url()
  local warehouse_id = vim.env.DATABRICKS_SQL_WAREHOUSE_ID
  if not warehouse_id or warehouse_id == "" then
    return nil
  end

  local query = {}
  local profile = vim.env.DATABRICKS_CONFIG_PROFILE or vim.env.DATABRICKS_PROFILE
  if profile and profile ~= "" then
    table.insert(query, "profile=" .. url_encode(profile))
  end
  if vim.env.DATABRICKS_CATALOG and vim.env.DATABRICKS_CATALOG ~= "" then
    table.insert(query, "catalog=" .. url_encode(vim.env.DATABRICKS_CATALOG))
  end
  if vim.env.DATABRICKS_SCHEMA and vim.env.DATABRICKS_SCHEMA ~= "" then
    table.insert(query, "schema=" .. url_encode(vim.env.DATABRICKS_SCHEMA))
  end

  local url = "databricks:" .. url_encode(warehouse_id)
  if #query > 0 then
    url = url .. "?" .. table.concat(query, "&")
  end
  return url
end

local function setup_databricks()
  local databricks_connection = databricks_url()
  if databricks_connection then
    local dbs = type(vim.g.dbs) == "table" and vim.g.dbs or {}
    if dbs.Databricks == nil then
      dbs.Databricks = databricks_connection
    end
    vim.g.dbs = dbs
  end

  local table_helpers = type(vim.g.db_ui_table_helpers) == "table" and vim.g.db_ui_table_helpers or {}
  table_helpers.databricks = table_helpers.databricks
    or table_helpers.Databricks
    or {
      List = "SELECT * FROM {table} LIMIT 200",
      Columns = "DESCRIBE TABLE {table}",
    }
  vim.g.db_ui_table_helpers = table_helpers
end

return {
  {
    "kristijanhusak/vim-dadbod-ui",
    optional = true,
    keys = {
      { "<leader>rq", "<Plug>(DBUI_ExecuteQuery)", mode = { "n", "v" }, desc = "Run Query" },
    },
    init = function()
      vim.g.db_ui_save_location = vim.fn.stdpath("config") .. "/db_ui"
      setup_databricks()
    end,
  },
}
