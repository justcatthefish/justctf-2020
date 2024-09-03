<?php
require_once("secrets.php");
$nonce = random_bytes(8);

if(isset($_GET['flag'])){
 if(isAdmin()){
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('Content-type: text/html; charset=UTF-8');
    echo $flag;
    die();
 }
 else{
     echo "You are not an admin!";
     die();
 }
}

for($i=0; $i<10; $i++){
    if(isset($_GET['alg'])){
        $_nonce = hash($_GET['alg'], $nonce);
        if($_nonce){
            $nonce = $_nonce;
            continue;
        }
    }
    $nonce = md5($nonce);
}

if(isset($_GET['user']) && strlen($_GET['user']) <= 23) {
    header("content-security-policy: default-src 'none'; style-src 'nonce-$nonce'; script-src 'nonce-$nonce'");
    echo <<<EOT
        <script nonce='$nonce'>
            setInterval(
                ()=>user.style.color=Math.random()<0.3?'red':'black'
            ,100);
        </script>
        <center><h1> Hello <span id='user'>{$_GET['user']}</span>!!</h1>
        <p>Click <a href="?flag">here</a> to get a flag!</p>
EOT;
}else{
    show_source(__FILE__);
}

// Found a bug? We want to hear from you! /bugbounty.php
// Check /Dockerfile