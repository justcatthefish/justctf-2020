<?php

require_once("secrets.php");

error_reporting(0);
ini_set("display_errors", 0);
$message = "";

function send_url_bot($url){
    global $admin_secret, $chall_url;
    $bot_url = 'http://bot:8080/bot';
    $url_encoded = urlencode($url);
    $redir_url = $chall_url."secrets.php?token=$admin_secret&url=$url_encoded";
    $data = array(
        'timeout' => 5, 
        'url' => $redir_url, 
        'region' => 'eu',
        'user_ip' => '127.0.0.1'
    );

    // use key 'http' even if you send the request to https://...
    $options = array(
        'http' => array(
            'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
            'method'  => 'POST',
            'content' => http_build_query($data)
        )
    );
    $context  = stream_context_create($options);
    $result = file_get_contents($bot_url, false, $context);
    if ($result === false) { return false; }
    return true;

}
function parse_parameters(){
    global $private_key, $message;
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['g-recaptcha-response']) && isset($_POST['url'])) {
        $recaptcha_url = 'https://www.google.com/recaptcha/api/siteverify';
        $recaptcha_response = $_POST['g-recaptcha-response'];
    
        $url = $_POST['url'];
        if(!preg_match('/^https?:\/\//', $url)){
            $message = "Invalid URL! Needs to be https?://";
            return 0;
        }
        $recaptcha = file_get_contents($recaptcha_url . '?secret=' . $private_key . '&response=' . $recaptcha_response);
        $recaptcha = json_decode($recaptcha);
    
        if ($recaptcha->success) {
            if(send_url_bot($url)){
                $message = "<h2>Thank you for reporting this information to us. We are sending it to the appropriate product team for further investigation. We will keep you updated on our progress.</h2>";
            }else{
                $message = "<h2>Something went wrong with the bot, please reach out to admins on discord</h2>";
            }
            
        } else {
            $message = "<h2>Error with recaptcha.</h2>";
        }
    }
}

parse_parameters();

?>

<html>

<head>
    <meta charset="UTF-8">
    <title>BugBounty</title>
</head>

<body>
    <script src='https://www.google.com/recaptcha/api.js?hl=en'></script>
    <script>
        function submit() {
            form.submit()
        }
    </script>
    <h1>Bug Bounty platform</h1>
    <?=$message;?>
    <p>Have you found a vulnerability on our website? Let us know in the form below, but know, that we only accept links to writeups!</p>
    <form id="form" method="POST">
        writeup URL: <input name="url" />
        <button class="g-recaptcha" data-sitekey="<?=$site_key;?>" data-callback="submit" data-action="submit">Submit</button>
    </form>
</body>

</html>