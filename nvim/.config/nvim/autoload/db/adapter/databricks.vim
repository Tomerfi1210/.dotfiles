" vim-dadbod adapter for Databricks SQL via the Databricks CLI.
"
" URL format:
"   databricks:<warehouse-id>?profile=DEFAULT&catalog=samples&schema=tpch
"
" URL pieces may be omitted and read from the environment:
"   DATABRICKS_SQL_WAREHOUSE_ID
"   DATABRICKS_CONFIG_PROFILE or DATABRICKS_PROFILE
"   DATABRICKS_CATALOG
"   DATABRICKS_SCHEMA
"
" Do not put Databricks tokens or other secrets in URLs or files.

let s:save_cpo = &cpo
set cpo&vim

function! s:url_decode(value) abort
  let l:value = substitute(a:value, '+', ' ', 'g')
  return substitute(l:value, '%\(\x\x\)', '\=nr2char(str2nr(submatch(1), 16))', 'g')
endfunction

function! s:parse_url(url) abort
  let l:raw = substitute(a:url, '^databricks:', '', '')
  let l:parts = split(l:raw, '?', 1)
  let l:opts = {}

  if !empty(l:parts[0])
    let l:opts.warehouse_id = s:url_decode(l:parts[0])
  endif

  if len(l:parts) > 1
    for l:item in split(l:parts[1], '&')
      if empty(l:item)
        continue
      endif
      let l:pair = split(l:item, '=', 1)
      let l:key = s:url_decode(l:pair[0])
      let l:value = len(l:pair) > 1 ? s:url_decode(l:pair[1]) : ''
      let l:opts[l:key] = l:value
    endfor
  endif

  if empty(get(l:opts, 'warehouse_id', ''))
    let l:opts.warehouse_id = $DATABRICKS_SQL_WAREHOUSE_ID
  endif
  if empty(get(l:opts, 'profile', ''))
    let l:opts.profile = !empty($DATABRICKS_CONFIG_PROFILE) ? $DATABRICKS_CONFIG_PROFILE : $DATABRICKS_PROFILE
  endif
  if empty(get(l:opts, 'catalog', ''))
    let l:opts.catalog = $DATABRICKS_CATALOG
  endif
  if empty(get(l:opts, 'schema', ''))
    let l:opts.schema = $DATABRICKS_SCHEMA
  endif

  return l:opts
endfunction

function! s:runner() abort
  let l:from_adapter = fnamemodify(expand('<sfile>:p'), ':h:h:h:h') . '/scripts/dadbod-databricks'
  if executable(l:from_adapter)
    return l:from_adapter
  endif

  for l:path in split(globpath(&runtimepath, 'scripts/dadbod-databricks'), "\n")
    if executable(l:path)
      return l:path
    endif
  endfor

  return 'dadbod-databricks'
endfunction

function! s:command(url, ...) abort
  let l:opts = s:parse_url(a:url)
  let l:cmd = [s:runner()]

  if empty(get(l:opts, 'warehouse_id', ''))
    throw 'dadbod-databricks: missing warehouse id; set it in the URL or DATABRICKS_SQL_WAREHOUSE_ID'
  endif

  call extend(l:cmd, ['--warehouse-id', l:opts.warehouse_id])
  for l:key in ['profile', 'catalog', 'schema']
    if !empty(get(l:opts, l:key, ''))
      call extend(l:cmd, ['--' . l:key, l:opts[l:key]])
    endif
  endfor

  if a:0 && !empty(a:1)
    call extend(l:cmd, ['--file', a:1])
  endif

  return l:cmd
endfunction

function! s:sql_string(value) abort
  return "'" . substitute(a:value, "'", "''", 'g') . "'"
endfunction

function! db#adapter#databricks#interactive(url) abort
  return s:command(a:url)
endfunction

function! db#adapter#databricks#filter(url) abort
  return s:command(a:url)
endfunction

function! db#adapter#databricks#input(url, infile) abort
  return s:command(a:url, a:infile)
endfunction

function! db#adapter#databricks#input_extension() abort
  return 'sql'
endfunction

function! db#adapter#databricks#auth_input() abort
  return v:false
endfunction

function! db#adapter#databricks#massage(input) abort
  let l:sql = a:input
  if l:sql =~# '\S' && l:sql !~# ';\s*$'
    let l:sql .= ';'
  endif
  return l:sql
endfunction

function! db#adapter#databricks#tables(url) abort
  let l:opts = s:parse_url(a:url)
  let l:where = ["table_schema <> 'information_schema'", "table_catalog <> '__databricks_internal'"]

  if !empty(get(l:opts, 'catalog', ''))
    call add(l:where, 'table_catalog = ' . s:sql_string(l:opts.catalog))
  endif
  if !empty(get(l:opts, 'schema', ''))
    call add(l:where, 'table_schema = ' . s:sql_string(l:opts.schema))
  endif

  let l:sql = 'SELECT table_catalog, table_schema, table_name FROM system.information_schema.tables WHERE ' . join(l:where, ' AND ') . ' ORDER BY table_catalog, table_schema, table_name'
  let l:cmd = s:command(a:url)
  call add(l:cmd, '--raw')
  let l:rows = systemlist(l:cmd, l:sql)
  if v:shell_error
    return []
  endif

  let l:tables = []
  let l:catalog_pinned = !empty(get(l:opts, 'catalog', ''))
  let l:schema_pinned = !empty(get(l:opts, 'schema', ''))
  for l:row in l:rows[1:]
    let l:cols = split(l:row, "\t", 1)
    if len(l:cols) < 3 || empty(l:cols[2])
      continue
    endif
    if l:catalog_pinned && l:schema_pinned
      call add(l:tables, l:cols[2])
    elseif l:catalog_pinned
      call add(l:tables, l:cols[1] . '.' . l:cols[2])
    else
      call add(l:tables, l:cols[0] . '.' . l:cols[1] . '.' . l:cols[2])
    endif
  endfor
  return l:tables
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
