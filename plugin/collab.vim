if !has('python')
  finish
endif

com! -nargs=* Collab py Collab.connect(<f-args>)

python << EOF

import vim
import json
from ws4py.client.geventclient import WebSocketClient

class CollabClient(WebSocketClient):
    def opened(self):
        vim.command('echo "opened"')

    def closed(self, code, reason):
        vim.command('echo "closed"')

    def received_message(self, m):
        vim.command('echo "message"')

    def update(self):
      self.send(json.dumps({
        'name': 'foo',
        'content': '\n'.join(vim.current.buffer[:]),
        'room': 'foo'
      }))

class CollabScope:
    def connect(self, room=False):
        socket.connect()
        vim.command('autocmd CursorMoved * py socket.update()')

socket = CollabClient('ws://localhost:9000?room=foo')
Collab = CollabScope()
