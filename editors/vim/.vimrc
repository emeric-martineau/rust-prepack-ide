"----------------------------------[ general config ]---------------------------
"enable mouse support
set mouse=a

"check file change every 4 seconds ('CursorHold') and reload the buffer upon detecting change
set autoread
au CursorHold * checktime

"convert tabs to 4 spaces
set tabstop=4
"shift/indent also to 4 spaces
set shiftwidth=4
"auto indent (pressing enter, will indent)
set ai

"global clipboard for copy pasting between terminals
set clipboard=unnamedplus

"to hide the default mode (INSERT, NORMAL, etc)
set noshowmode

" get rid of the `|` in the window splits (signifcant whitespace after \ )
set fillchars+=vert:\
"-------------------------------------------------------------------------------
