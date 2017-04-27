# dashing.js is located in the dashing framework
# It includes jquery & batman for you.
#= require dashing.js

#= require_directory .
#= require_tree ../../widgets


Dashing.Widget::accessor 'updatedAtMessageWithSeconds', ->
    if updatedAt = @get('updatedAt')
      timestamp = new Date(updatedAt * 1000)
      hours = timestamp.getHours()
      minutes = ("0" + timestamp.getMinutes()).slice(-2)
      seconds = ("0" + timestamp.getSeconds()).slice(-2)
      "Last updated at #{hours}:#{minutes}:#{seconds}"

Dashing.on 'ready', ->
  Dashing.widget_margins ||= [5, 5]
  Dashing.widget_base_dimensions ||= [300, 360]
  Dashing.numColumns ||= 4

  contentWidth = (Dashing.widget_base_dimensions[0] + Dashing.widget_margins[0] * 2) * Dashing.numColumns

  Batman.setImmediate ->
    $('.gridster').width(contentWidth)
    $('.gridster ul:first').gridster({
      widget_margins: Dashing.widget_margins,
      widget_base_dimensions: Dashing.widget_base_dimensions,
      avoid_overlapped_widgets: true #!Dashing.customGridsterLayout
    }).data('gridster').disable();

  Batman.Filters.titleize = (string) ->
    string.replace /(^|\s)([a-z])/g, (m, p1, p2) -> p1 + p2.toUpperCase()

  Batman.Filters.statusify = (pool, status) ->
    if status == 'ENABLED_STATUS_DISABLED'
      "#{pool} (•)"
    else
      pool
