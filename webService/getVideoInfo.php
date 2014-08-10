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

    $videoId = mysql_escape_string($_POST['videoId']); 
    
	$sql = "
		select t1.*, t2.rb_username, t2.rb_photo, t2.rb_cred
			 , second(timediff( now(), t1.rb_created_time )) as seconds
		     , minute(timediff( now(), t1.rb_created_time )) as minutes
		     , hour(timediff( now(), t1.rb_created_time )) as hours
		     , datediff( now(), t1.rb_created_time ) as days
		     , month(datediff( now(), t1.rb_created_time )) as months
		  from rb_video t1, rb_user t2
		 where t1.rb_user = t2.rb_user
		   and t1.rb_video = $videoId";
	
	$videoList = $db->queryArray( $sql );

	for( $i = 0 ; $i < count( $videoList ); $i ++ ){
		$months = $videoList[$i]['months'];
		$days = $videoList[$i]['days'];
		$hours = $videoList[$i]['hours'];
		$minutes = $videoList[$i]['minutes'];
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
	
		$videoId = $videoList[$i]['rb_video'];
		$sql = "select t1.*, t2.rb_username
				  from rb_user_video_comment t1, rb_user t2
				 where t1.rb_video = $videoId
				   and t1.rb_user = t2.rb_user
				 order by t1.rb_created_time asc";
		$commentList = $db->queryArray( $sql );
		if( $commentList == null )
			$commentList = array( );
	
		$videoList[$i]['commentList'] = $commentList;
		$videoList[$i]['timeAgo'] = $timeAgo;
		$videoList[$i]['rb_photo'] = RB_photoURL( $videoList[$i]['rb_photo'] );
		
		$videoList[$i]['videoURL'] = RB_videoUrl( $videoList[$i]['rb_video_type'], $videoList[$i]['rb_video_url'] );	
		if( $videoList[$i]['rb_video_type'] == "V" ){
			$data['videoIPhone'] = "http://vimeo.com/".RB_getVimeoId( $videoList[$i]['rb_video_url'] );
		}
	}
	if( $videoList == null )
		$videoList = array( );
	
    $data['videoItem'] = $videoList[0];
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
