function draw_graph(gr_id, gr_title, gr_subtitle, category_data, series_data){
    $("#gr"+gr_id+"_container").highcharts({
        title: {
            text: gr_title,
            x: -20 //center
        },
        subtitle: {
            text: gr_subtitle,
            x: -20
        },
        xAxis: {
                categories : category_data
        },
        yAxis: {
            title: {
                text: " "
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        }, 
        // tooltip: {
        //     valueSuffix: yAxis_unity
        // },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            borderWidth: 0
        },
        series: series_data
    });
    
}

function entry_type_change(wlroles_list_json, wlusers_list_json){
    entry_type_value = document.getElementById("entry_type").value;
        $("#entry_id").empty();
    if(entry_type_value == "User"){
        $(wlusers_list_json).each(function(i) {  //list of users as option 
            $("#entry_id").append("<option value=\"" + wlusers_list_json[i][1] + "\">" + wlusers_list_json[i][0] + "</option>")
        });
    }else{
         $(wlroles_list_json).each(function(i) {  //list of users as option 
            $("#entry_id").append("<option value=\"" + wlroles_list_json[i][1] + "\">" + wlroles_list_json[i][0] + "</option>")
        });
    }

}

function entry_id_change(){
    entry_type_value = document.getElementById("entry_type").value;
    entry_id_count = document.getElementById("entry_id").selectedOptions.length;
    operation_field = document.getElementById("operation");   
    

      operation_field.disabled = false;
    if(entry_type_value == "User"){
        if(entry_id_count > 1){
            operation_field.disabled = false;
        }else{
            operation_field.disabled = true;
        }
    }else{
        operation_field.disabled = false;
    } 

    if(operation_field.disabled){
        $("#operation_div").hide();
    }
    else{   //choose the operation to do (sum, average, max, min)
        $("#operation_div").show();
    }
    // else : always giving a type of operation if the entry_type is a role
        
}

function delete_graph_div(graph_id){
    graph_div = document.getElementById("gr"+graph_id+"_block");
    graph_div.parentNode.removeChild(graph_div);
}


function initGrDashSortable(list, url) {
  $('#list-'+list).sortable({
    connectWith: '.block-receiver',
    tolerance: 'pointer',
    update: function(){
      $.ajax({
         url: url,
        type: 'post',
        data: {'blocks': $.map($('#list-'+list).children(), function(el){return $(el).attr('id');})}
      });
    }
  });
  $("#list-top, #list-left, #list-right").disableSelection();
}



function preview_graph(project_id, gr_graph_id){
    $.ajax({
          url: '/projects/'+project_id+'/gr_graphs/'+gr_graph_id+'/preview',
          cache: false,
          beforeSend: function(){
            $('#ajax-indicator').show();
                      },
          success: function(data){
            $("#gr-content").html(data);
          }

    });
    
}