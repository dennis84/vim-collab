if !has('python')
  finish
endif

com! -nargs=* Collab py Collab.connect(<f-args>)
com! -nargs=0 CollabClean py Collab.clean()

python << EOF

import vim
import json
import uuid
from difflib import unified_diff
from ws4py.client.geventclient import WebSocketClient

class CollabClient(WebSocketClient):
  def __init__(self, *args, **kwargs):
    self.current_buffer = self.makeBuffer(vim.current.buffer[:])
    WebSocketClient.__init__(self, *args, **kwargs)

  def opened(self):
    print 'connection opened'

  def closed(self, code, reason):
    print 'connection closed'

  def received_message(self, m):
    print 'received message'

  def clean(self):
    self.current_buffer = self.makeBuffer(vim.current.buffer[:])
    self.sendMessage('clean', ''.join(self.current_buffer))

  def update(self):
    next_buffer = self.makeBuffer(vim.current.buffer[:])
    if next_buffer != self.current_buffer:
      diff = unified_diff(self.current_buffer, next_buffer)
      content = ''.join(list(diff))
      self.current_buffer = next_buffer
      self.sendMessage('code', content)
    else:
      self.sendMessage('cursor', '')

  def makeBuffer(self, buffer):
    return map(lambda x: x + '\n', buffer)

  def sendMessage(self, type, content):
    self.send(json.dumps({
      "t": type, "d": {
        'name': vim.current.buffer.name,
        'content': content,
        'cursor_x': vim.current.window.cursor[1] + 1,
        'cursor_y': vim.current.window.cursor[0]
      }
    }))

class CollabScope:
  def connect(self, room=False):
    if room == False:
      room = str(uuid.uuid4()).split('-')[-1]
    self.socket = CollabClient('wss://polar-woodland-4270.herokuapp.com/' + room)
    self.socket.connect()
    vim.command('autocmd CursorMoved * py Collab.socket.update()')
    print 'Joined room "' + room + '".'

  def clean(self):
    self.socket.clean()

Collab = CollabScope()
