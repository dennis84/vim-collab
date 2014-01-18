if !has('python')
  finish
endif

com! -nargs=* Collab py Co.connect(<f-args>)
com! -nargs=0 CollabDisconnect py Co.disconnect()

au VimLeave * :CollabDisconnect

python << EOF

import vim
import json
import uuid
import websocket
import threading

class Connection(threading.Thread):
  def __init__(self, ws):
    threading.Thread.__init__(self)
    self.ws = ws

  def run(self):
    self.ws.run_forever()

class Collab:
  def __init__(self):
    self.current_buffer = vim.current.buffer[:]

  def on_open(self, message):
    print 'Joined: ' + self.room

  def connect(self, room=False):
    if room == False:
      self.room = str(uuid.uuid4()).split('-')[-1]
    else:
      self.room = room

    self.ws = websocket.WebSocketApp(
      'wss://polar-woodland-4270.herokuapp.com/' + self.room,
      on_open = self.on_open)

    self.co = Connection(self.ws)
    self.co.start()

    vim.command('autocmd CursorMoved * py Co.update()')
    vim.command('autocmd CursorMovedI * py Co.update()')

  def disconnect(self):
    self.ws.close()

  def update(self):
    next_buffer = vim.current.buffer[:]
    if next_buffer != self.current_buffer:
      self.current_buffer = next_buffer
      self._send_message('code', {
        'buffer': '\n'.join(next_buffer),
        'path':   vim.eval('expand("%")'),
        'lang':   vim.eval('&ft')
      })
    self._send_cursor()

  def _send_message(self, t, d):
    self.ws.send(json.dumps({ 't': t, 'd': d }))

  def _send_cursor(self):
    self._send_message('cursor', {
      'x': vim.current.window.cursor[1] + 1,
      'y': vim.current.window.cursor[0]
    })

Co = Collab()
