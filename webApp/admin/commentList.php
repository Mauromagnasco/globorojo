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
<!--[if IE 8]> <html lang="en" class="ie8"> <![endif]-->  
<!--[if IE 9]> <html lang="en" class="ie9"> <![endif]-->  
<!--[if !IE]><!--> <html lang="en"> <!--<![endif]-->  
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
		$pageNo = 3;
	?>
	<link rel="stylesheet" type="text/css" href="http://www.datatables.net/media/blog/bootstrap_2/DT_bootstrap.css">
	
	<script type="text/javascript" src="js/jquery.dataTables.js"></script>
	<script type="text/javascript" src="js/DT_bootstrap.js"></script>
	<script type="text/javascript" src="js/commentList.js"></script>		
</head>

<body>

<?php require_once("top.php"); ?>

<div class="container" style="min-height: 530px;">     
    <div class="row">
		<?php require_once("leftMenu.php"); ?>
        <div class="col-md-9">
			<div class="panel panel-sea margin-bottom-40">
				<div class="panel-heading">
					<h3 class="panel-title floatleft" style="line-height:30px;"><i class="icon-user"></i> Comment List</h3>
					<button class="floatright btn-u btn-u-red" onclick="onDeleteComment()" style="width: 90px;"><i class="icon-trash"></i> Delete</button>
					<div class="clearboth"></div>
				</div>
				<?php
					$sql = "select t1.*, t2.rb_username, t3.rb_hashtag
							  from rb_user_video_comment t1, rb_user t2, rb_video t3
							 where t1.rb_user = t2.rb_user
							   and t1.rb_video = t3.rb_video
							 order by t1.rb_created_time desc";
					$dataComment = $db->queryArray( $sql ); 
				?>
				<table class="table table-striped" id="example">
					<thead>
						<tr>
							<th style="width:60px;"><input type="checkbox" id="checkAll" onclick="onCheckAll( this )"/></th>
							<th style="width:60px;">No</th>
							<th style="width:130px;">Hashtag</th>
							<th style="width:130px;">Username</th>
							<th>Comment</th>
							<th style="width:90px;">Created Time</th>
						</tr>
					</thead>
					<tbody>
						<?php for($i = 0 ; $i < count( $dataComment); $i ++ ){ ?>					
						<tr>
							<td><input type="checkbox" id="chkCommentId" value="<?php echo $dataComment[$i]['rb_user_video_comment']; ?>"/></td>
							<td><?php echo $i + 1; ?></td>
							<td><a href="commentDetail.php?id=<?php echo $dataComment[$i]['rb_user_video_comment']; ?>"/><?php echo "#".$dataComment[$i]['rb_hashtag']; ?></a></td>
							<td><a href="commentDetail.php?id=<?php echo $dataComment[$i]['rb_user_video_comment']; ?>"/><?php echo "@".$dataComment[$i]['rb_username']; ?></a></td>
							<td><a href="commentDetail.php?id=<?php echo $dataComment[$i]['rb_user_video_comment']; ?>"/><?php echo $dataComment[$i]['rb_content']; ?></a></td>
							<td><a href="commentDetail.php?id=<?php echo $dataComment[$i]['rb_user_video_comment']; ?>"/><?php echo $dataComment[$i]['rb_created_time']; ?></a></td>
						</tr>
						<?php } ?>
					</tbody>
				</table>
			</div>        			       
        </div>
    </div>          
</div>     
<?php require_once("footer.php"); ?>
</body>
</html> 