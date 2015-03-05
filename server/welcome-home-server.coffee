Lights = new Mongo.Collection("lights");
HueGroups = new Mongo.Collection("hueGroups");

bridge = {}
bridge.hue_user = "newdeveloper"

defaultState = JSON.stringify({
  alert: "none", hue: 14922, effect: "none",
  sat: 60, bri: 254, on: true
})

onState = JSON.stringify({ on: true })
offState = JSON.stringify({ on: false })

Meteor.methods
  getbridgeData: ->
    result = Meteor.http.call "GET", "http://www.meethue.com/api/nupnp"
    return result

  getLightsData: ->
    return Meteor.http.call "GET", "http://#{bridge.local_ip}/api/#{bridge.hue_user}/lights"

  setLightsData: ->
    Meteor.call "getLightsData", (error, results) ->
      for k,v of results.data
        v.id = k
        Lights.upsert({id: k}, v)
        console.log "Lights id: #{k} #{v}"

  getGroupsData: ->
    return Meteor.http.call "GET", "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups"

  setGroupsData: ->
    Meteor.call "getGroupsData", (error, results) ->
      for k,v of results.data
        v.id = k
        HueGroups.upsert({id: k}, v)
        console.log "Group id: #{k} #{v}"

  createGroup:  ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups"
    Meteor.http.call "POST", url, {content: JSON.stringify data.state}

  allOn: ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/0/action"
    Meteor.http.call "PUT", url, { content: onState }
    Meteor.call "setLightsData"

  allOff: ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/0/action"
    Meteor.http.call "PUT", url, { content: offState }
    Meteor.call "setLightsData"

  allDefault: ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/groups/0/action"
    Meteor.http.call "PUT", url, { content: defaultState }
    Meteor.call "setLightsData"


  bulbOn: (bulb) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/lights/#{bulb}/state"
    Meteor.http.call "PUT", url, { content: onState }
    Meteor.call "setLightsData"

  bulbOff: (bulb) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/lights/#{bulb}/state"
    Meteor.http.call "PUT", url, { content: offState }
    Meteor.call "setLightsData"

  bulbDefault: (bulb) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/lights/#{bulb}/state"
    Meteor.http.call "PUT", url, { content: defaultState }
    Meteor.call "setLightsData"

  setBulb: (data) ->
    url = "http://#{bridge.local_ip}/api/#{bridge.hue_user}/lights/#{data.id}/state"
    Meteor.http.call "PUT", url, { content: JSON.stringify data.state }
    Meteor.call "setLightsData"


Meteor.startup ->

  # We only care about the first connected bridge
  # for now, because I only have one bridge. :P
  Meteor.call "getbridgeData", (error, results) ->
    bridge.local_ip = results.data[0].internalipaddress
    console.log "#{bridge.local_ip}"
    Meteor.call "setLightsData"
    Meteor.call "setGroupsData"

  Meteor.publish "lights", ->
    Lights.find {}

  Meteor.publish "hueGroups", ->
    HueGroups.find {}  