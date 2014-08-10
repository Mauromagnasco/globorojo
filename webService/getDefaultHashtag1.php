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

    $sql1 = "select t1.rb_parent_hashtag as p, t1.rb_hashtag h, 2 as priority, 0 as cnt
    		  from rb_default_hashtag t1, rb_video t2
    		 where date(t2.rb_created_time) = date(now())
    		   and ( lcase(t2.rb_hashtag) = lcase(t1.rb_hashtag) or lcase(t2.rb_hashtag) = lcase(t1.rb_parent_hashtag))";
    
    $sql = "select rb_hashtag, count(*) cnt, max(rb_created_time) as rb_created_time
    		  from rb_video
    		 group by lcase( rb_hashtag )";
    
    $sql2 = "select t1.rb_parent_hashtag as p, t1.rb_hashtag h, 1 as priority, ifnull( t2.cnt, 0 ) as cnt
    		  from rb_default_hashtag t1, ( $sql ) t2
    		 where date(t2.rb_created_time) <= date(now())
    		   and date(date_sub(now(), interval 1 month)) <= date(t2.rb_created_time) 
    		   and ( lcase(t2.rb_hashtag) = lcase(t1.rb_hashtag) or lcase(t2.rb_hashtag) = lcase(t1.rb_parent_hashtag))";
    
    $sql3 = "select t1.rb_parent_hashtag as p, t1.rb_hashtag h, 0 as priority, ifnull( t2.cnt, 0 ) as cnt
    		   from rb_default_hashtag t1
    		   left join ( $sql ) t2 on lcase(t2.rb_hashtag) = lcase(t1.rb_parent_hashtag)";
    
    $sql = "select * from ($sql1 union all $sql2 union all $sql3) t1 order by priority desc, cnt desc limit 5000";
    
    $sql = "select p, h from ( $sql ) t3 group by p, h";

    $hashtagList = $db->queryArray( $sql );
    if( $hashtagList == null )
    	$hashtagList = array();
    
    $data['hashtagList'] = $hashtagList;
    $data['result'] = $result;
    $data['error'] = $error;
    ob_start("ob_gzhandler");
    // header('Content-Type: application/json');
    echo json_encode($data);
    ob_end_flush();
?>