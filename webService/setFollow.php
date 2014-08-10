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

	$followingId = mysql_escape_string($_POST['followingId']);
	$type = mysql_escape_string($_POST['type']);
	$followerId = mysql_escape_string($_POST['userId']);
	
	if( $followingId == $followerId ){
		$result = "failed";
		$error = "You can't follow you.";
	}else{
		if( $type == "FOLLOW" ){
			$sql = "select * from rb_friend where rb_following = $followingId and rb_follower = $followerId";
			$dataFriend = $db->queryArray( $sql );
			if( $dataFriend != null ) {
				$result = "failed";
				$error = "You are already following this member.";
			}else{
				$sql = "insert into rb_friend( rb_following, rb_follower, rb_created_time, rb_updated_time )
						value( $followingId, $followerId, now(), now() )";
				$db->queryInsert( $sql );
					
				// Notification
				$sql = "insert into rb_notification(rb_user, rb_sender, rb_type, rb_created_time, rb_updated_time)
						value( $followingId, $followerId, 3, now(), now())";
				$db->queryInsert( $sql );
				
				$dataUser = RB_getUserInfo( $followerId );
				$username = $dataUser['rb_username'];
				
				RB_pushNotiByUser($followingId, "@"."$username is following you", 3, $followerId);
				
				$userUrl = "http://".HOST_SERVER."/profile.php?id=".base64_encode($followerId);
				$subject = "@".$username." is following you";
				$message ="<a href='$userUrl'>"."@".$username."</a> is following you";
				RB_emailNotiByUser( $followingId, $message, $subject, 3 );
				
			}
		}else{
			$sql = "delete from rb_friend where rb_following = $followingId and rb_follower = $followerId";
			$db->query( $sql );
			
			// Notification
			$sql = "insert into rb_notification(rb_user, rb_sender, rb_type, rb_created_time, rb_updated_time)
			value( $followingId, $followerId, 5, now(), now())";
			$db->queryInsert( $sql );
			
			$dataUser = RB_getUserInfo( $followerId );
			$username = $dataUser['rb_username'];
			RB_pushNotiByUser($followingId, "@"."$username is unfollowing you", 5, $followerId);	
			
			$userUrl = "http://".HOST_SERVER."/profile.php?id=".base64_encode($followerId);
			$subject = "@".$username." is unfollowed you";
			$message ="<a href='$userUrl'>"."@".$username."</a> unfollowed you";
			RB_emailNotiByUser( $followingId, $message, $subject, 5 );
			
		}
	}
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
