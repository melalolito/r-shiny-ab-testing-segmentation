// Listen variants checkbox click event and don't allow more than 2 selections
$(document).on("click", 'input[name="variants_select"]', function(event){
  if($("div.checkbox input[name=variants_select]:checked").length > 2)
  {
    event.preventDefault();
  }
});
