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

    function getUsernameList( $str ){
    	$usernameList = array( );
    	$arr = explode( "@", $str );
    	for( $i = 1; $i < count( $arr ); $i ++ ){
    		$part1 = explode( " ", $arr[$i] );
    		$part2 = explode( "?", $part1[0] );
    		$part3 = explode( ",", $part2[0] );
    		$part4 = explode( ":", $part3[0] );
    		$part5 = explode( ")", $part4[0] );
    		$part6 = explode( "!", $part5[0] );
    		$part7 = explode( ";", $part6[0] );
    		$username = $part6[0];
    		$usernameList[] = $username;
    	}
    	return $usernameList;
    }    
    
    $userId = mysql_escape_string($_POST['userId']);
    $videoId = mysql_escape_string($_POST['videoId']);
    $txtComment = mysql_escape_string($_POST['txtComment']);

    $new_str = str_replace(' ', '', $txtComment);
    $new_str = preg_replace( "/\r|\n/", "", $new_str );
    if( $new_str != "" ){
	    $sql = "select rb_user from rb_video where rb_user = $userId";
	    $dataResult = $db->queryArray( $sql );
	    $creatorId = $dataResult[0]['rb_user'];
	    
	    
	    $sql = "insert into rb_user_video_comment( rb_user, rb_video, rb_content, rb_created_time, rb_updated_time)
	    		value( $userId, $videoId, '$txtComment', now(), now() )";
	    $db->queryInsert( $sql );
	    $commentId = $db->getPrevInsertId();
	    
	    $usernameList = getUsernameList( $txtComment );
	    for( $i = 0; $i < count( $usernameList ); $i ++ ){
	    	$sql = "select * from rb_user where rb_username = '".$usernameList[$i]."'";
	    	$dataResult = $db->queryArray( $sql );
	    	if( $dataResult != null ){
	    		$receiverId = $dataResult[0]['rb_user'];
	    		
	    		$sql = "select * from rb_user where rb_user = $userId";
	    		$dataUser = $db->queryArray( $sql );
	    		$username = $dataUser[0]['rb_username'];
	    		
	    		if( $creatorId != $receiverId ){
	    			$sql = "insert into rb_notification(rb_user, rb_content, rb_sender, rb_video, rb_type, rb_created_time, rb_updated_time)
	    					 value ( $receiverId, '', $userId, $videoId, 4, now(), now())";
	    			$db->queryInsert( $sql );
	    			RB_pushNotiByUser( $receiverId, "@"."$username mentioned you", 4, $userId );
	    			
	    			$userUrl = "http://".HOST_SERVER."/profile.php?id=".base64_encode($userId);
	    			$videoUrl = "http://".HOST_SERVER."/video.php?id=".base64_encode($videoId);
	    			
	    			$message ="<a href='$userUrl'>"."@".$username."</a> mentioned you in a <a href='$videoUrl'>comment</a>";
	    			$subject = "@".$username." mentioned you in a comment";
	    			RB_emailNotiByUser( $receiverId, $message, $subject, 4 );
	    		}
	    	}
	    		
	    	
	    }
	    
	    // Notification
	    $sql = "select * from rb_video where rb_video = $videoId";
	    $dataVideo = $db->queryArray( $sql );
	    $dataVideo = $dataVideo[0];
	    $receiverId = $dataVideo['rb_user'];
	    
	    $sql = "select * from rb_user where rb_user = $userId";
	    $dataUser = $db->queryArray( $sql );
	    $dataUser = $dataUser[0];
	    $username = $dataUser['rb_username'];
	    
	    if( $creatorId != $receiverId ){
		    $sql = "insert into rb_notification(rb_user, rb_content, rb_sender, rb_video, rb_type, rb_created_time, rb_updated_time)
		    		value( $receiverId, '$txtComment', $userId, $videoId, 1, now(), now())";
		    $db->queryInsert( $sql );
		    
		    $receiverData = RB_getUserInfo( $receiverId );
		    RB_pushNotiByUser( $receiverId, "@"."$username commented your post", 1, $videoId );
		    
		    $userUrl = "http://".HOST_SERVER."/profile.php?id=".base64_encode($userId);
		    $videoUrl = "http://".HOST_SERVER."/video.php?id=".base64_encode($videoId);
		    
		    $message ="<a href='$userUrl'>"."@".$username."</a> commented your <a href='$videoUrl'>post</a>";
		    $subject = "@".$username." commented your post";
		    RB_emailNotiByUser( $receiverId, $message, $subject, 1 );
		    
		}
	    

	    
	    $data['userId'] = $userId;
	    $data['commentId'] = $commentId;
	    $data['username'] = $username;
    }else{
    	$result = "failed";
    }
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);  
?>
