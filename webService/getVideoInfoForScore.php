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
    $userId = mysql_escape_string($_POST['userId']);
    
    $sql = "select rb_count as cnt from rb_video_view_count where rb_video = $videoId";
    $cntView = $db->queryArray( $sql );
    if( $cntView == null )
    	$cntView = 0;
    else
    	$cntView = $cntView[0]['cnt'];
    
    $sql = "select rb_count as cnt from rb_video_share_count where rb_video = $videoId";
    $cntShare = $db->queryArray( $sql );
    if( $cntShare == null )
    	$cntShare = 0;
    else
    	$cntShare = $cntShare[0]['cnt'];
    
    $sql = "select count(*) as cnt from rb_user_video_comment where rb_video = $videoId";
    $cntComment = $db->queryArray( $sql );
    $cntComment = $cntComment[0]['cnt'];
    
    $sql = "select count(*) as cnt from rb_user_video_score where rb_video = $videoId";
    $cntScore = $db->queryArray( $sql );
    $cntScore = $cntScore[0]['cnt'];    
    
    $sql = "select * from rb_video where rb_video = $videoId";
    $dataVideo = $db->queryArray( $sql );
    $dataVideo = $dataVideo[0];
    
    $sql = "select t1.*, t2.rb_username 
    		  from rb_user_video_score t1, rb_user t2 
    		 where t1.rb_video = $videoId
    		   and t1.rb_user = t2.rb_user";
    $scoreList = $db->queryArray( $sql );
    if( $scoreList == null )
    	$scoreList = array( );

    $sql = "select * from rb_user_video_score where rb_video = $videoId and rb_user = $userId";
    $dataScore = $db->queryArray( $sql );
    if( $dataScore == null ){
    	$isScored = "N";
    	$givenScore = $dataVideo['rb_video_score'];
    }else{
    	$isScored = "Y";
    	$givenScore = $dataVideo['rb_video_score'];
    	// $givenScore = $dataScore[0]['rb_score'];    	
    }
    
    $data['isScored'] = $isScored;
    $data['givenScore'] = $givenScore;
    $data['cntView'] = $cntView;
    $data['cntShare'] = $cntShare;
    $data['cntComment'] = $cntComment;
    $data['cntScore'] = $cntScore;
    $data['dataVideo'] = $dataVideo;
    $data['scoreList'] = $scoreList;
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>