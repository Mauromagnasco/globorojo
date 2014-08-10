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
    $currentUserId = mysql_escape_string($_POST['currentUserId']);
    
    $sql = "select * from rb_user where rb_user = $userId";
    $dataUser = $db->queryArray( $sql );
	$photo = $dataUser[0]['rb_photo'];
    
	$sql = "select count(*) cnt from rb_video where rb_user = $userId";
	$cntVideos = $db->queryArray( $sql );
	$cntVideos = $cntVideos[0]['cnt'];
	
	$sql = "select count(*) cnt from rb_friend where rb_following = $userId";
	$cntFollowers = $db->queryArray( $sql );
	$cntFollowers = $cntFollowers[0]['cnt'];
	
	$sql = "select count(*) cnt from rb_friend where rb_follower = $userId";
	$cntFollowing = $db->queryArray( $sql );
	$cntFollowing = $cntFollowing[0]['cnt'];
	
	$followingId = $userId;
	$followerId = $currentUserId;

	$sql = "select * from rb_friend where rb_following = $followingId and rb_follower = $followerId";
	$dataResult = $db->queryArray( $sql );
	if( $dataResult == null ){
		$isFollowing = "N";
	}else{
		$isFollowing = "Y";
	}
	
	$sql = "select * from rb_friend where rb_following = $followerId and rb_follower = $followingId";
	$dataResult = $db->queryArray( $sql );
	if( $dataResult == null ){
		$isFollower = "N";
	}else{
		$isFollower = "Y";
	}
	
	$sql = "select count(*) cnt, ifnull( avg( rb_video_score) , 0 ) as score, rb_hashtag from rb_video where rb_user = $userId group by rb_hashtag
			union all
			select 1, 1 as score, rb_hashtag
			  from (
			select t2.rb_hashtag
			  from rb_user_video_score t1, rb_video t2
			 where t1.rb_user = $userId
			   and t1.rb_video = t2.rb_video
			 group by t2.rb_hashtag ) t1
			 where t1.rb_hashtag not in ( select rb_hashtag from rb_video where rb_user = $userId )";
	$sql = "select count(*) cnt, ifnull( avg( rb_video_score) , 0 ) as score, rb_hashtag from rb_video where rb_user = $userId group by rb_hashtag";
	$sql = "select * from ($sql) t1 order by score desc";
	$categoryList = $db->queryArray( $sql );
	if( $categoryList == null ){
		$categoryList = array();
	}
	
	$data['categoryList'] = $categoryList;
	$data['rb_username'] = $dataUser[0]['rb_username'];
	$data['rb_name'] = $dataUser[0]['rb_name'];
	$data['rb_cred'] = $dataUser[0]['rb_cred'];
	$data['rb_email'] = $dataUser[0]['rb_email'];
	$data['isFollowing'] = $isFollowing;
	$data['isFollower'] = $isFollower;
	$data['photo'] = RB_photoURL( $photo );
	$data['cntVideos'] = $cntVideos;
	$data['cntFollowers'] = $cntFollowers;
	$data['cntFollowing'] = $cntFollowing;
		
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
