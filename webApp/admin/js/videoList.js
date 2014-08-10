/**
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 */
$(document).ready(function() {
	$('#example').dataTable( {
		"sDom": "<'row'<'span6'l><'span6'f>r>t<'row'<'span6'i><'span6'p>>",
		"sPaginationType": "bootstrap",
		"aaSorting": [],
		"oLanguage": {
			"sLengthMenu": "_MENU_ records per page"
		},
        "aoColumnDefs": [
                         { 
                             "bSortable": false, 
                             "aTargets": [ 0 ]
                         } 
                     ]
	} );
} );
function onCheckAll( obj ){
	if( obj.checked ){
		$("table#example").find("input:checkbox").prop("checked", true);
	}else{
		$("table#example").find("input:checkbox").prop("checked", false);
	}
}
function onDeleteVideo( ){
	var objList = $("table#example").find("input#chkVideoId:checkbox:checked");
	if( objList.length == 0 ){ alert("Please select Videos to delete."); return;}
	var strIds = "";
	for( var i = 0 ; i < objList.length; i ++ ){
		strIds += objList.eq(i).val();
		if( i != objList.length - 1 )
			strIds += ",";
	}
	if( !confirm("Are you sure?") ){ return; }
    $.ajax({
        url: "async-deleteVideo.php",
        dataType : "json",
        type : "POST",
        data : { videoIds : strIds },
        success : function(data){
            if(data.result == "success"){
            	alert("Videos deleted succesfully.");
            	window.location.reload(); 
            }
        }
    });	
}
function onAddUser( ){
	window.location.href = "userDetail.php";
}