# MIT License
# Created by Chip Viled

class World
  config = null
  map = null
  canvas = null
  context = null
  frame = null
  player = null
  mouse = null
  aggro = null
  players = null
  currentAggro = null
  wayPoints = null

  constructor: ->
    console?.log('World create.')
    @map = []
    @frame = 0
    @canvas = {}
    @player = null
    @mouse = {x:0, y:0}
    @aggro = []
    @players = []
    @playersOldParam1 = []
    @playersOldParam2 = []
    @wayPoints = []

    @config = {
      shootRadius: 305
      playerHalf: 16
      autoShoot: false
      autoRun: false
      autoStopWhenRun: false
      autoRunToPoint: 0
      autoRunStopFix: false
      selectWayPoint: false
      notShoot: false
    }

  loadMap: (pMap) ->
    @map = []
    for plan in pMap
      p = {
        x: plan.x
        y: plan.y
        w: plan.w
        h: plan.h
      }
      @map.push(p)

  setPlayer: (player) ->
    @player = player
    return this

  testLoadMap: (pMap) ->
    if (@map.lenght == 0)
      @loadMap(pMap)

  loadMapAtFrame: (pMap) ->
    if (@frame % 100 == 0)
      @loadMap(pMap)

  drawMap: (map) ->
    if (@player?)
      @context.strokeStyle = '#FF0000'

      if (!map?)
        map = @map

      for plan in map
        @context.strokeRect(
          Math.floor(plan.x - @player.x + @canvas.w/2)
          Math.floor(plan.y - @player.y + @canvas.h/2)
          plan.w
          plan.h
        );


  selectCurrentAggro: () ->
    # Players
    d = null
    @currentAggro = null
    for paln in @players
      for agg in @aggro
        if (agg == player.name)
          td = @distance(plan.x, plan.y - @config.playerHalf, @player.x, @player.y - @config.playerHalf)
          if (d? or d > td)
            d = td
            currentAggro = plan
            currentAggro.type = 'player'
            currentAggro.distance = d


  selectNextWayPoint: (debugDraw) ->
    if (@player? and @mouse.x?)
      point = @getFirstCollision(
        [
          @player.x - @canvas.w/2 + @mouse.x
          @player.y - @canvas.h/2 + @mouse.y - 20
        ]
        [
          @player.x - @canvas.w/2 + @mouse.x
          @player.y - @canvas.h/2 + @mouse.y + 40
        ]
        60
        @map
        debugDraw
      )
    if (point?)
      @wayPoints.push(point)

  addStopWayPoint: (time) ->
    @wayPoints.push(['stop', time])

  deleteAllWayPoints: () ->
    @wayPoints = []


  drawStatus: () ->
    @context.font = "10px SonicTitle";
    @context.fillStyle = "#FFFFFF";
    @context.strokeStyle = '#000000'
    @context.textAlign = "left"
    @context.strokeText("Frame: " + @frame, 11, @canvas.h - 20)
    @context.fillText("Frame: " + @frame, 11, @canvas.h - 20)

    if (@player?)
      @context.strokeText("X: " + (@player.x).toFixed(2), 11, @canvas.h - 50)
      @context.fillText("X: " + (@player.x).toFixed(2), 11, @canvas.h - 50)
      @context.strokeText("Y: " + (@player.y).toFixed(2), 11, @canvas.h - 35)
      @context.fillText("Y: " + (@player.y).toFixed(2), 11, @canvas.h - 35)

      @context.strokeText("Aggro: " + @aggro.join('  '), 11, @canvas.h - 65)
      @context.fillText("Aggro: " + @aggro.join('  '), 11, @canvas.h - 65)

      @context.strokeText("Way points: " + @wayPonitsToString(), 161, @canvas.h - 20)
      @context.fillText("Way points: " + @wayPonitsToString(), 161, @canvas.h - 20)


  wayPonitsToString: () ->
    st = ''
    for p in @wayPoints
      if (p[0] == 'stop')
        st = st + '[' + p[0] + ',' + p[1] + '] '
      else
        st = st + '[' + p[0].toFixed(0) + ',' + p[1].toFixed(0) + '] '
    return st


  loadPlayers: (players) ->
    @playersOldParam2 = []
    for p in @playersOldParam1
      @playersOldParam2.push({
        name: p.name
        x: p.x
        y: p.y
      })

    @playersOldParam1 = []
    for p in @players
      @playersOldParam1.push({
        name: p.name
        x: p.x
        y: p.y
      })

    @players = []
    for p in players
      @players.push({
        name: p.name
        x: p.x
        y: p.y
        hp: p.HP
        w: p.w
        h: p.h
      })


  drawPlayers: ->
    if (@player? and @players?)
      for p in @players
        @context.strokeStyle = '#FF00FF'
        if (p.name == @player.name)
          continue
        resAggro = false
        for pa in @aggro
          if (p.name == pa)
            resAggro = true
        @context.strokeStyle = '#FF00FF'
        if (resAggro)
          @context.strokeStyle = '#FFCCFF'
          @context.strokeRect(
            Math.floor(p.x - @player.x + @canvas.w/2 - 19)
            Math.floor(p.y - @player.y + @canvas.h/2 + 3)
            38
            -38
          )
        @context.strokeRect(
          Math.floor(p.x - @player.x + @canvas.w/2 - 16)
          Math.floor(p.y - @player.y + @canvas.h/2)
          32
          -32
        );


  drawMouse: () ->
    if (@player? and @mouse.x?)
      @context.strokeStyle = '#00FF00'
      @context.strokeRect(@mouse.x - 7, @mouse.y - 7, 15, 15)

      xPl = @canvas.w/2
      yPl = @canvas.h/2 - @config.playerHalf
      wPl = xPl - @mouse.x
      hPl = yPl - @mouse.y
      d = distance(xPl, yPl, @mouse.x, @mouse.y)
      wPl = wPl / d * @config.shootRadius
      hPl = hPl / d * @config.shootRadius

      @context.strokeStyle = '#00FF00'
      @context.beginPath()
      @context.moveTo(xPl, yPl)
      @context.lineTo(xPl - wPl, yPl - hPl)
      @context.stroke()

#      p = @getFirstCollision(
#        [
#          @player.x
#          @player.y  - @config.playerHalf
#        ]
#        [
#          @player.x - @canvas.w/2 + @mouse.x
#          @player.y - @canvas.h/2 + @mouse.y
#        ]
#        @config.shootRadius + @config.playerHalf
#        @map
#        true
#      )

      if (@config.selectWayPoint)
        point = @getFirstCollision(
          [
            @player.x - @canvas.w/2 + @mouse.x
            @player.y - @canvas.h/2 + @mouse.y - 20
          ]
          [
            @player.x - @canvas.w/2 + @mouse.x
            @player.y - @canvas.h/2 + @mouse.y + 40
          ]
          60
          @map
          true
        )


  drawWayPonits: () ->
    for ponit, index in @wayPoints
      if (@config.autoRunToPoint == index)
        @context.strokeStyle = '#FFFF00'
      else
        @context.strokeStyle = '#00FFFF'
      @context.strokeRect(
        ponit[0] - 7 - @player.x + @canvas.w/2
        ponit[1] - 7 - @player.y + @canvas.h/2
        15
        15
      )


  getFirstCollision: (pointBegin, pointEnd, maxRadius, map, debugDraw) ->
    if (pointBegin[0]? and pointBegin[1]? and pointEnd[0]? and pointEnd[1]?)
      d = @distance(pointBegin[0], pointBegin[1], pointEnd[0], pointEnd[1])
      if (d > maxRadius)
        pointEnd[0] = (pointEnd[0] - pointBegin[0]) / d * maxRadius + pointBegin[0]
        pointEnd[1] = (pointEnd[1] - pointBegin[1]) / d * maxRadius + pointBegin[1]

      reColision = []
      for plan in map
        if (@colisionLineRectangle(
          [pointBegin[0], pointBegin[1]]
          [pointEnd[0], pointEnd[1]]
          [plan.x, plan.y]
          [plan.x + plan.w, plan.y]
          [plan.x + plan.w, plan.y + plan.h]
          [plan.x, plan.y + plan.h]
        ))
          reColision.push(plan)
          if (debugDraw)
            @context.strokeStyle = '#FFFFFF'
            @context.strokeRect(
              Math.floor(plan.x - @player.x + @canvas.w/2)
              Math.floor(plan.y - @player.y + @canvas.h/2)
              plan.w
              plan.h
            )
      pColisions = []
      for plan in reColision
        res = @getPointOfIntersection(
          [pointBegin[0], pointBegin[1]]
          [pointEnd[0], pointEnd[1]]
          [plan.x, plan.y]
          [plan.x + plan.w, plan.y]
        )
        if (res?)
          pColisions.push(res)

        res = @getPointOfIntersection(
          [pointBegin[0], pointBegin[1]]
          [pointEnd[0], pointEnd[1]]
          [plan.x + plan.w, plan.y]
          [plan.x + plan.w, plan.y + plan.h]
        )
        if (res?)
          pColisions.push(res)

        res = @getPointOfIntersection(
          [pointBegin[0], pointBegin[1]]
          [pointEnd[0], pointEnd[1]]
          [plan.x + plan.w, plan.y + plan.h]
          [plan.x, plan.y + plan.h]
        )
        if (res?)
          pColisions.push(res)

        res = @getPointOfIntersection(
          [pointBegin[0], pointBegin[1]]
          [pointEnd[0], pointEnd[1]]
          [plan.x, plan.y + plan.h]
          [plan.x, plan.y]
        )
        if (res?)
          pColisions.push(res)

      dSmallest = null
      pointSmallest = null
      for point in pColisions
        d = @distance(pointBegin[0], pointBegin[1], point[0], point[1])
        if (!dSmallest? or dSmallest > d)
          dSmallest = d
          pointSmallest = point

      if (debugDraw)
        @context.beginPath()
        @context.moveTo(
          pointBegin[0] - @player.x + @canvas.w/2
          pointBegin[1] - @player.y + @canvas.h/2
        )
        @context.lineTo(
          pointEnd[0] - @player.x + @canvas.w/2
          pointEnd[1] - @player.y + @canvas.h/2
        )
        @context.stroke()

      if (debugDraw and pointSmallest?)
        @context.strokeStyle = '#FFFF00'
        @context.strokeRect(
          pointSmallest[0] - 5 - @player.x + @canvas.w/2
          pointSmallest[1] - 5 - @player.y + @canvas.h/2
          11
          11
        )
      return pointSmallest
    else
      return null


  shootInAggroPlayers: (debugDraw) ->
    if (!@player?)
      return 0

    ignorePlayers = []
    aggroPlayers = []

    for player in @players
      if (player.name == @player.name)
        continue
      isAggro = false
      for aggroName in @aggro
        if (player.name == aggroName)
          isAggro = true
          aggroPlayers.push(player)
      if (!isAggro)
        ignorePlayers.push(player)

    mapIgnore = []
    for player in ignorePlayers
      mapIgnore.push({
        x: player.x - 16
        y: player.y - 32
        w: 32
        h: 32
      })

    for m in @map
      mapIgnore.push({
        x: m.x
        y: m.y
        w: m.w
        h: m.h
      })

    if (debugDraw)
      @drawMap(mapIgnore)

    for aggroName in @aggro
      for player in aggroPlayers
        if (player.name == aggroName)
          if (debugDraw)
            @context.strokeStyle = '#CCCCCC'
            @context.strokeRect(
              player.x - 6 - @player.x + @canvas.w/2
              player.y - 6 - @player.y + @canvas.h/2 - @config.playerHalf
              13
              13
            )

          d = distance(
            @player.x
            @player.y - @config.playerHalf
            player.x
            player.y - @config.playerHalf
          )
          if (d > (@config.shootRadius + @config.playerHalf))
            continue

          dif = @getDifForPlayer(player.name)
          if (!dif?)
            dif = [0, 0]

          p = @getFirstCollision(
            [
              @player.x
              @player.y - @config.playerHalf
            ]
            [
              player.x + dif[0]* d
              player.y - @config.playerHalf + dif[1] * d
            ]
            @config.shootRadius + @config.playerHalf
            mapIgnore
            debugDraw
          )

          if (p)
            continue

          if (debugDraw)
            @context.strokeStyle = '#FFFFFF'
            @context.strokeRect(
              player.x - 5 - @player.x + @canvas.w/2 + dif[0] * d
              player.y - 5 - @player.y + @canvas.h/2 - @config.playerHalf + dif[1] * d
              11
              11
            )

          if (!@config.notShoot and @config.autoShoot)
            @shoot([
              -(player.y - @player.y + dif[1] * d)
              -(player.x - @player.x + dif[0] * d)
            ])
            @config.notShoot = true
            window.setTimeout( =>
              @config.notShoot = false
            ,
              700
            )
          return 0



  getDifForPlayer: (name) ->
    for p in @players
      if (p.name == name)
        pNow = [p.x, p.y]

    for p in @playersOldParam1
      if (p.name == name)
        pOld1 = [p.x, p.y]

    for p in @playersOldParam2
      if (p.name == name)
        pOld2 = [p.x, p.y]

    sigma = []
    if (pNow? and pOld1? and pOld2?)
      if (pNow[0] - pOld2[0] == 0)
        sigma[0] = 0.05           # It's MAGIC NUMBER
      else
        if (Math.abs(pNow[0] - pOld1[0]) > Math.abs(pOld1[0] - pOld2[0]))
          sigma[0] = 0.05
        else
          sigma[0] = 0.05

      if (pNow[1] - pOld2[1] == 0)
        sigma[1] = 0.06
      else
        if (Math.abs(pNow[1] - pOld1[1]) > Math.abs(pOld1[1] - pOld2[1]))
          sigma[1] = 0.07
        else
          sigma[1] = 0.05
      return [(pNow[0] - pOld2[0])/2 * sigma[0], (pNow[1] - pOld2[1])/2 * sigma[1]]
    else
     return null


  autoRunOnWay: (debugDraw) ->
    if (!@config.autoRun or @config.autoStopWhenRun)
      @runStop()
      return null
    else
      if (!@wayPoints?)
        return null
      if (!@wayPoints[@config.autoRunToPoint]?)
        if (@wayPoints[0]?)
          @config.autoRunToPoint = 0
        else
          @runStop()
          return null
      if (@wayPoints[@config.autoRunToPoint][0] == 'stop')
        @config.autoStopWhenRun = true
        window.setTimeout(
          () =>
            @config.autoStopWhenRun = false
          parseInt(@wayPoints[@config.autoRunToPoint][1], 10)
        )
        @config.autoRunToPoint = @config.autoRunToPoint + 1
        return null

      res = @runToPoint(@wayPoints[@config.autoRunToPoint], 20)
      if (res == true)
        @config.autoRunToPoint = @config.autoRunToPoint + 1
      return null


  runToPoint: (point, delta) ->
    if (!delta?)
      delta = 10
    if (point[0] > @player.x + delta)
      @runRight()
      return false
    else  if (point[0] < @player.x - delta)
      @runLeft()
      return false
    else
      @runStop()
      return true


  setAggroUsers: (arr) ->
    @aggro = []
    for s in arr
      if (s.trim() != '')
        @aggro.push(s.trim())

  setCanvas: (canvas) ->
    @canvas = canvas
    return this

  setCanvasWH: (w, h) ->
    @canvas.w = w
    @canvas.h = h
    return this

  getCanvas: () ->
    return @canvas

  setContext: (context) ->
    @context = context
    return this

  setMouse: (x, y)->
    @mouse = {x: x, y: y}
    return this

  getMouse: () ->
    return @mouse

  getContext: () ->
    return @context

  getAutoShoot: () ->
    return @config.autoShoot

  setAutoShoot: (boo) ->
    @config.autoShoot = boo
    return this

  getAutoRun: () ->
    return @config.autoRun

  setAutoRun: (boo) ->
    @config.autoRun = boo
    @config.autoStopWhenRun = false
    return this

  incFrame: () ->
    @frame = @frame + 1

  getSelectWayPoint: () ->
    return @config.selectWayPoint

  setSelectWayPoint: (value) ->
    @config.selectWayPoint = value
    return this

  distance: (x1, y1, x2, y2) ->
    return Math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))

  distanceSquare: (x1, y1, x2, y2) ->
    return ((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))

  rotate: (A, B, C) ->
    return (B[0]-A[0])*(C[1]-B[1])-(B[1]-A[1])*(C[0]-B[0])

  intersect: (A, B, C, D) ->
    return @rotate(A,B,C)*@rotate(A,B,D)<=0 and @rotate(C,D,A)*@rotate(C,D,B)<0

  colisionLineRectangle: (L1, L2, B1, B2, B3, B4) ->
    return (@intersect(L1, L2, B1, B2) or @intersect(L1, L2, B2, B3) or @intersect(L1, L2, B3, B4) or @intersect(L1, L2, B4, B1))

  getPointOfIntersection: (P1, P2, P3, P4) ->
    d = (P1[0] - P2[0]) * (P4[1] - P3[1]) - (P1[1] - P2[1]) * (P4[0] - P3[0])
    da = (P1[0] - P3[0]) * (P4[1] - P3[1]) - (P1[1] - P3[1]) * (P4[0] - P3[0])
    db = (P1[0] - P2[0]) * (P1[1] - P3[1]) - (P1[1] - P2[1]) * (P1[0] - P3[0])
    ta = da / d
    tb = db / d
    if (ta >= 0 and ta <= 1 and tb >= 0 and tb <= 1)
      dx = P1[0] + ta * (P2[0] - P1[0])
      dy = P1[1] + ta * (P2[1] - P1[1])
      return [dx, dy]
    return null


  shoot: (point) ->
    angle = Math.atan2(point[0], point[1])
    sX = Math.cos(angle) * 15
    sY = Math.sin(angle) * 15
    window.socket.emit('netNewProjectile', { sX: sX, sY: sY })

  runLeft: () ->
    @config.autoRunStopFix = true
    window.socket.emit('btnPress', { 'key' : 'A' })
    window.socket.emit('btnRelease', { 'key' : 'D' })

  runRight: () ->
    @config.autoRunStopFix = true
    window.socket.emit('btnPress', { 'key' : 'D' })
    window.socket.emit('btnRelease', { 'key' : 'A' })

  runStop: () ->
    if (@config.autoRunStopFix)
      window.socket.emit('btnRelease', { 'key' : 'A' })
      window.socket.emit('btnRelease', { 'key' : 'D' })
      @config.autoRunStopFix = false
    return null


#*******************************************************
window.cvWorld = new World
window.cvI = 0
window.cvConfig = {
  debugDraw: true
}


#jQuery('body').append('<script src="https://raw.githubusercontent.com/kripken/box2d.js/master/build/Box2D_v2.3.1_min.js"></script>')

jQuery('document').ready( =>
  console?.log('Including...')
  canvas  = document.getElementById("game")
  context = canvas.getContext("2d")
  window.cvWorld.setCanvas(canvas)
  window.cvWorld.setCanvasWH(window.cw, window.ch)
  window.cvWorld.setContext(context)
  window.cvWorld.loadMap(window.level)

  tr = window.requestAnimationFrame
  window.requestAnimationFrame = (s) =>
    tr(s)
    window.cvWorld.incFrame()
    window.cvWorld.setPlayer(window.localPlayer)
    window.cvWorld.setMouse(window.mX, window.mY)
    window.cvWorld.loadMapAtFrame(window.level)
    window.cvWorld.loadPlayers(window.p)
    window.cvWorld.shootInAggroPlayers(window.cvConfig.debugDraw)
    window.cvWorld.autoRunOnWay(window.cvConfig.debugDraw)

    if (window.cvConfig.debugDraw)
      #window.cvWorld.drawMap()
      window.cvWorld.drawMouse()
      #window.cvWorld.drawPlayers()
      window.cvWorld.drawWayPonits()

    window.cvWorld.drawStatus()

    return null
)


jQuery('#game').after(
  '''
  <style>
  .cv-control {
    background-color: #104d9d;
    color: #FAFAFF;
    border-radius: 5px;
    display: inline-block;
    position: relative;
    margin: 5px;
    padding: 4px;
    width: 1000px;
  }

  .cv-button {
    cursor:pointer;
    padding: 2px 5px;
    display: inline-block;
    border-radius: 5px;
  }

  .cv-button:hover {
    box-shadow: inset 0px 0px 15px 3px rgba(0,0,0,0.25);
  }

  .cv-push {
    box-shadow: inset 0px 0px 15px 3px rgba(0,0,0,0.75);
  }

  .cv-push:hover {
    box-shadow: inset 0px 0px 15px 3px rgba(0,0,0,0.5);
  }

  .cv-input {
    margin-left: 15px;
    color: #000000
  }

  </style>
  <div class="cv-control">
    <div>
      <span id="autoshoot" class="cv-button">Auto Shoot</span>
      <span id="autorun" class="cv-button">Auto Run</span>
      <span id="select-way-point" class="cv-button">Add way point</span>
      <span id="add-stop-way-point" class="cv-button">Stop way point (7c)</span>
      <span id="delete-way-points" class="cv-button">Delete way points</span>
      <input id="aggro-input" value="aggro (separate come)" class="cv-input">
      <span id="aggro-send" class="cv-button">Send aggro</span>
    </div>
    <div>
      <span id="debugDraw" class="cv-button">Debug Draw</span>
    </div>
  </div>
  ''')

addWayPoint = () ->
  jQuery('#game').off('click', addWayPoint)
  jQuery('#select-way-point').removeClass('cv-push')
  window.cvWorld.setSelectWayPoint(false)
  window.cvWorld.selectNextWayPoint()

jQuery('#autoshoot').click( () =>
  if (window.cvWorld.getAutoShoot() != true)
    window.cvWorld.setAutoShoot(true)
    jQuery('#autoshoot').addClass('cv-push')
  else
    window.cvWorld.setAutoShoot(false)
    jQuery('#autoshoot').removeClass('cv-push')
)

jQuery('#autorun').click( () =>
  if (window.cvWorld.getAutoRun() != true)
    window.cvWorld.setAutoRun(true)
    jQuery('#autorun').addClass('cv-push')
  else
    window.cvWorld.setAutoRun(false)
    jQuery('#autorun').removeClass('cv-push')
)

jQuery('#select-way-point').click( () =>
  if (window.cvWorld.getSelectWayPoint() != true)
    jQuery('#select-way-point').addClass('cv-push')
    jQuery('#game').on('click', addWayPoint)
    window.cvWorld.setSelectWayPoint(true)
  else
    jQuery('#select-way-point').removeClass('cv-push')
    jQuery('#game').off('click', addWayPoint)
    window.cvWorld.setSelectWayPoint(false)
)

jQuery('#add-stop-way-point').click( () =>
  window.cvWorld.addStopWayPoint(7000)
)

jQuery('#delete-way-points').click( () =>
  jQuery('#select-way-point').removeClass('cv-push')
  jQuery('#game').off('click', addWayPoint)
  window.cvWorld.setSelectWayPoint(false)
  window.cvWorld.deleteAllWayPoints()
)

jQuery('#aggro-send').click( () =>
  tmpArray = []
  s = jQuery('#aggro-input').val()
  tmpArray2 = s.split(',')
  for ss in tmpArray2
    tmpArray.push(ss.trim())
  window.cvWorld.setAggroUsers(tmpArray)
)

jQuery('#debugDraw').click( () =>
  if (window.cvConfig.debugDraw != true)
    window.cvConfig.debugDraw = true
    jQuery('#debugDraw').addClass('cv-push')
  else
    window.cvConfig.debugDraw = false
    jQuery('#debugDraw').removeClass('cv-push')
)


