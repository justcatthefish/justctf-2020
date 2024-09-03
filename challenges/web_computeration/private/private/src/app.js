const express = require("express");
const bodyParser = require('body-parser');
const fetch = require("node-fetch");
const Recaptcha = require('express-recaptcha').RecaptchaV3;

const app = express();
const flag = 'justCTF{cross_origin_timing_lol}';
const domain_url = 'https://computeration.web.jctf.pro/';

const RECAPTCHA_SECRET_KEY = "CAPTCHA_SECRET"
const RECAPTCHA_PUBLIC_KEY = "CAPTCHA_PUBLIC"

const recaptcha = new Recaptcha(RECAPTCHA_PUBLIC_KEY, RECAPTCHA_SECRET_KEY, {callback:'cb'});


app.set('view engine', 'ejs');

app.use(bodyParser.urlencoded({extended: false}));

app.get('/', (req,res)=>{
    res.render('index');
});

app.get('/b811667a5a09db734093a974111d750e', (req, res)=>{
    res.set('Referrer-Policy', 'no-referer');
    res.send(`<script>
    
    localStorage.setItem('notes',JSON.stringify([{
        title:'flag',
        content:'${flag}'
    }]));
    
    location = (new URL(location.href)).searchParams.get('url');

    </script>`)
});

app.get('/report', (req, res)=>{
    res.render('report');
})

app.post('/report', recaptcha.middleware.verify, async (req, res)=>{
    if (req.recaptcha.error) {
        return res.send("Captcha Error: " + req.recaptcha.error);
    }

    if(typeof req.body.url !== 'string' || !req.body.url.match('^https?://')){
        return res.send("Invalid url. Only https?:// allowed");
    }
    
    const url = domain_url + 'b811667a5a09db734093a974111d750e?url='+encodeURIComponent(req.body.url);
    console.log(url);
    let resp = await fetch('http://bot:8080/bot',{
        method:'POST', 
        headers: {'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'},
        body:new URLSearchParams({
          timeout: 10,
          url,
          task_name: 'computerator',
          region: 'eu',
          user_ip: req.user_ip,
        }),
      }).then(e=>e.text());

    console.log(resp);

    if(resp){
        res.send("The bot will visit your URL shortly. Position in queue: " + resp);
    }else{
        res.send("Something went wrong");
    }
})

const PORT = 8080;

app.listen(PORT, ()=>{
    console.log(`The app is listening on localhost:${PORT}`);
})