{CompositeDisposable} = require 'atom'
request = require 'request'

module.exports = DropUp =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      editorView = atom.views.getView editor
      editorView.addEventListener 'drop', (e) =>
        e.preventDefault?()
        e.stopPropagation?()

        files = e.dataTransfer.files

        f = files[0]

        formData = new FormData
        formData.append "image", f

        xhr = new XMLHttpRequest
        xhr.open "POST", "https://api.imgur.com/3/image", true
        xhr.setRequestHeader "Authorization", "Client-ID cf92c740bb37b86"

        xhr.onreadystatechange = ->
          if this.readyState == 4 and this.status == 200
            json = JSON.parse xhr.responseText
            editor.insertText "![#{f.name}](#{json.data.link})"

        xhr.send formData

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
