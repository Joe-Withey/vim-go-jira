let s:home = getcwd()
let s:jira_dir = s:home . '/.jira.d'
let s:plugin_dir = s:jira_dir . '/vim-go-jira'

function! s:create_dir(path)
    if !isdirectory(a:path)
        call mkdir(a:path)
    endif
endfunction

function! s:create_file(file)
    call writefile([], s:plugin_dir . '/' . a:file)
endfunction

function! s:write_file(lines, file)
    call writefile(a:lines, s:plugin_dir . '/' . a:file)
endfunction

function! s:create_plugin_dir()
    call s:create_dir(s:jira_dir)
    call s:create_dir(s:plugin_dir)
    call s:create_file('list')
endfunction

function! s:popen(file)
    execute 'pedit ' . s:plugin_dir . '/' . a:file
    execute 'normal! W' 
    execute 'set noma' 
endfunction

call s:create_plugin_dir()

function! s:jira_list()
    let l:lines = ['# JIRA LIST', '', "\t[LAN-137466] Map messages to ID's"]
    call s:write_file(l:lines, 'list')
    call s:popen('list')
endfunction

command! JiraList call s:jira_list()
