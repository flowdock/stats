Stats = require '../src/stats'
require 'should'

describe 'stats', ->
  beforeEach ->
    @stats = new Stats namespace: 'foo'
    @res =
      contentType: (type) ->
        @_contentType = type
      send: (payload) ->
        @_payload = payload

  it 'can increment value', ->
    @stats.increment 'counter', 1
    @stats.stats['counter'].should.eql 1
    @stats.render null, @res
    JSON.parse(@res._payload).counter.should.eql 1

  it 'can render function keys', ->
    @stats.key 'fun', ->
      1
    @stats.render null, @res
    JSON.parse(@res._payload).fun.should.eql 1

  it 'can render plain value keys', ->
    @stats.key 'plain', 1
    @stats.render null, @res
    JSON.parse(@res._payload).plain.should.eql 1
