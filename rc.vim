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
		throw 'Error curl or wget is not available'
	endif

	exec '!'.cmd

	if (0 != v:shell_error)
		throw 'Error running cmd:$ '.cmd
	endif
endfunction

if exists('g:rc_url')
	" Download the URL
	call s:download_single_file(g:rc_url)

	" Execute the file
	if filereadable(s:filename) != 0
		exe 'source '.s:filename
	endif
endif
