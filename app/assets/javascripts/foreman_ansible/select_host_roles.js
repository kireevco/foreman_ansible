function load_ansible_role(item) {
  var url = $(item).attr('data-url');
  if (url == undefined) return; // no parameters
  var placeholder = $('<tr id="puppetclass_'+id+'_params_loading">'+
      '<td colspan="5">' + spinner_placeholder(__('Loading parameters...')) + '</td></tr>');
  $('#inherited_puppetclasses_parameters').append(placeholder);
  $.ajax({
    url: url,
    type: 'get',
    data: data,
    success: function(result, textstatus, xhr) {
      var params = $(result);
      placeholder.replaceWith(params);
      params.find('a[rel="popover"]').popover();
      if (params.find('.error').length > 0) $('#params-tab').addClass('tab-error');
    }
  });
}
