$(document).ready(function() {
  bindCategoryEvents();
});

function bindCategoryEvents() {
  $('.category').unbind();
  jQuery('.category').droppable({
    drop: function(ev, ui) {
      var droppedOn = jQuery(this);
      jQuery.ajax({
        type: 'PUT',
        url: '/admin/categories/' + encodeURIComponent(jQuery(ui.draggable).attr('data-id')) + '.js',
        data: { category: { parent_id: $(this).attr('data-id') } }
      });
    },
    hoverClass: 'hovering'
  });
  $('.category_root .category').droppable('option', 'greedy', true);

  $('.category_name').draggable({
    revert: 'invalid',
    opacity: 0.7,
    zIndex: 10000,
    helper: function(event) {
      return $('<div class="category">' + $(this).text() + '</div>');
    }
  });

  $('.disclosure').unbind();
  $('.disclosure').click(function(e) {
    var categoryId = $(this).attr('data-id');
    expandDisclosure(categoryId);
  });
}

function expandDisclosure(categoryId) {
  var disclosure = $('#disclosure_' + categoryId);
  if (disclosure.is('.collapsed')) {
    disclosure.removeClass('collapsed');
    disclosure.removeClass('expanded');

    var opts = {
      lines: 7, // The number of lines to draw
      length: 0, // The length of each line
      width: 4, // The line thickness
      radius: 3, // The radius of the inner circle
      corners: 1, // Corner roundness (0..1)
      rotate: 0, // The rotation offset
      color: '#000', // #rgb or #rrggbb
      speed: 1, // Rounds per second
      trail: 60, // Afterglow percentage
      shadow: false, // Whether to render a shadow
      hwaccel: true, // Whether to use hardware acceleration
      className: 'spinner', // The CSS class to assign to the spinner
      zIndex: 2e9, // The z-index (defaults to 2000000000)
      top: 'auto', // Top position relative to parent in px
      left: 'auto' // Left position relative to parent in px
    };
    var spinner = new Spinner(opts).spin(disclosure[0]);

    $.get(
      '/admin/categories.js',
      { parent_id: categoryId },
      function(data) {
        spinner.stop();
        disclosure.addClass('expanded');
        bindCategoryEvents();
      }
    );
  }
  else {
    disclosure.removeClass('expanded');
    disclosure.addClass('collapsed');
    $('#category_' + categoryId + "_children").html('');
  }
}
