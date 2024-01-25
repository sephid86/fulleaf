"-----플러그인설정
call plug#begin()
"-트리
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'
"-자동완성
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'dcampos/nvim-snippy'
Plug 'dcampos/cmp-snippy'
"-상태표시줄
Plug 'feline-nvim/feline.nvim'
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
"-git-signs
Plug 'lewis6991/gitsigns.nvim'
"-color schema
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
call plug#end()

"-----Lua 설정
"lua vim.g.loaded_netrw = 1
"lua vim.g.loaded_netrwPlugin = 1
lua vim.opt.termguicolors = true
lua require('nvim-tree').setup()
lua require('autocomplete')
lua require('feline').setup()
lua require('bufferline').setup()
lua require('gitsigns').setup()
lua require('catppuccin').setup({transparent_background=true})

"-----기본설정
colorscheme catppuccin " catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
set mouse=
set clipboard=unnamedplus
set tabstop=2
set shiftwidth=2
set softtabstop=2
set ts=2
set sw=2
set sts=2
set cursorline
set ignorecase
set smartcase

"-----키 맵핑
noremap <Tab> :bn!<CR>
noremap <S-Tab> :bp!<CR>
nnoremap <C-t> :NvimTreeToggle<CR>

"-----커서 마지막 위치로 이동
au BufReadPost *                                                                                                     
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\ exe "norm g`\"" |                                                             
\ endif
