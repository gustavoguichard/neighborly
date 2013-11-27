Neighborly.Admin ?= {} if Neighborly.Admin is undefined
Neighborly.Admin.Modules ?= {} if Neighborly.Admin.Modules is undefined

Neighborly.Admin.Modules.Sort = Backbone.View.extend
  el: ".admin"

  events:
    "click [data-sort]": "sort"

  initialize: ->
    @form = @$("form")
    @table = @$(".data-table")
    @selectSorting()

  getSorting: ->
    sortField = @form.find("[name=order_by]")
    sort = sortField.val().split(" ")
    field: sort[0]
    order: sort[1]

  selectSorting: ->
    link = @$("a[data-sort=\"" + @getSorting().field + "\"]")
    sortOrder = link.siblings("span.sort-order")

    # Clean old sort orders
    @$("[data-sort]").siblings("span.sort-order").html ""

    # Add sorting order to header
    if @getSorting().order is "DESC"
      sortOrder.html "(desc)"
    else
      sortOrder.html "(asc)"

  sort: (event) ->
    link = $(event.target)
    sortField = @form.find("[name=order_by]")

    # Put sorting data in hidden field and select sorting
    sortField.val link.data("sort") + " " + ((if @getSorting().order is "ASC" then "DESC" else "ASC"))
    @selectSorting()
    @form.submit()
    false

