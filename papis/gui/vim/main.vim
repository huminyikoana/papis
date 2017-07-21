let g:papis_help_key = "h"
let g:papis_open_key = "o"
let g:papis_open_dir_key = "<S-o>"
let g:papis_edit_key = "e"

let g:papis_next_key = "j"
let g:papis_prev_key = "k"

let g:papis_title_magic_word =  "Title :"
let g:papis_author_magic_word = "Author:"
let g:papis_year_magic_word =   "Year  :"
let g:papis_tags_magic_word =   "Tags  :"
let g:papis_document_separator = "^-------$"

" Environment variables that should have been set by papis
let g:papis_lib = $PAPIS_LIB
let g:papis_lib_path = $PAPIS_LIB_PATH
let g:papis_config_path = $PAPIS_CONFIG_PATH
let g:papis_config_file = $PAPIS_CONFIG_FILE
let g:papis_scripts_path = $PAPIS_SCRIPTS_PATH
let g:papis_verbose = $PAPIS_VERBOSE

" Set no modifiable
setlocal nomodifiable

syntax match Comment "^[^:]*:"
exe 'syntax region Statement start="'.g:papis_title_magic_word.'" contains=Comment end="$" keepend'
syntax match Number "[0-9]\+"
exe "syntax match Statement '".g:papis_document_separator."'"


"exe "syntax keyword papisMagicWord ".g:papis_title_magic_word
"highlight link papisMagicWord Number
"
function! PapisGetIdentifier()
    " This function returns a paper identifier for the current entry
    let current_line = getline(".")
    if current_line =~ g:papis_title_magic_word.".*"
        let title_line = current_line
    endif
    "let start = line(".")
    "let end = search(g:papis_document_separator)
    "echom getline(start, end)
    let title_line = substitute(
                \ title_line,
                \ g:papis_title_magic_word,
                \ "", ""
                \ )

    return title_line
endfunction

function! PapisExeCommand(cmd, ...)
    let title_line = PapisGetIdentifier()
    let command = ":!papis -l ".g:papis_lib." ".a:cmd." ".join(a:000)." '".title_line."'"
    exe command
endfunction

function! PapisHelp()
    echomsg "Help     - ".g:papis_help_key
    echomsg "Open     - ".g:papis_open_key
    echomsg "Open dir - ".g:papis_open_dir_key
    echomsg "Edit     - ".g:papis_edit_key
endfunction

function! PapisGo(direction)
  let back = "b"
  if a:direction == "next"
    let back = ""
  elseif a:direction == "bottom"
    exe ":normal! G"
  elseif a:direction == "half-down"
    exe ":normal! \<C-d>"
  elseif a:direction == "half-up"
    if 1 == line(".")
      return
    endif
    exe ":normal! \<C-u>"
  endif
  call cursor(search(g:papis_title_magic_word, back), 0)
  exe ":normal! zt"
endfunction

exec "nnoremap <buffer> ".g:papis_help_key." :call PapisHelp()<cr>"
exec "nnoremap <buffer> ".g:papis_open_key." :call PapisExeCommand('open')<cr>"
exec "nnoremap <buffer> <Return> :call PapisExeCommand('open')<cr>"
exec "nnoremap <buffer> ".g:papis_open_dir_key." :call PapisExeCommand('open', '--dir')<cr>"
exec "nnoremap <buffer> ".g:papis_edit_key." :call PapisExeCommand('edit')<cr>"

exec "nnoremap <buffer> ".g:papis_next_key." :call PapisGo('next')<cr>"
exec "nnoremap <buffer> ".g:papis_prev_key." :call PapisGo('prev')<cr>"
nmap <buffer> <Up> :call PapisGo('prev')<cr>
nmap <buffer> <Down> :call PapisGo('next')<cr>
nmap <buffer> <S-g> :call PapisGo("bottom")<cr>
nmap <buffer> <C-d> :call PapisGo("half-down")<cr>
nmap <buffer> <C-u> :call PapisGo("half-up")<cr>

nnoremap q :quit<cr>
command! -nargs=0 PapisHelp    call PapisHelp()
command! -nargs=0 PapisOpen    call PapisExeCommand("open")
command! -nargs=0 PapisOpenDir call PapisExeCommand("open", '--dir')
command! -nargs=0 PapisBrowse  call PapisExeCommand("browse")
command! -nargs=0 PapisEdit    call PapisExeCommand("edit")
