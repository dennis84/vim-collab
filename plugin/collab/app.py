import json
import websocket
import diff_match_patch as dmp
from .conn import Connection
from .parse import parse_message
from .util import generate_id

class Collab:
    def __init__(self):
        self.current_buffer = None
        self.current_file = None
        self.connected = False
        self.patching = False
        self.dmp = dmp.diff_match_patch()

    def is_connected(fn):
        def decorated(self, *args, **kwargs):
            if self.connected:
                fn(self, *args, **kwargs)
        return decorated

    @is_connected
    def _send_message(self, t, d):
        self.ws.send(t + json.dumps(d))

    def _on_open(self, ws):
        self.connected = True
        print 'Joined: ' + self.room

    def _on_error(self, ws, error):
        self.disconnect()

    def _on_message(self, ws, message):
        evt, sender, data = parse_message(message)
        if evt == 'join':
            self.patching = False

    def connect(self, room=False, url=False):
        if room == False:
            room = generate_id()
        if url == False:
            url = 'radiant-dusk-8167.herokuapp.com'
        self.room = room
        self.ws = websocket.WebSocketApp(
            'ws://' + url + '/' + room,
            on_message = self._on_message,
            on_open = self._on_open,
            on_error = self._on_error)
        self.co = Connection(self.ws)
        self.co.start()

    @is_connected
    def disconnect(self):
        self.connected = False
        self.ws.close()

    def change_nick(self, name):
        self._send_message('change-nick', {'name': name})

    def update(self, buffer, file, lang):
        if buffer != self.current_buffer:
            content = buffer
            if True == self.patching and file == self.current_file:
                diffs = self.dmp.patch_make(self.current_buffer, buffer)
                content = self.dmp.patch_toText(diffs)
            self._send_message('code', {
                'content': content,
                'file':    file,
                'lang':    lang
            })
            self.patching = True
            self.current_buffer = buffer
            self.current_file = file

    def update_cursor(self, x, y, file):
        self._send_message('cursor', {'x': x, 'y': y, 'file': file})
