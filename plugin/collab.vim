if !has('python')
  finish
endif

python << END_PYTHON
import sys
import vim
sys.path.append(vim.eval("expand('<sfile>:p:h')"))
from collab import Collab

Co = Collab()

def collab_update():
    content = "\n".join(vim.current.buffer[:])
    file = vim.eval("expand('%')")
    if not content and not file:
        return
    lang = vim.eval("&ft")
    file = file if file else "[No Name]"
    x = vim.current.window.cursor[1] + 1
    y = vim.current.window.cursor[0]
    Co.update(content, file, lang)
    Co.update_cursor(x, y, file)

END_PYTHON

function! s:collab_initialize(...)
  py Co.connect(*vim.eval("a:000"))
  augroup collab
    autocmd!
    autocmd CursorMoved * py collab_update()
    autocmd CursorMovedI * py collab_update()
    autocmd BufEnter * py collab_update()
  augroup END
endfunction

com! -nargs=* Collab call s:collab_initialize(<f-args>)
com! -nargs=1 CollabChangeNick py Co.change_nick(<f-args>)
com! -nargs=0 CollabDisconnect py Co.disconnect()
au VimLeave * :CollabDisconnect
