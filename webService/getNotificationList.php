<?php
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
	require_once("../common/DB_Connection.php");	
    require_once("../common/functions.php");
    require_once("../common/checkAuth.php");

    $result = "success";
    $error = "";
    $data = array();
    
    $userId = mysql_escape_string($_POST['userId']);
    $cntLoaded = mysql_escape_string($_POST['cntLoaded']);
    $currentTime = mysql_escape_string($_POST['currentTime']);
    $cntLazyLoad = mysql_escape_string($_POST['cntLazyLoad']);
    
	$sql = "
			select t1.*, t2.rb_photo rb_sender_photo, t2.rb_username rb_sender_username
				 , second(timediff( now(), t1.rb_created_time )) as seconds
			     , minute(timediff( now(), t1.rb_created_time )) as minutes
			     , hour(timediff( now(), t1.rb_created_time )) as hours
			     , datediff( now(), t1.rb_created_time ) as days
			     , month(datediff( now(), t1.rb_created_time )) as months 
			  from rb_notification t1, rb_user t2
			 where t1.rb_sender = t2.rb_user
			   and t1.rb_user = $userId
			   and t1.rb_created_time < '$currentTime'
			 order by t1.rb_created_time desc";
	
	$sql = "
		select *
		  from (
		  		select t.*, @rownum := @rownum + 1 AS rownum
				  from (
					$sql
					   ) t, (select @rownum := 0 ) r
				) tt
		 where tt.rownum > $cntLoaded
		 limit $cntLazyLoad";	
	$notificationList = $db->queryArray( $sql );
	if( $notificationList == null )
		$notificationList = array( );
	for( $i = 0 ; $i < count( $notificationList ); $i ++ ){
		$months = $notificationList[$i]['months'];
		$days = $notificationList[$i]['days'];
		$hours = $notificationList[$i]['hours'];
		$minutes = $notificationList[$i]['minutes'];
		$seconds = $notificationList[$i]['seconds'];
		if( $months == 1 ) $timeAgo = "1 month ago";
		else if( $months > 1 ) $timeAgo = $months." months ago";
		else if( $days == 1 ) $timeAgo = "yesterday";
		else if( $days > 1 ) $timeAgo = $days." days ago";
		else if( $hours == 1 ) $timeAgo = "1 hour ago";
		else if( $hours > 1 ) $timeAgo = $hours." hours ago";
		else if( $minutes == 1 ) $timeAgo = " 1 minute ago";
		else if( $minutes > 1 ) $timeAgo = $minutes." minutes ago";
		else if( $seconds > 0 ) $timeAgo = $seconds." seconds ago";
		else $timeAgo = "undefined";
		$notificationList[$i]['timeAgo'] = $timeAgo;
		$notificationList[$i]['rb_sender_photo'] = RB_photoURL( $notificationList[$i]['rb_sender_photo'] );
	}
	$data['notificationList'] = $notificationList;
	if( $notificationList == null )
		$notificationList = array( );	
		
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
