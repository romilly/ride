prefs = require './prefs'
{delay} = require './util'

@name = 'Code'

$ai = $sw = $aim = $swm = $acbr = $acbl = $fold = null

updateAutoIndentFields = ->
  $sw.add($aim).prop 'disabled', !$ai.is ':checked'
  $swm.prop 'disabled', !$ai.is(':checked') || !$aim.is ':checked'
  return

@init = ($e) ->
  $e.html '''
    <p><label><input id=code-ai   type=checkbox>Auto-indent</label> <label><input id=code-sw  size=1> spaces</label>
    <p><label><input id=code-aim  type=checkbox>in methods:</label> <label><input id=code-swm size=1> spaces</label>
    <p><label><input id=code-acbr type=checkbox>Auto-close brackets: <tt>{}[]()</tt></label>
    <p><label><input id=code-acbl type=checkbox>Auto-close blocks: <tt>:if :for ...</tt></label>
    <p><label><input id=code-fold type=checkbox>Code folding</label>
  '''
  $ai   = $ '#code-ai'
  $sw   = $ '#code-sw'
  $aim  = $ '#code-aim'
  $swm  = $ '#code-swm'
  $acbr = $ '#code-acbr'
  $acbl = $ '#code-acbl'
  $fold = $ '#code-fold'
  $ai.add($aim).change updateAutoIndentFields
  $sw.add($swm).click -> $(@).select(); return
  return

@load = ->
  sw  = prefs.indent();        $ai .prop 'checked', sw  >= 0; $sw .val sw  < 0 && 4 || sw
  swm = prefs.indentMethods(); $aim.prop 'checked', swm >= 0; $swm.val swm < 0 && 2 || swm
  $acbr.prop 'checked', !!prefs.autoCloseBrackets()
  $acbl.prop 'checked', !!prefs.autoCloseBlocks()
  $fold.prop 'checked', !!prefs.fold()
  updateAutoIndentFields()
  return

@save = ->
  prefs.autoCloseBrackets $acbr.is ':checked'
  prefs.autoCloseBlocks   $acbl.is ':checked'
  prefs.indent        if $ai .is ':checked' then +$sw .val() || 0 else -1
  prefs.indentMethods if $aim.is ':checked' then +$swm.val() || 0 else -1
  prefs.fold $fold.is ':checked'
  return
