adminIndexes =
  dateNeededDisplay: 0
  title: 1
  requestDateDisplay: 2
  instructor: 3
  course: 4
  typeDisplay: 5
  requestDateTimestamp: 6
  dateNeededTimestamp: 7
  searchKeywords: 8
  status: 9
  library: 10
  type: 11

class AdminDataTable
  constructor: (@tableElement) ->
    if @tableElement.length > 0
      @setupTable()
      @setupFilters()

  setupTable: ->
    @table = @tableElement.DataTable(
      dom: "f<'row-fluid'<'span12'ip>r>t<'row-fluid'<'span12'ip>>",
      pagingType: "bootstrap"
      lengthChange: false
      deferRender: true
      pageLength: 100
      processing: true
      ajax:
        url: window.location.href
      columnDefs: [
        targets: adminIndexes['requestDateDisplay']
        orderData: [adminIndexes['requestDateTimestamp']]
      ,
        targets: adminIndexes['dateNeededDisplay']
        orderData: [adminIndexes['dateNeededTimestamp']]
      ,
        targets: adminIndexes['requestDateTimestamp']
        sortable: false
        searchable: false
        visible: false
      ,
        targets: adminIndexes['dateNeededTimestamp']
        sortable: false
        searchable: false
        visible: false
      ,
        targets: adminIndexes['searchKeywords']
        visible: false
      ,
        targets: adminIndexes['status']
        visible: false
      ,
        targets: adminIndexes['library']
        visible: true
      ,
        targets: adminIndexes['type']
        visible: false
      ]
    )

    @container = @tableElement.parent()
    @filterContainer = @container.find('.dataTables_filter')
    @searchInput = @filterContainer.find('input')

  setupFilters: ->
    object = @
    @filterContainer.addClass('well').addClass('well-small')
    @filterContainer.html jQuery('.table_filter').html()
    @statusCheckboxes = @filterContainer.find('.request_status_filter input')
    @typeCheckboxes = @filterContainer.find('.request_type_filter input')
    @libraryCheckboxes = @filterContainer.find('.request_library_filter input')
    @searchBox = @filterContainer.find('#filter_keyword')
    @statusTabs = jQuery('.request_status_filter li')
    @container.removeClass('form-inline')

    @searchBox.change ->
      object.applyKeywordFilter()

    @searchBox.keyup ->
      object.applyKeywordFilter()

    @filterOnCheckboxes @statusCheckboxes, ->
      object.applyStatusFilter()

    @filterOnCheckboxes @typeCheckboxes, ->
      object.applyTypeFilter()

    @filterOnCheckboxes @libraryCheckboxes, ->
      object.applyLibraryFilter()

    @statusTabs.click (event) ->
      event.preventDefault()
      link = jQuery(this).find('a')
      object.filterStatus(link.attr('filter'))

  filterOnCheckboxes: (checkboxes, callback) ->
    allCheckbox = checkboxes.filter('.all')
    filterCheckboxes = checkboxes.not('.all')
    checkboxes.click (event) ->
      checkbox = jQuery(this)
      if checkbox.hasClass('all')
        if checkbox.prop('checked')
          filterCheckboxes.prop('checked', false)
        else
          event.preventDefault()
      else
        if checkbox.prop('checked')
          allCheckbox.prop('checked', false)
        else if checkboxes.filter(':checked').length == 0
          allCheckbox.prop('checked', true)
      callback()
      return

    return

  applyKeywordFilter: ->
    @table.search(@searchBox.val())
    @draw()

  applyStatusFilter: ->
    values = @checkboxSearchExpression(@statusCheckboxes)
    @table.column(adminIndexes['status']).search(values, true)
    @draw()

  applyTypeFilter: ->
    values = @checkboxSearchExpression(@typeCheckboxes)
    @table.column(adminIndexes['type']).search(values, true)
    @draw()

  applyLibraryFilter: ->
    values = @checkboxSearchExpression(@libraryCheckboxes)
    @table.column(adminIndexes['library']).search(values, true)
    @draw()

  checkboxSearchExpression: (checkboxes) ->
    values = []
    checkboxes.filter(':checked').each ->
      value = jQuery(this).val()
      if value && value != 'all'
        values.push(value)
    values.join('|')

  draw: ->
    object = @
    setTimeout ->
      object.table.draw()
    , 10


  filterStatus: (status) ->
    if status == 'all'
      value = ''
    else
      value = status
    @statusTabs.removeClass('active').find("a[filter=#{status}]").parent().addClass('active')
    @table.column(adminIndexes['status']).search(value, true)
    @draw()

jQuery ($) ->


  setupAdminDatatable = () ->
    table = $(".admin_datatable")
    if table.size() > 0
      new AdminDataTable(table)

  ready = ->
    setupAdminDatatable()

  $(document).ready ->
    ready()
