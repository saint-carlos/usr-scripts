" Vim syntax file
" Language:	Quoted Unified Diff - for emails.
" Maintainer:	solo <solo@tonian.com>
" Last Change:	2012 oct 07

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match diffOnly	"^Only in .*"
syn match diffIdentical	"^Files .* and .* are identical$"
syn match diffDiffer	"^Files .* and .* differ$"
syn match diffBDiffer	"^Binary files .* and .* differ$"
syn match diffIsA	"^File .* is a .* while file .* is a .*"
syn match diffNoEOL	"^No newline at end of file .*"
syn match diffCommon	"^Common subdirectories: .*"

syn match diffRemoved	"^>\+ -.*"
syn match diffAdded	"^>\+ +.*"
syn match diffContext	"^>\+\(\|  .*\| --\| \d\.\d\.\d\.\d\)$"

syn match diffLine	"^>\+ @@ -\d\+,\d\+ +\d\+,\d\+ @@.*"

syn match diffHeader	"^>\+ diff --git.*"
syn match diffNewFile	"^+++ .*"
syn match diffHeader	"^>\+ index \x\+\.\.\x\+.*$"
syn match diffOnly	"^Component: .*$"
syn match diffFile	"^==== .*$"
syn match diffOldFile	"^>\+ --- .*"
syn match diffNewFile	"^>\+ +++ .*"

syn match diffComment	"^#.*"

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_qdiff_syntax_inits")
  if version < 508
    let did_qdiff_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink diffHeader	Statement
  HiLink diffOldFile	Statement
  HiLink diffNewFile	Statement
  HiLink diffFile	Identifier
  HiLink diffOnly	Constant
  HiLink diffIdentical	Constant
  HiLink diffDiffer	Constant
  HiLink diffBDiffer	Constant
  HiLink diffIsA	Constant
  HiLink diffNoEOL	Constant
  HiLink diffCommon	Constant
  HiLink diffRemoved	Special
  HiLink diffChanged	Identifier
  HiLink diffAdded	Type
  HiLink diffContext	Comment
  HiLink diffLine	PreProc
  HiLink diffSubname	Identifier
  HiLink diffComment	Comment

  delcommand HiLink
endif

let b:current_syntax = "qdiff"

" vim: ts=8 sw=2
