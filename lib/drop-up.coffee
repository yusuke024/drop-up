{CompositeDisposable} = require 'atom'

# TODO: Read this from settings
supportedScopes =
  'text.plain.null-grammar':
    loading: '#{name} (#{percent}%)'
    finished: '#{name} (#{link})'
  'source.gfm':
    loading: '[uploading #{name}...#{percent}%]'
    finished: '![#{name}](#{link})'
  'text.html.basic':
    loading: '<!-- uploading #{name}...#{percent}% -->'
    finished: '<img src="#{link}" alt="#{name}">'
  'source.css':
    loading: 'url(/* #{name}...#{percent}% */);'
    finished: 'url(#{link});'

module.exports = DropUp =

  # Configuration
  config:
    apiEndPoint:
      type: 'string'
      default: 'https://api.imgur.com/3/image'
      title: 'API End Point'
    authorizationHeader:
      type: 'string'
      default: 'Client-ID cf92c740bb37b86'
      title: 'Authorization Header'

  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.workspace.observeTextEditors (textEditor) ->
      textEditorElement = atom.views.getView textEditor
      textEditorElement.addEventListener 'drop', (e) ->
        scope = textEditor.getRootScopeDescriptor().getScopesArray()[0]
        if not (scope of supportedScopes)
          return

        files = e.dataTransfer.files

        for f in (files[i] for i in [0...files.length]) when f.type.match "image/.*"
          do (f) ->
            e.preventDefault?()
            e.stopPropagation?()

            range = textEditor.insertText supportedScopes[scope].loading.replace(/#\{name\}/g, f.name).replace(/#\{percent\}/g, "0")
            marker = textEditor.markBufferRange range[0], {invalidate: 'inside'}

            formData = new FormData
            formData.append "image", f

            xhr = new XMLHttpRequest
            xhr.open "POST", atom.config.get('drop-up.apiEndPoint'), true
            xhr.setRequestHeader "Authorization", atom.config.get('drop-up.authorizationHeader')

            xhr.onreadystatechange = ->
              if this.readyState == 4 and this.status == 200
                json = JSON.parse this.responseText
                textEditor.setTextInBufferRange marker.getBufferRange(), supportedScopes[scope].finished.replace(/#\{name\}/g, f.name).replace(/#\{link\}/g, json.data.link)
                marker.destroy()

            xhr.upload.onprogress = (e) ->
              percent = Math.floor(e.loaded / e.total * 100)
              textEditor.setTextInBufferRange marker.getBufferRange(), supportedScopes[scope].loading.replace(/#\{name\}/g, f.name).replace(/#\{percent\}/g, "#{percent}")

            xhr.send formData

  deactivate: ->
    @subscriptions.dispose()
