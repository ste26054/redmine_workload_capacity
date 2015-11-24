function convert_daily_hours()
{
	var	weekly_hours_field = document.getElementById('weekly_basis_hours_id');
	var daily_hours = ""

	if(weekly_hours_field.value != ""){
	daily_hours = weekly_hours_field.value/5;
	}
	var daily_hours_field = document.getElementById('daily_basis_hours_id');
	daily_hours_field.innerHTML = daily_hours;

update_hours_from_threshold(document.getElementById('low_danger_id'), 'low_danger_hours_id', false);
update_hours_from_threshold(document.getElementById('low_accept_id'), 'low_accept_hours_id', false);
update_hours_from_threshold(document.getElementById('high_accept_id'), 'high_accept_hours_id', true);
update_hours_from_threshold(document.getElementById('high_danger_id'), 'high_danger_hours_id', true);

}

function update_hours_from_threshold(this_field, id_field_to_change, type_operation){
	//type_operation false: soustraction, true: addition
	var daily_hours_value = document.getElementById('daily_basis_hours_id').innerHTML;
	var threshold_value = this_field.value;
	var field_to_change = document.getElementById(id_field_to_change);
	var result = "-";
	if(threshold_value != "" && daily_hours_value != ""){
		daily_hours_value = Number(daily_hours_value);
		if(type_operation){
			// addition
			result = (1+(threshold_value/100))*daily_hours_value;
		}else{
			//soustraction
			result = (1-(threshold_value/100))*daily_hours_value;
		}
		field_to_change.innerHTML = result.toFixed(2);
	}else{
		field_to_change.innerHTML = result;
	}
}