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
    $sql = "select t2.*
    	 	  from rb_friend t1, rb_user t2
    		 where t1.rb_following = $userId
    		   and t1.rb_follower = t2.rb_user";
    
    $sql = "select t1.*, if( ifnull( t2.rb_friend, 'N' ) = 'N', 'N', 'Y' ) as isFollowing
    			 , if( ifnull( t3.rb_friend, 'N' ) = 'N', 'N', 'Y' ) as isFollower
    		  from ( $sql ) t1
    		  left join rb_friend t2 on t1.rb_user = t2.rb_follower and t2.rb_following = '$userId'
    		  left join rb_friend t3 on t1.rb_user = t3.rb_following and t3.rb_follower = '$userId'";    
    
    $dataUser = $db->queryArray( $sql );
    for( $i = 0; $i < count( $dataUser ); $i ++ ){
    	$dataUser[ $i ]['rb_photo'] = RB_photoURL( $dataUser[ $i ]['rb_photo'] );
    }
    if( $dataUser == null )
    	$dataUser = array( );
    
    $data['userList'] = $dataUser;
    $data['result'] = $result;
    $data['error'] = $error;
    header('Content-Type: application/json');
    echo json_encode($data);    
?>
