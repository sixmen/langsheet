function saveSelection() {
  var unchecked = $('#select_lang input:not(:checked)').map(function () {
    return $(this).attr('data-name');
  });
  localStorage.setItem('unchecked', JSON.stringify(unchecked.get()));
}

function loadSelection() {
  var unchecked = JSON.parse(localStorage.getItem('unchecked'));
  for (var i=0;i<unchecked.length;i++) {
    var el = $("#select_lang input[data-name='" + unchecked[i] + "']");
    el.prop('checked', false);
    hideColumn(el.parent().index()+2);
  }
  updateRows();
}

function showColumn(index) {
  $('#sheet thead th:nth-child(' + index + ')').show();
  $('#sheet tr td:nth-child(' + index + ')').show();
}

function hideColumn(index) {
  $('#sheet thead th:nth-child(' + index + ')').hide();
  $('#sheet tr td:nth-child(' + index + ')').hide();
}

function updateRows() {
  $('tr.item').each(function () {
    var visibles = $(this).find('td').filter(function (index) {
      return index>0 && $(this).css('display')!=='none' && !$(this).hasClass('no_information') && !$(this).hasClass('not_applicable');
    });
    if (visibles.length===0) {
      $(this).hide();
    } else {
      $(this).show();
    }
  });
  $('tbody').each(function () {
    var visibles = $(this).find('tr.item').filter(function (index) {
      return $(this).css('display')!=='none';
    });
    if (visibles.length===0) {
      $(this).hide();
    } else {
      $(this).show();
    }
  });
}

$(document).on('change', '#select_lang input', function () {
  var index = Number(this.value)+2
    , show = this.checked;
  if (show) {
    showColumn(index);
  } else {
    hideColumn(index);
  }
  updateRows();
  saveSelection();
});

$('.item_note:first-child').qtip({
  position: {
    at: 'top right',
    my: 'top left'
  }
});
$('.item_note:not(:first-child)').qtip({
  position: {
    at: 'top left',
    my: 'top right'
  }
});

$(loadSelection);
