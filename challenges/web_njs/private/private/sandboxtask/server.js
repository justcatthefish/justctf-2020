var Calculator = function(result){
    this.result = result;
};

Calculator.prototype.addEquation = function(op, x, y){
    this.result = this[op](x, y);
    return this.result
};

Calculator.prototype.toString = function(prop) {
    if(prop) {
        return this.result[prop]
    }
    return this.result;
};

Calculator.prototype.add = function(x, y) {
    if(y != null)
        return x + y;
    return this.result + x;
};
Calculator.prototype.sub = function(x, y) {
    if(y != null)
        return x - y;
    return this.result - x;
};
Calculator.prototype.mul = function(x, y) {
    if(y != null)
        return x * y;
    return this.result * x;
};
Calculator.prototype.div = function(x, y) {
    if(y != null)
        return x / y;
    return this.result / x;
};

function template() {
    return  "<html>" +
        "<head></head><body>" +
        "<form id='form' method='post'>" +
        "<input name='x' type='text' value='7'>" +
        "<select name='op'>" +
        "<option value='add'>+</option>" +
        "<option value='sub'>-</option>" +
        "<option selected value='mul'>*</option>" +
        "<option value='div'>/</option>" +
        "</select>" +
        "<input name='y' type='text' value='7'>" +
        "<span>=</span>" +
        "<span id='result'>?</span>" +
        "<input type='submit' value='Calc'/>" +
        "</form>" +
        "<!-- <a href='/source'>source</a> -->" +
        "<script>function onSubmit(t){t.preventDefault();try{(async()=>{var t={};const e=new FormData(document.querySelector(\"form\"));for(var n of e.entries())t[n[0]]=n[1];try{var r=await fetch(\"/\",{method:\"POST\",headers:{Accept:\"application/json\",\"Content-Type\":\"application/json\"},body:JSON.stringify([{op:t.op,x:parseInt(t.x),y:parseInt(t.y)}])});document.getElementById(\"result\").innerText=await r.text()}catch(t){document.getElementById(\"result\").innerText=t.toString()}})()}catch(t){}return!1}document.getElementById(\"form\").addEventListener(\"submit\",onSubmit);</script>" +
        "<!-- <a href='/source'>source</a> -->" +
        "</body></html>"
}

// GET /
// POST /
function handlerCalc(r) {
    r.headersOut['Content-Type'] = 'text/html';
    if (r.method !== "POST") {
        r.return(200, template());
        return;
    }

    try {
        var data = r.requestBody;
        var calc = new Calculator(0);
        var calls = JSON.parse(data);
        for(var i = 0; i<calls.length; i++) {
            var call = calls[i];
            calc.addEquation(call.op, call.x, call.y);
        }
        r.return(200, calc.toString());
    } catch (e) {
        r.return(500, e.toString());
    }
}

// GET /source
function handlerSource(r) {
    r.headersOut['Content-Type'] = 'text/plain';
    r.return(200, require("fs").readFileSync("/etc/nginx/server.js"));
}

// GET /info
function handlerInfo(r) {
    r.headersOut['Content-Type'] = 'text/plain';
    r.return(200, njs.dump(global));
}

/*
Hint1: We are using docker image `nginx:1.19.5-alpine`
Hint2: Flag is in `/home/` directory
*/
export default {handlerCalc, handlerSource, handlerInfo};
