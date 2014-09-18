
Abstract = require('./Abstract')
Native   = require('../methods/Native')

class Document extends Abstract
  priority: Infinity

  Methods:    Native::mixin {},
              Abstract::Methods,
              require('../methods/Selectors'),
              require('../methods/Rules')

  Queries:    require('../modules/Queries')
  Pairs:      require('../modules/Pairs')

  Mutations:  require('../modules/Mutations')
  Positions:  require('../modules/Positions')
  Stylesheet: require('../modules/Stylesheets')

  helps: true

  constructor: () ->
    @engine.positions   ||= new @Positions(@)
    @engine.stylesheets ||= new @Stylesheet(@)
    @engine.applier     ||= @engine.positions
    @engine.scope       ||= document
    @engine.queries     ||= new @Queries(@)
    @engine.pairs       ||= new @Pairs(@)
    @engine.mutations   ||= new @Mutations(@)
    @engine.all           = @engine.scope.getElementsByTagName('*')

    
    if @scope.nodeType == 9 && ['complete', 'loaded'].indexOf(@scope.readyState) == -1
      @scope.addEventListener 'DOMContentLoaded', @
      window.addEventListener 'load', @
    else if @running
      @events.compile.call(@)



    @scope.addEventListener 'scroll', @engine, true
    debugger
    if window?
      window.addEventListener 'resize', @engine

    super

  events:
    resize: (e = '::window') ->
      id = e.target && @identity.provide(e.target) || e
      debugger
      if e.target && @updating
        if @updating.resizing
          return @updating.resizing = 'scheduled'
        @updating.resizing = 'computing'
        @once 'solve', ->
          if @updated.resizing == 'scheduled'
            @document.events.resize.call(@)


      @solve id + ' resized', ->
        @intrinsic.verify(id, "width")
        @intrinsic.verify(id, "height")
      
    scroll: (e = '::window') ->
      id = e.target && @identity.provide(e.target) || e
      @solve id + ' scrolled', ->
        @intrinsic.verify(id, "scroll-top")
        @intrinsic.verify(id, "scroll-left")

    solve: ->
      if @scope.nodeType == 9
        html = @scope.body.parentNode
        klass = html.className
        if klass.indexOf('gss-ready') == -1
          html.className = (klass && klass + ' ' || '') + 'gss-ready' 
      # Unreference removed elements
      if @removed
        for id in @removed
          @identity.unset(id)
        @removed = undefined

    # Observe stylesheets in dom
    DOMContentLoaded: ->
      @scope.removeEventListener 'DOMContentLoaded', @
      window.removeEventListener 'load', @
      @engine.compile() if @running == undefined
    
    onLoad: ->
      @DOMContentLoaded()

    # Observe and parse stylesheets
    compile: ->
      @stylesheets.compile()
      
    destroy: ->
      @scope.removeEventListener 'DOMContentLoaded', @
      @scope.removeEventListener 'scroll', @
      window.removeEventListener 'resize', @
      @events.destroy.apply(@, arguments)

  @condition: ->
    @scope?  
  url: null
module.exports = Document