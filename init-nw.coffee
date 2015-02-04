# NW.js-specific initialisation
if process? then do ->
  gui = require 'nw.gui'; crypto = require 'crypto'; fs = require 'fs'
  path = require 'path'; {spawn} = require 'child_process'; {Proxy} = require './proxy'
  D.nwjs = true
  D.process = process

  nww = gui.Window.get()
  if !opener then do -> # restore window state:
    try i = JSON.parse localStorage.winInfo || null
    if i
      if i.x? && i.y? then nww.moveTo i.x, i.y
      if i.width && i.height then nww.resizeTo i.width, i.height
    return
  nww.show()
  nww.on 'close', ->
    process.nextTick -> nww.close true; return
    if !opener then do -> # save window state:
      i = x: nww.x, y: nww.y, width: nww.width, height: nww.height
      localStorage.winInfo = JSON.stringify i
      return
    window.onbeforeunload?(); window.onbeforeunload = null; return
  D.zoomIn    = -> nww.zoomLevel++;   return
  D.zoomOut   = -> nww.zoomLevel--;   return
  D.resetZoom = -> nww.zoomLevel = 0; return
  $(document).on 'keydown', '*', 'f12', -> nww.showDevTools(); false

  # external editors (available only under nwjs)
  tmpDir = process.env.TMPDIR || process.env.TMP || process.env.TEMP || '/tmp'
  if editorExe = process.env.DYALOG_IDE_EDITOR || process.env.EDITOR
    D.openInExternalEditor = (text, line, callback) ->
      tmpFile = path.join tmpDir, "#{crypto.randomBytes(8).toString 'hex'}.dyalog"
      callback0 = callback
      callback = (args...) -> fs.unlink tmpFile, -> callback0 args... # make sure to delete file before calling callback
      fs.writeFile tmpFile, text, {mode: 0o600}, (err) ->
        if err then callback err; return
        child = spawn editorExe, [tmpFile], cwd: tmpDir, env: $.extend {}, process.env,
          DYALOG_IDE_FILE: tmpFile
          DYALOG_IDE_LINE_NUMBER: 1 + line
        child.on 'error', callback
        child.on 'exit', (c, s) ->
          if c || s then callback('Editor exited with ' + if c then 'code ' + c else 'signal ' + s); return
          fs.readFile tmpFile, 'utf8', callback; return
        return
      return

  D.createSocket = ->
    class LocalSocket
      emit: (a...) -> @other.onevent data: a
      onevent: ({data}) -> (for f in @[data[0]] or [] then f data[1..]...); return
      on: (e, f) -> (@[e] ?= []).push f; @
    socket = new LocalSocket; socket1 = new LocalSocket; socket.other = socket1; socket1.other = socket
    setTimeout (-> Proxy() socket1), 1
    socket

  D.quit = -> gui.Window.get().close(); return
  D.clipboardCopy = (s) -> require('nw.gui').Clipboard.get().set s; return
  return