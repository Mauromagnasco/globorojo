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

    $type = mysql_escape_string($_POST['type']); // 0 : date, 1 : score, 2 : cred
    $period = mysql_escape_string($_POST['period']); // 1 : daily, 2 : weekly, etc : always
    $txtKeyword = mysql_escape_string($_POST['txtKeyword']);
    
    $cntLoaded = mysql_escape_string($_POST['cntLoaded']);
    $currentTime = mysql_escape_string($_POST['currentTime']);
    $cntLazyLoad = mysql_escape_string($_POST['cntLazyLoad']);
    $sort = mysql_escape_string($_POST['sort']);
    
    if( $sort == 2 ) $sort = "asc";
    else $sort = "desc";    
    
	$sql1 = "
		select t1.*, t2.rb_username, t2.rb_photo, t2.rb_cred
			 , second(timediff( now(), t1.rb_created_time )) as seconds
		     , minute(timediff( now(), t1.rb_created_time )) as minutes
		     , hour(timediff( now(), t1.rb_created_time )) as hours
		     , datediff( now(), t1.rb_created_time ) as days
		     , month(datediff( now(), t1.rb_created_time )) as months		
		  from rb_video t1, rb_user t2
		 where t1.rb_user = t2.rb_user
		   and t1.rb_created_time < '$currentTime'";
	if( $period == 1 && $type == 1){
		$sql1 .= " and date(t1.rb_created_time) = date( now() )";
	}else if( $period == 2 && $type == 1 ){
		$sql1 .= " and t1.rb_created_time > concat(date(date_sub(now(), interval weekday( now( ) ) day)),' 00:00:00')";
	}
	
	$sql = "select t1.*
			  from ( $sql1 ) t1
			  left join rb_user_video_comment t2 on t1.rb_video = t2.rb_video";
	
	
	if( $type == 0 ){
		if( $txtKeyword != "" ){
			$sql.=" where t1.rb_hashtag like '%$txtKeyword%' or t2.rb_content like '%$txtKeyword%'";
		}
		$sql.=" group by t1.rb_video";
		$sql.=" order by t1.rb_created_time $sort";
	}else if( $type == 1 ){
		if( $txtKeyword != "" ){
			$sql.=" where t1.rb_hashtag like '%$txtKeyword%' or t2.rb_content like '%$txtKeyword%'";
		}
		$sql.=" group by t1.rb_video";
		$sql.=" order by t1.rb_video_score $sort, t1.rb_video";
	}else if( $type == 2 && $txtKeyword == "" ){
		$sql.=" group by t1.rb_video";
		$sql.=" order by t1.rb_cred $sort, t1.rb_created_time $sort";  
	}else{
		$sql = $sql1." and t1.rb_hashtag = '$txtKeyword'";
		
		$sql1 = "select rb_user, avg( rb_video_score ) as rb_category_merit
				   from rb_video
				  where rb_created_time < '$currentTime'
				    and rb_hashtag = '$txtKeyword'
				  group by rb_user";
		
		$sql = "select t1.*, ifnull(t2.rb_category_merit, 0) rb_category_merit
				  from ( $sql ) t1
				  left join ( $sql1 ) t2
				    on t1.rb_user = t2.rb_user
				 order by rb_category_merit $sort, rb_video_score $sort";
	}
	
	
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
	$videoList = $db->queryArray( $sql );
	if( $videoList == null )
		$videoList = array( );
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
		$videoList[$i]['rb_photo'] = RB_photoURL($videoList[$i]['rb_photo']);
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
		
		$videoList[$i]['videoURL'] = RB_videoUrl( $videoList[$i]['rb_video_type'], $videoList[$i]['rb_video_url'] );
		
	}
	if( $videoList == null )
		$videoList = array( );
    $data['videoList'] = $videoList;
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
