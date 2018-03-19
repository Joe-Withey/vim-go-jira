let s:home = getcwd()
let s:jira_dir = s:home . '/.jira.d'
let s:plugin_dir = s:jira_dir . '/vim-go-jira'

function! s:create_dir(path)
  if !isdirectory(a:path)
    call mkdir(a:path)
  endif
endfunction

function! s:write_file(lines, file)
  call writefile(a:lines, s:plugin_dir . '/' . a:file)
endfunction

function! s:create_plugin_dir()
  call s:create_dir(s:jira_dir)
  call s:create_dir(s:plugin_dir)
endfunction

function! s:select_issue_in_list()
  let l:line = getline('.')
  return matchstr(l:line, '^\([^-]\+-\d\+\)')
endfunction

function! s:transitions_to_key_values(key, transition)
  let l:key_value = split(a:transition, ': ')
  return [l:key_value[0], l:key_value[1]]
endfunction

function! vim_go_jira#transition_issue_in_list()
  let l:issue_nr = s:select_issue_in_list()
  let l:transitions = systemlist('jira transitions ' . l:issue_nr)
  call map(l:transitions, function('s:transitions_to_key_values'))
  let l:states = map(copy(l:transitions), {key, val -> (key + 1) . ': ' . val[1]})
  let l:selection_index = inputlist(['Enter key for transition:'] + l:states)
  
  if !empty(l:selection_index)
    let l:transition_id = l:transitions[l:selection_index - 1][0]
    let l:comment = input('Comment: ')
    " system('jira transition --noedit --comment="' . l:comment . '" ' . l:transition_id . ' ' l:issue_nr)
  else
    echomsg 'Cancelled transition'
  endif
endfunction

function! vim_go_jira#open_issue_in_list()
  let l:issue_nr = s:select_issue_in_list()
  if !empty(l:issue_nr)
    echomsg 'Retieving Issue...'
    let l:issue_content = systemlist('jira view ' . l:issue_nr)
    execute 'normal! P' 
    call s:write_file(l:issue_content, 'view_issue.yml')
    execute 'normal! p' 
    execute 'edit! ' . s:plugin_dir . '/view_issue.yml'
    setlocal buftype=nofile
    setlocal noma
  endif
endfunction

function! s:popen(file)
  execute 'pclose'
  execute 'pedit! ' . s:plugin_dir . '/' . a:file
  execute 'normal! t' 
  setlocal buftype=nofile
  setlocal noma 
  map <silent> <buffer> o :call vim_go_jira#open_issue_in_list()<CR>
  map <silent> <buffer> <CR> o
  map <silent> <buffer> t :call vim_go_jira#transition_issue_in_list()<CR>
  " autocmd BufWipeout or BufWinLeave <buffer> for clearing list
endfunction

call s:create_plugin_dir()

function! s:jira_list()
  echomsg 'Retrieving Issues...'
  let l:issues = systemlist('jira sprint')
  let l:lines = ['# JIRA LIST', ''] + l:issues
  call s:write_file(l:lines, 'list')
  call s:popen('list')
endfunction
command! JiraList call s:jira_list()
