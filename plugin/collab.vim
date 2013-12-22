if !has('python')
  finish
endif

com! -nargs=* Collab py Collab.connect(<f-args>)

python << EOF

import vim
import json
import uuid
from ws4py.client.geventclient import WebSocketClient

class CollabClient(WebSocketClient):
  def opened(self):
    print 'connecttion opened'

  def closed(self, code, reason):
    print 'connection closed'

  def received_message(self, m):
    print 'received message'

  def update(self):
    self.send(json.dumps({
      "t": "code", "d": {
        'name': vim.current.buffer.name,
        'content': '\n'.join(vim.current.buffer[:]),
        'cursor_x': vim.current.window.cursor[1] + 1,
        'cursor_y': vim.current.window.cursor[0]
      }
    }))

socket = None

class CollabScope:
  def connect(self, room=False):
    if room == False:
      room = str(uuid.uuid4()).split('-')[-1]
    self.socket = CollabClient('wss://polar-woodland-4270.herokuapp.com/' + room)
    self.socket.connect()
    vim.command('autocmd CursorMoved * py Collab.socket.update()')
    print 'Joined room "' + room + '".'

Collab = CollabScope()
