{CompositeDisposable} = require "atom"
{config, preset, setPreset} = require "./config"

module.exports =

  # Configuration
  config: config

  subscriptions: null

  activate: (state) ->

    # Set preset message formats for the first activation
    if atom.config.get("drop-up.setPreset") ? true
      atom.config.set("drop-up.setPreset", false)
      setPreset(preset)

    # Events subscribed to in atom"s system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.workspace.observeTextEditors (textEditor) ->
      textEditorElement = atom.views.getView textEditor
      textEditorElement.addEventListener "drop", (e) ->
        scope = textEditor.getRootScopeDescriptor()

        # Unsupported scope
        if atom.config.getAll("drop-up.format", scope: scope).length == 1
          return

        files = e.dataTransfer.files

        for f in (files[i] for i in [0...files.length]) when f.type.match "image/.*"
          do (f) ->
            e.preventDefault?()
            e.stopPropagation?()

            range = textEditor.insertText atom.config.get("drop-up.format.loading", scope: scope).replace(/\{\{ *name *\}\}/g, f.name).replace(/\{\{ *percent *\}\}/g, "0")
            marker = textEditor.markBufferRange range[0], {invalidate: "inside"}

            formData = new FormData
            formData.append "image", f

            xhr = new XMLHttpRequest
            xhr.open "POST", atom.config.get("drop-up.apiEndPoint"), true
            xhr.setRequestHeader "Authorization", atom.config.get("drop-up.authorizationHeader")

            xhr.onreadystatechange = ->
              if this.readyState == 4 and this.status == 200
                json = JSON.parse this.responseText
                text = atom.config.get("drop-up.format.success", scope: scope).replace(/\{\{ *name *\}\}/g, f.name).replace(/\{\{ *link *\}\}/g, json.data.link)
                textEditor.setTextInBufferRange marker.getBufferRange(), text
                marker.destroy()

            xhr.upload.onprogress = (e) ->
              percent = Math.floor(e.loaded / e.total * 100)
              text = atom.config.get("drop-up.format.loading", scope: scope).replace(/\{\{ *name *\}\}/g, f.name).replace(/\{\{ *percent *\}\}/g, "#{percent}")
              textEditor.setTextInBufferRange marker.getBufferRange(), text

            xhr.send formData

  deactivate: ->
    @subscriptions.dispose()
