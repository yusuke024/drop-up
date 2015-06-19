DropUpView = require './drop-up-view'
{CompositeDisposable} = require 'atom'

module.exports = DropUp =
  dropUpView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @dropUpView = new DropUpView(state.dropUpViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @dropUpView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'drop-up:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @dropUpView.destroy()

  serialize: ->
    dropUpViewState: @dropUpView.serialize()

  toggle: ->
    console.log 'DropUp was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
