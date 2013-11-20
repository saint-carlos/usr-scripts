function! s:GitDiffCommon(Ignore)
    let opt = a:Ignore
    if &diffopt =~ "icase"
        let opt = opt . "-i "
    endif
    if &diffopt =~ "iwhite"
        let opt = opt . "-b "
    endif
    silent execute "!diff -a --binary " . opt . v:fname_in . " " . v:fname_new .
                \  " > " . v:fname_out
endfunction

function GitDiffLog()
    call s:GitDiffCommon("-I '^commit' ")
endfunction

function GitDiffDiff()
    let opt = "-I '^index ' -I '^@@ ' -I '^ ' "
    call s:GitDiffCommon(opt)
endfunction
