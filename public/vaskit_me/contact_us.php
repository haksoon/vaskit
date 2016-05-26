<?php
include "Sendmail.php";

$config = array(
  'host'=>'ssl://smtp.worksmobile.com:465',
  'smtp_id'=>'notice@vaskit.kr',
  'smtp_pw'=>'vaskit1234',
  'debug'=>0,
  'charset'=>'utf-8',
  'ctype'=>'text/plain'
);

$sendmail = new Sendmail($config);

$to = "notice@vaskit.kr";
$from = "notice@vaskit.kr";
$subject = "[VASKIT] New form submitted!";
$body = "\n1. ".$_POST['user_title']."\n2. ".$_POST['user_contact']."\n3. ".$_POST['user_detail']."\n\n";
// $cc_mail = "leegkrtns@gmail.com".","."seokki.yoon07@gmail.com";

$sendmail -> send_mail($to, $from, $subject, $body, $cc_mail);
?>
