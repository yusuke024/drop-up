{CompositeDisposable} = require 'atom'

module.exports = DropUp =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.workspace.observeTextEditors (textEditor) ->
      textEditorElement = atom.views.getView textEditor
      textEditorElement.addEventListener 'drop', (e) ->
        e.preventDefault?()
        e.stopPropagation?()

        files = e.dataTransfer.files

        for f in (files[i] for i in [0...files.length])
          do (f) ->
            range = textEditor.insertText "[uploading #{f.name}...0%]"
            marker = textEditor.markBufferRange range[0]

            formData = new FormData
            formData.append "image", f

            xhr = new XMLHttpRequest
            xhr.open "POST", "https://api.imgur.com/3/image", true
            xhr.setRequestHeader "Authorization", "Client-ID cf92c740bb37b86"

            xhr.onreadystatechange = ->
              if this.readyState == 4 and this.status == 200
                json = JSON.parse this.responseText
                textEditor.setTextInBufferRange marker.getBufferRange(), "![#{f.name}](#{json.data.link})"
                marker.destroy()

            xhr.upload.onprogress = (e) ->
              percent = Math.floor(e.loaded / e.total * 100)
              textEditor.setTextInBufferRange marker.getBufferRange(), "[uploading #{f.name}...#{percent}%]"

            xhr.send formData

  deactivate: ->
    @subscriptions.dispose()
