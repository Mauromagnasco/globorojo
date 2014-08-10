<!-- 
 * Globo Rojo open source application
 *
 *  Copyright © 2013, 2014 by Mauro Magnasco <mauro.magnasco@gmail.com>
 *
 *  Licensed under GNU General Public License 2.0 or later.
 *  Some rights reserved. See COPYING, AUTHORS.
 *
 * @license GPL-2.0+ <http://spdx.org/licenses/GPL-2.0+>
 -->
<?php session_start(); ?>
<!DOCTYPE html>
<!--[if IE 8]><html lang="en" id="ie8" class="lt-ie9 lt-ie10"> <![endif]-->
<!--[if IE 9]><html lang="en" id="ie9" class="gt-ie8 lt-ie10"> <![endif]-->
<!--[if gt IE 9]><!-->
<html lang="en"> <!--<![endif]-->
<head>
    <title>Red Balloon</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
       
	<?php 
		require("asset.php");
		require("../common/config.php");
		require("../common/DB_Connection.php");		
		require("../common/functions.php");		
    	if( isset($_GET['id']) && $_GET['id'] != "" ){
			$commentId = $_GET['id'];
			$sql = "select t1.*, t2.rb_username, t3.rb_hashtag
					  from rb_user_video_comment t1, rb_user t2, rb_video t3
					 where t1.rb_user = t2.rb_user
					   and t1.rb_video = t3.rb_video
					   and t1.rb_user_video_comment = $commentId";
			$dataComment = $db->queryArray( $sql );
			$dataComment = $dataComment[0];
			$type = "Edit";
		}else{
			$type = "Add";
		}    	
    	$pageNo = 3;
	?>
	<link rel="stylesheet" type="text/css" href="http://www.datatables.net/media/blog/bootstrap_2/DT_bootstrap.css">
	
	<script type="text/javascript" src="js/jquery.dataTables.js"></script>
	<script type="text/javascript" src="js/DT_bootstrap.js"></script>
	<script type="text/javascript" src="js/commentDetail.js"></script>		
</head>
<body>
<?php require_once("top.php"); ?>
<div class="container" style="min-height: 530px;">     
    <div class="row">
	    <?php require_once("leftMenu.php"); ?>
	   	 <div class="col-md-9">
			<div class="panel panel-green margin-bottom-40">
                <div class="panel-heading">
                    <h3 class="panel-title"><i class="icon-user"></i> Comment <?php echo $type;?></h3>
                </div>
                <div class="panel-body">
                	<div class="form-horizontal">
                		<input type="hidden" id="type" value="<?php echo $type;?>"/>
                		<input type="hidden" id="commentId" value="<?php echo $commentId?>"/>
                		
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Hashtag</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataComment['rb_hashtag']?>" class="form-control" readonly style="background:#FEFEFE; cursor: pointer;">
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Username</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataComment['rb_username']?>" class="form-control" readonly style="background:#FEFEFE; cursor: pointer;">
                            </div>
                        </div>                        
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Comment</label>
                            <div class="col-lg-10">
                                <textarea id="content" class="form-control"><?php echo $dataComment['rb_content']?></textarea>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label class="col-lg-2 control-label">Created Time</label>
                            <div class="col-lg-10">
                                <input type="text" value="<?php echo $dataComment['rb_created_time']?>" class="form-control" readonly style="background:#FEFEFE; cursor: pointer;" >
                            </div>
                        </div>
                                                
                        <div class="form-group">
                            <div class="col-lg-offset-2 col-lg-10" style="text-align:center;">
                                <button class="btn-u btn-u-green" style="margin-right: 20px;width:90px;" onclick="onCommentSave()"><i class="icon-edit"></i> Save</button>
                                <button class="btn-u btn-u-red" style="width:90px;" onclick="window.location.href='commentList.php'"><i class="icon-list"></i> List</button>
                            </div>
                        </div>                                                                        
					</div>
				</div>
			</div>
		</div>
    </div>
</div>
</body>
</html>