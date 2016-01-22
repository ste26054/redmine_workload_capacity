function toggleGroup(){

    $(".tog").toggle();
    
}

function disable_link(this_field){

	$('#ajax-indicator').show();
	this_field.style.display="none";
}

function loading_action(this_field){

	this_field.parentNode.innerHTML = "<img alt=\"loading\" src=\"/../images/loading.gif\" />";
}

function update_footer(){
	palloc_average_field = document.getElementById("palloc_average_id");
	list = document.getElementsByClassName("member_palloc_average_class");
	sum_value = 0;
	result = 0;
	if(list.length != 0){
		for(i=0; i<list.length; i++){
			sum_value += Number(list[i].innerHTML);
		}
		result = Math.round(sum_value/list.length);
	}
	palloc_average_field.innerHTML = result;
}

function delete_contentline_rows(member_id){
	old_rows = document.getElementsByName("wlmember"+member_id+"-contentline");
	wltable = document.getElementById("wltable");
	if(old_rows.length >0){
		var index = 0;
		for(i=old_rows.length-1; i>=0; i-- )
		{
			index = old_rows[i].rowIndex;
			wltable.deleteRow(index);
		}

	}
}


function refresh_member_contentline(project_id, member_id, flash_msg, notice_flash){
	$.ajax({
	      url: '/projects/'+project_id+'/workload/update_wlconfigure/'+member_id,
	      cache: false,
	      beforeSend: function(){
	      	$('#ajax-indicator').show();
	        	      },
	      success: function(data){
			delete_contentline_rows(member_id);
			$("table #wlmember"+member_id+"-nameline").after(data);
			update_footer();
			if(flash_msg != "" ){
				field_flash =  document.getElementById('flash');
				field_flash.innerHTML = "";
				if(notice_flash == false){
					field_flash.className= "flash error";
				}else{
					field_flash.className= "flash notice";
				}
				field_flash.innerHTML = flash_msg+" ";
	      	}
	      }

	});
	
}
