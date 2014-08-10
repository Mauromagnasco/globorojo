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
    
    $sql = "select t2.*, t1.rb_hashtag, t1.rb_video_score
    		  from rb_video t1, rb_user t2
    		 where t1.rb_user = t2.rb_user
    		   and t1.rb_video = $videoId";
    $dataVideo = $db->queryArray( $sql );
    $dataVideo = $dataVideo[0];
    
    $creatorId = $dataVideo['rb_user'];
    $creatorUsername = $dataVideo['rb_username'];
    $hashtag = $dataVideo['rb_hashtag'];
    $videoScore = $dataVideo['rb_video_score'];
    
    $sql = "select t1.*, t2.rb_username
    		  from rb_user_video_score t1, rb_user t2
    		 where t1.rb_user = $userId
    		   and t1.rb_video = $videoId
    		   and t1.rb_user =t2.rb_user";
    $isScored = $db->queryArray( $sql );
    if( $isScored == null ){
    	$data['myGivenScore'] = 0;
    	$data['myUsername'] = "";    	
    	$isScored = "N";
    }else{
    	$myGivenScore = $isScored[0]['rb_score'];
    	$myUsername = $isScored[0]['rb_username'];
    	    	    	
    	$data['myGivenScore'] = $myGivenScore;
    	$data['myUsername'] = $myUsername;
    	$isScored = "Y";
    }
    
    $sql = "select ifnull(avg(rb_video_score), 1) as avg from rb_video where rb_user = '$userId' and lcase(rb_hashtag) = lcase('$hashtag')";
    $myHashtagScore = $db->queryArray( $sql );
    $myHashtagScore = $myHashtagScore[0]['avg'];
    $data['myHashtagScore'] = $myHashtagScore;
        
    $sql = "select t1.rb_user, t2.rb_username, t1.rb_score as rb_given_score, ifnull(t1.rb_user_cred, 0) as rb_hashtag_score
    		  from rb_user_video_score t1, rb_user t2
    		 where t1.rb_video = $videoId
    		   and t1.rb_user != $userId
    		   and t1.rb_user = t2.rb_user";
/*     $sql = "select t1.*, ifnull( t2.rb_video_score, 1 ) rb_hashtag_score
    		  from ( $sql ) t1
    		  left join (select rb_user, rb_hashtag, ifnull(avg(rb_video_score), 0 ) rb_video_score from rb_video where rb_hashtag = '$hashtag' group by rb_user) t2
    		    on t1.rb_user = t2.rb_user"; */
    $scoreList = $db->queryArray( $sql );
    if( $scoreList == null ){
    	$scoreList = array();
    }
    
    $data['scoreList'] = $scoreList;
    $data['isScored'] = $isScored;
    $data['rb_hashtag'] = $hashtag;
    $data['rb_video_score'] = $videoScore;
    $data['rb_creator'] = $creatorId;
    $data['rb_creator_username'] = $creatorUsername;
    
    
    
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>