rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })

rex.bind("ctrl+b>shift+\\", "pane.split.right")
rex.bind("ctrl+b>-", "pane.split.down")
rex.bind("ctrl+b>x", "pane.close")
rex.bind("ctrl+b>z", "pane.zoom")
rex.bind("ctrl+b>o", "pane.focus_next")

rex.bind("ctrl+b>c", "client.tab.new")
rex.bind("ctrl+b>shift+7", "client.tab.close")
rex.bind("ctrl+b>n", "client.tab.next")
rex.bind("ctrl+b>p", "client.tab.previous")
rex.bind("ctrl+b>,", "client.tab.rename")

rex.bind("ctrl+b>s", "session.switch")
rex.bind("ctrl+b>shift+4", "session.rename")

rex.bind("alt+left", "pane.focus.left")
rex.bind("alt+down", "pane.focus.down")
rex.bind("alt+up", "pane.focus.up")
rex.bind("alt+right", "pane.focus.right")

for i = 1, 9 do
  rex.bind("alt+" .. i, "client.tab.goto", { index = i })
end
