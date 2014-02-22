if !has('python')
  finish
endif

com! -nargs=1 Collab py Co.connect(<f-args>)
com! -nargs=1 CollabChangeNick py Co.updateNick(<f-args>)
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
    self.connected = False

  def is_connected(func):
    def decorated(self, *args, **kwargs):
      if self.connected:
        func(self, *args, **kwargs)
    return decorated

  def on_open(self, ws):
    self.connected = True
    print 'Joined: ' + self.room

  def on_error(self, ws, error):
    self.disconnect()

  def connect(self, room=False):
    if room == False:
      self.room = str(uuid.uuid4()).split('-')[-1]
    else:
      self.room = room

    self.ws = websocket.WebSocketApp(
      'wss://polar-woodland-4270.herokuapp.com/' + self.room,
      on_open = self.on_open,
      on_error = self.on_error)

    self.co = Connection(self.ws)
    self.co.start()

    vim.command('autocmd CursorMoved * py Co.update()')
    vim.command('autocmd CursorMovedI * py Co.update()')

  def disconnect(self):
    self.connected = False
    self.ws.close()
    self.co.close()

  def updateNick(self, name):
    self._send_message('update-nick', name)

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

  @is_connected
  def _send_message(self, t, d):
    self.ws.send(json.dumps({ 't': t, 'd': d }))

  def _send_cursor(self):
    self._send_message('cursor', {
      'x': vim.current.window.cursor[1] + 1,
      'y': vim.current.window.cursor[0]
    })

Co = Collab()
