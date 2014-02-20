# Copyright Xavier Pouyollon 2014
# GPL v3 License

# This file contains the model. Will get away in a soon future.

dmx_model = {
    "1": {"channel": 1,
          "defs": {
              "dimmer": 1,
              "red": 3,
              "green": 4,
              "blue": 5
          },
          "inits": {
              "dimmer": 255,
              "red": 255,
              "green": 254,
              "blue": 253
          }
    }
}

dmx_setting = {
    "setting_red" : {
        "dimmer":255,
        "red":255,
        "green":0,
        "blue":0
    },
    "setting_green" : {
        "dimmer":255,
        "red":0,
        "green":255,
        "blue":0
    },
    "setting_green_clair" : {
        "dimmer":85,
        "red":111,
        "green":174,
        "blue":113
    },
    "setting_blue" : {
        "dimmer":255,
        "red":0,
        "green":0,
        "blue":255
    }
}

sounds = {
    "4" : {
        'song-file' : "08_ Porte se ferme.wav",
        'song-name' : "La porte !",
        'position' : 'l',
        'loop' : False,
        'card' : 1
    },
    "8" : {
        'song-file' : "Gnomes2 deform.wav",
        'song-name' : "Fin",
        'loop' : False,
        'position' : 'r',
        'card' : 1
    }
}



