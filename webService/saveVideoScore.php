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
    	$videoId = mysql_escape_string($_POST['videoId']);
    	$score = mysql_escape_string($_POST['score']);
    	
    	$sql = "select * from rb_video where rb_video = $videoId";
    	$dataCreator = $db->queryArray( $sql );
    	$dataCreator = $dataCreator[0];
    	$creatorId = $dataCreator['rb_user'];    	
    	if( $userId == $creatorId ){
    		$result = "failed";
    		$error = "You can't give score on your Video.";
    	}else{    		
	    	$sql = "select count(*) cnt from rb_user_video_score where rb_user = $userId and rb_video = $videoId";
	    	$dataResult = $db->queryArray( $sql );
	    	$cnt = $dataResult[0]['cnt'];
	    	if( $cnt == 0 ){
	    		// 1. Get Rater's CRED
	    		
	    		$hashtag = $dataCreator['rb_hashtag'];
	    		// logToFile("data.log", "HASHTAG : $hashtag");
	    		$sql = "select avg(rb_video_score) as rb_video_score from rb_video where rb_user = $userId and lcase(rb_hashtag) = lcase('$hashtag') group by rb_hashtag";
	    		$dataResult = $db->queryArray( $sql );
	    		if( $dataResult == null )
	    			$cred = 1;
	    		else
	    			$cred = $dataResult[0]['rb_video_score'];
	    		
	    		$sql = "select * from rb_user where rb_user = $userId";
	    		$dataUser = $db->queryArray( $sql );
	    		$dataUser = $dataUser[0];	    		
	    		$username = $dataUser['rb_username'];
	    			    		
	    		// 2. Save User's Video Score
	    		$sql = "insert into rb_user_video_score( rb_user, rb_video, rb_user_cred, rb_score, rb_created_time, rb_updated_time)
	    				values( $userId, $videoId, $cred, $score, now(), now() )";
	    		$db->queryInsert( $sql );
	    		
	    		// logToFile("data.log", "2-SQL : $sql");
	    		    		
	    		// 3. Get Video's Give Score List
	    		$sql = "select * 
	    				  from rb_user_video_score
	    				 where rb_video = $videoId";
	    		$videoScoreList = $db->queryArray( $sql );
	    		// logToFile("data.log", "3-SQL : $sql");
	    		
	    		// 4. Calculate Video's Score and Update
	    		$sumCred = 0;
	    		$sumCredScore = 0;
	    		for( $i = 0; $i < count( $videoScoreList ); $i ++ ){
	    			$sumCredScore += $videoScoreList[$i]['rb_user_cred'] * $videoScoreList[$i]['rb_score'];
	    			$sumCred += $videoScoreList[$i]['rb_user_cred'];
	    		}
	    		if( round($sumCred) == 0 ){
	    			$videoScore = 0;
	    		}else{
	    			$videoScore = $sumCredScore / $sumCred;
	    		}
	    		
	    		$sql = "update rb_video set rb_video_score = $videoScore where rb_video = $videoId";
	    		$db->query( $sql );
	    		
	    		// 5. Get Video Creator Info
	    		$sql = "select * from rb_video where rb_video = $videoId";
	    		$dataCreator = $db->queryArray( $sql );
	    		$dataCreator = $dataCreator[0];
	    		$creatorId = $dataCreator['rb_user'];
	    		// logToFile("data.log", "5-SQL : $sql");
	    		// logToFile("data.log", "5-CREATOR ID = $creatorId");
	    		
	    		
	    		// 6. Get Video List Created By Creator
	    		$sql = "select avg(rb_video_score) as rb_video_score, rb_hashtag  from rb_video where rb_user = $creatorId group by rb_hashtag";
	    		$sql = "select avg( rb_video_score ) rb_video_score from ($sql) t";
	    		$avgVideoScore = $db->queryArray( $sql );
	    		if( $avgVideoScore == null ){
	    			$avgVideoScore = 0;
	    		}else{
	    			$avgVideoScore = $avgVideoScore[0]['rb_video_score'];
	    		}
	    		
	    		$sql = "update rb_user set rb_cred = $avgVideoScore where rb_user = $creatorId";
	    		$db->query( $sql );
	    		// logToFile("data.log", "6-SQL : $sql");
	    		$data["videoScore"] = $videoScore;
	    		$data["username"] = $username;
	    		$data["userId"] = $userId;
	    		// Notification
	    		$sql = "insert into rb_notification(rb_user, rb_content, rb_sender, rb_video, rb_type, rb_created_time, rb_updated_time)
	    				value( $creatorId, '$score', $userId, $videoId, 2, now(), now())";
	    		$db->queryInsert( $sql );
	    		
	    		$dataCreator = RB_getUserInfo( $creatorId );
	    		RB_pushNotiByUser($creatorId, "@"."$username scored your post", 2, $videoId);
	    		
	    		$userUrl = "http://".HOST_SERVER."/profile.php?id=".base64_encode($userId);
	    		$videoUrl = "http://".HOST_SERVER."/video.php?id=".base64_encode($videoId);
	    		
	    		$message ="<a href='$userUrl'>"."@".$username."</a> scored your <a href='$videoUrl'>post</a>";
	    		$subject = "@".$username." scored your post";
	    		RB_emailNotiByUser( $receiverId, $message, $subject, 2 );
	    	}else{
	    		$result = "failed";
	    		$error = "You've already give score on this Video.";
	    	}
		}
		    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
