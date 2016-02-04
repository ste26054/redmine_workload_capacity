function draw_graph(gr_id, gr_title, gr_subtitle, category_data, series_data){
// category_data = document.getElementById("category_data").InnerHTML
// series_data = document.getElementById("series_data").InnerHTML
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
            // categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                // 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
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
        series: 
        series_data
        // [{
        //     name: 'Steph',
        //     data: entry_data_1
        // }, {
        //     name: 'Fabien',
        //     data: entry_data_2
        // }]
        // [{
        //     name: 'Tokyo',
        //     data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6]
        // }, {
        //     name: 'New York',
        //     data: [-0.2, 0.8, 5.7, 11.3, 17.0, 22.0, 24.8, 24.1, 20.1, 14.1, 8.6, 2.5]
        // }, {
        //     name: 'Berlin',
        //     data: [-0.9, 0.6, 3.5, 8.4, 13.5, 17.0, 18.6, 17.9, 14.3, 9.0, 3.9, 1.0]
        // }, {
        //     name: 'London',
        //     data: [3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]
        // }]
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