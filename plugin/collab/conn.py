import threading

class Connection(threading.Thread):
  def __init__(self, ws):
    threading.Thread.__init__(self)
    self.ws = ws

  def run(self):
    self.ws.run_forever()
