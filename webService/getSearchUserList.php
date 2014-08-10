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
    $type = mysql_escape_string($_POST['type']);
    $txtKeyword = mysql_escape_string($_POST['txtKeyword']);
    $cntLoaded = mysql_escape_string($_POST['cntLoaded']);
    $currentTime = mysql_escape_string($_POST['currentTime']);
    $cntLazyLoad = mysql_escape_string($_POST['cntLazyLoad']);
    $sort = mysql_escape_string($_POST['sort']);
    
    if( $sort == 2 ) $sort = "asc";
    else $sort = "desc";   
    
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
		$sql .= " order by t1.rb_created_time $sort";
	else if( $type == 2 )
		$sql .= " order by t1.rb_username $sort";
	else if( $type == 3 )
		$sql .= " order by t1.rb_cred $sort";
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
	
	$userList = $db->queryArray( $sql );
	if( $userList == null )
		$userList = array( );
	for( $i = 0; $i < count( $userList ); $i ++ ){
		$userList[ $i ]['rb_photo'] = RB_photoURL( $userList[ $i ]['rb_photo'] );
	}
	if( $userList == null )
		$userList = array( );
    $data['userList'] = $userList;
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
