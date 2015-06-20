{CompositeDisposable} = require 'atom'

module.exports = DropUp =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      editorView = atom.views.getView editor
      editorView.addEventListener 'dragover', (e) =>
        e.preventDefault?()
        console.log e


  deactivate: ->
    @subscriptions.dispose()

  serialize: ->
