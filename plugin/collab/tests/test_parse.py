import unittest
from collab.parse import parse_message

class ParseTest(unittest.TestCase):
    def testParseMessage(self):
        self.assertEqual(("", "", ""), parse_message(""))
        self.assertEqual(("foo", "", ""), parse_message("foo"))
        self.assertEqual(("foo", "bar", ""), parse_message("foo@bar"))
        self.assertEqual(("foo", "", "[]"), parse_message("foo[]"))
        self.assertEqual(("foo", "bar", "[]"), parse_message("foo@bar[]"))
        self.assertEqual(("foo", "bar", "{}"), parse_message("foo@bar{}"))
        self.assertEqual(("foo", "bar", "{{[]}}"), parse_message("foo@bar{{[]}}"))
