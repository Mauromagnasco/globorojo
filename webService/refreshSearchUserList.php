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
    
    $sql = "select t1.*, if( ifnull( t2.rb_friend, 'N' ) = 'N', 'N', 'Y' ) as isFollowing
    			    , if( ifnull( t3.rb_friend, 'N' ) = 'N', 'N', 'Y' ) as isFollower
    		  from rb_user t1
    		  left join rb_friend t2 on t1.rb_user = t2.rb_follower and t2.rb_following = '$userId'
    		  left join rb_friend t3 on t1.rb_user = t3.rb_following and t3.rb_follower = '$userId'";
    if( $txtKeyword == "" ){

    }else{
		$sql.= " where t1.rb_username like '%$txtKeyword%'";
	}
	if( $type == 1 )
		$sql .= " order by t1.rb_created_time desc";
	else if( $type == 2 )
		$sql .= " order by t1.rb_cred desc";

	
	$userList = $db->queryArray( $sql );
	if( $userList == null )
		$userList = array( );
	for( $i = 0; $i < count( $userList ); $i ++ ){
		$userList[ $i ]['rb_photo'] = RB_photoURL( $userList[ $i ]['rb_photo'] );
	}
	
	$sql = "select now() currentTime";
	$dataResult = $db->queryArray( $sql );
	
	$data['currentTime'] = $dataResult[0]['currentTime'];	
	
	if( $userList == null )
		$userList = array( );
    $data['userList'] = $userList;
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);
?>
