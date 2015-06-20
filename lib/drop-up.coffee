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

        reader = new FileReader

        reader.onloadend = =>
          options =
            url: "https://api.imgur.com/3/image"
            headers:
              Authorization: "Client-ID xxxxxxxxxxxxxxx"
            formData:
              image: new Buffer new Uint8Array reader.result

          request.post options, (err, resp, body) =>
            console.log body

        reader.readAsArrayBuffer files[0]


  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
