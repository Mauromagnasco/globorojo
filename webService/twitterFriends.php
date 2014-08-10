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
	require_once('../twitteroauth/twitteroauth.php');
	require_once("../common/DB_Connection.php");	
    require_once("../common/functions.php");
    require_once("../common/checkAuth.php");    

    $result = "success";
    $error = "";
    $data = array();
    
    $userId = mysql_escape_string($_POST['userId']);
    $sql = "select * from rb_user_sns where rb_user = $userId and rb_sns_type = 2";
    $dataSnsUser = $db->queryArray( $sql );
    if( $dataSnsUser == null ){
    	$result = "failed";
    }else{
    	$strSnsIds = "";
    	$token1 = $dataSnsUser[0]['rb_token'];
    	$token2 = $dataSnsUser[0]['rb_token2'];
    	
    	/* Create a TwitterOauth object with consumer/user tokens. */
    	$connection = new TwitterOAuth(TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET, $token1, $token2);
    	
    	$following = $connection->get('friends/ids');
    	$strSnsId = "";
    	for( $i = 0; $i < count( $following->ids); $i++ ){
    		$strSnsIds.="'".$following->ids[$i]."'";
    		if( $i != count( $following->ids ) - 1 )
    			$strSnsIds = $strSnsIds.",";
    	}
    	$sql = "select t2.*
    			  from rb_user_sns t1, rb_user t2
    			 where t1.rb_sns_type = 2
    			   and t1.rb_sns_id in ( $strSnsIds )
    			   and t1.rb_user = t2.rb_user";

    	$friendList = $db->queryArray( $sql );
    	if( $friendList == null )
    		$friendList = array( );
    	for( $i = 0; $i < count( $friendList ); $i ++ ){
    		$friendList[$i]['rb_photo'] = RB_photoURL( $friendList[$i]['rb_photo'] );
    	}    	
    	$data['userList'] = $friendList;    	    	
    }    
    
	$data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);
?>