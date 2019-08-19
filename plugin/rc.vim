" rc.vim: Vim plugin to download Vim configuration files externally
"
" Author: Thomas Versteeg <thomasversteeg at gmx.com>
" Version: 0.1
" HomePage: http://github.com/tversteeg/vim-rc
" Readme: http://github.com/tversteeg/vim-rc/blob/master/README.md
"
" This script downloads and loads Vim configuration files from URLs.

if exists('g:loaded_rc')
	finish
endif
let g:loaded_rc = 1

function! s:err(msg)
	echohl ErrorMsg
	echom '[vim-rc] '.a:msg
	echohl None
endfunction

function! s:trim(str)
	return substitute(a:str, '[\/]\+$', '', '')
endfunction

function! s:path(path)
	return s:trim(a:path)
endfunction

function! s:download_single_file(url, to)
	if executable('curl')
		let cmd = 'curl --fail -s -o '.shellescape(a:to).' '.shellescape(a:url)
	elseif executable('wget')
		let temp = shellescape(tempname())
		let cmd = 'wget -q -O '.temp.' '.shellescape(a:url).'  && mv -f '.temp.' '.shellescape(a:to)
		if (has('win32') || has('win64'))
			" Change force flag
			let cmd = substitute(cmd, 'mv -f ', 'mv /Y ')
			" Enclose in quotes so && joined cmds work
			let cmd = '"'.cmd.'"'
		end
	else
		return s:err('curl or wget is not available.')
	endif

	exec '!'.cmd

	if (0 != v:shell_error)
		return s:err('Error running cmd:$ '.cmd)
	endif
endfunction

function! s:set_home_directory()
	" Get the home directory
	if !empty(&rtp)
		let g:rc_home = s:path(split(&rtp, ',')[0]).'/rc'
	else
		return s:err('Unable to determine home path.')
	endif

	" Create the directory if it doesn't exist
	if !isdirectory(g:rc_home)
		try
			call mkdir(g:rc_home, 'p')
		catch
			return s:err(printf('Invalid rc directory: %s.', g:rc_home))
		endtry
	endif
endfunction

if exists('g:rc_url')
	call s:set_home_directory()

	let s:filename = g:rc_home.'/init.vim'

	" Download the URL
	call s:download_single_file(g:rc_url, s:filename)

	" Execute the file
	if filereadable(s:filename) != 0
		exe 'source '.s:filename
	endif
endif
