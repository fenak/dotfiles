" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if has('vim_starting')
  set nocompatible               " Be iMproved
  
  " required!
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" required!
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" required!
NeoBundleFetch 'Shougo/neobundle.vim'

" bundles
" github
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'ap/vim-css-color'
NeoBundle 'bling/vim-airline'
NeoBundle 'cespare/vim-toml'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'jlanzarotta/bufexplorer'
NeoBundle 'jgdavey/tslime.vim'
NeoBundle 'jnwhiteh/vim-golang'
NeoBundle 'justincampbell/vim-eighties'
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'quanganhdo/grb256'
NeoBundle 'thoughtbot/vim-rspec'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-haml'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-rails'
NeoBundle 'rking/ag.vim'
NeoBundle 'rust-lang/rust.vim'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'slim-template/vim-slim'

call neobundle#end()

" required!
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck

set fileencoding=utf-8
set encoding=utf-8

" general config
let mapleader=","
set autoread
set laststatus=2
set backupdir=/tmp
set directory=/tmp
set shell=zsh
set mouse=a
set backspace=indent,eol,start
set scrolloff=3
syntax on
autocmd CursorHold * checktime " hack for autoread

" terminal colors
set t_Co=256

" indentation
set autoindent

" white space blamer
set list
set listchars=tab:\ ¬,trail:.

" interface
set background=dark
set go-=T
set go-=L
set go-=r
set go-=m
set number

" status line
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" colorscheme
colorscheme grb256

" for ruby, autoindent with two spaces, always expand tabs
autocmd FileType ruby,yaml,cucumber set ai sw=2 sts=2 et
autocmd FileType eruby,html,javascript,scss,haml set sw=2 ts=2 sts=2 et
autocmd FileType c,python,haskell set sw=4 sts=4 et
autocmd FileType make set ai sw=4 ts=4 sts=4 noet

" mappings
nnoremap <C-J> <C-w>j<C-w>_
nnoremap <C-K> <C-w>k<C-w>_
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
map <F2> :NERDTreeToggle<CR>
nnoremap <leader><space> :noh<cr>
nnoremap <leader>a :Ag<space>
nnoremap <leader>w <C-w><C-v>
map <Leader>t :call RunCurrentSpecFile()<cr>
map <Leader>s :call RunNearestSpec()<cr>
map <Leader>l :call RunLastSpec()<cr>
map <Leader>A :call RunAllSpecs()<cr>
nnoremap <leader><leader> :CtrlP<cr>
nnoremap Q <nop>
nmap <C-c>r <Plug>SetTmuxVars
imap <c-l> <space>=><space>

let g:airline_powerline_fonts = 1
let g:rspec_command = 'call Send_to_Tmux(RspecCommand() . " {spec}\n")'

let g:eighties_enabled = 1
let g:eighties_minimum_width = 80
let g:eighties_extra_width = 60 " Increase this if you want some extra room
let g:eighties_compute = 1 " Disable this if you just want the minimum + extra
let g:eighties_bufname_additional_patterns = ['fugitiveblame'] " Defaults to [], 'fugitiveblame' is only an example. Takes a comma delimited list of bufnames as strings.

function! RspecCommand()
  if !empty(glob("bin/rspec"))
    return "bin/rspec"
  else
    return "bundle exec rspec"
  endif
endfunction

" got from garybernhardt/dotfiles
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" RENAME CURRENT FILE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <leader>n :call RenameFile()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" EXTRACT VARIABLE (SKETCHY)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! ExtractVariable()
    let name = input("Variable name: ")
    if name == ''
        return
    endif
    " Enter visual mode (not sure why this is needed since we're already in
    " visual mode anyway)
    normal! gv

    " Replace selected text with the variable name
    exec "normal c" . name
    " Define the variable on the line above
    exec "normal! O" . name . " = "
    " Paste the original selected text to be the variable value
    normal! $p
endfunction
vnoremap <leader>rv :call ExtractVariable()<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" INLINE VARIABLE (SKETCHY)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InlineVariable()
    " Copy the variable under the cursor into the 'a' register
    :let l:tmp_a = @a
    :normal "ayiw
    " Delete variable and equals sign
    :normal 2daW
    " Delete the expression into the 'b' register
    :let l:tmp_b = @b
    :normal "bd$
    " Delete the remnants of the line
    :normal dd
    " Go to the end of the previous line so we can start our search for the
    " usage of the variable to replace. Doing '0' instead of 'k$' doesn't
    " work; I'm not sure why.
    normal k$
    " Find the next occurence of the variable
    exec '/\<' . @a . '\>'
    " Replace that occurence with the text we yanked
    exec ':.s/\<' . @a . '\>/' . @b
    :let @a = l:tmp_a
    :let @b = l:tmp_b
endfunction
nnoremap <leader>ri :call InlineVariable()<cr>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SWITCH BETWEEN TEST AND PRODUCTION CODE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! OpenTestAlternate()
  let new_file = AlternateForCurrentFile()
  exec ':e ' . new_file
endfunction
function! AlternateForCurrentFile()
  let current_file = expand("%")
  let new_file = current_file
  let in_spec = match(current_file, '^spec/') != -1
  let going_to_spec = !in_spec
  let in_app = match(current_file, '\<controllers\>') != -1 || match(current_file, '\<models\>') != -1 || match(current_file, '\<views\>') != -1 || match(current_file, '\<helpers\>') != -1
  if going_to_spec
    if in_app
      let new_file = substitute(new_file, '^app/', '', '')
    end
    let new_file = substitute(new_file, '\.e\?rb$', '_spec.rb', '')
    let new_file = 'spec/' . new_file
  else
    let new_file = substitute(new_file, '_spec\.rb$', '.rb', '')
    let new_file = substitute(new_file, '^spec/', '', '')
    if in_app
      let new_file = 'app/' . new_file
    end
  endif
  return new_file
endfunction
nnoremap <leader>. :call OpenTestAlternate()<cr>
