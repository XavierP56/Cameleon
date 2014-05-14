# Copyright Xavier Pouyollon 2013-2014
# GPL v3 License

__author__ = 'xavierpouyollon'

class FakeRequest(object):

    def __init__(self):
        self._json = {}

    @property
    def json(self):
        return self._json