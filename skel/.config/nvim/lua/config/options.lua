-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.title = true
vim.opt.relativenumber=false
vim.g.autoformat=false

vim.g.ts=2
vim.g.sw=2
vim.g.sts=2

vim.cmd("set fencs=ucs-bom,utf-8,default,euc-kr,cp949")

vim.opt.clipboard = "unnamedplus"
vim.opt.guicursor = ""
