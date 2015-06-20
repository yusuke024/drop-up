{CompositeDisposable} = require 'atom'

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
        console.log "#{file.name} - #{file.type}" for file in e.dataTransfer.files


  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
